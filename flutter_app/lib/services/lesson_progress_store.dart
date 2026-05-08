import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guide_lesson_status.dart';
import '../models/lesson_progress_key.dart';

abstract class LessonProgressStore {
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses();

  Future<void> setLessonStatus(String lessonKey, GuideLessonStatus status);
}

class SharedPreferencesLessonProgressStore implements LessonProgressStore {
  const SharedPreferencesLessonProgressStore({
    required this.storageKey,
    required this.logLabel,
    this.mergeDuplicateStatuses = false,
  });

  final String storageKey;
  final String logLabel;
  final bool mergeDuplicateStatuses;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStatuses = prefs.getString(storageKey);
      if (storedStatuses != null && storedStatuses.trim().isNotEmpty) {
        return _decodeStatuses(storedStatuses);
      }
      return <String, GuideLessonStatus>{};
    } catch (error) {
      debugPrint(
        'Ignoring $logLabel progress for $storageKey because it could not be loaded: $error',
      );
      return <String, GuideLessonStatus>{};
    }
  }

  @override
  Future<void> setLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatuses = await loadLessonStatuses();
    final sanitizedLessonKey = lessonProgressKeyFromStoredValue(lessonKey);
    if (sanitizedLessonKey.isEmpty) {
      return;
    }

    if (status == GuideLessonStatus.unread) {
      storedStatuses.remove(sanitizedLessonKey);
    } else {
      storedStatuses[sanitizedLessonKey] = status;
    }

    final encodedStatuses = <String, String>{
      for (final entry in storedStatuses.entries)
        entry.key: entry.value.storageValue,
    };

    await prefs.setString(storageKey, jsonEncode(encodedStatuses));
  }

  Map<String, GuideLessonStatus> _decodeStatuses(String rawPayload) {
    final decodedPayload = jsonDecode(rawPayload);
    if (decodedPayload is! Map) {
      return <String, GuideLessonStatus>{};
    }

    final statuses = <String, GuideLessonStatus>{};
    for (final entry in decodedPayload.entries) {
      final rawPath = entry.key?.toString().trim() ?? '';
      final rawStatus = entry.value?.toString() ?? '';
      final status = GuideLessonStatus.fromStorageValue(rawStatus);
      final canonicalKey = lessonProgressKeyFromStoredValue(rawPath);
      if (canonicalKey.isEmpty ||
          status == null ||
          status == GuideLessonStatus.unread) {
        continue;
      }

      statuses[canonicalKey] = mergeDuplicateStatuses
          ? _mergeStatus(statuses[canonicalKey], status)
          : status;
    }

    return statuses;
  }

  GuideLessonStatus _mergeStatus(
    GuideLessonStatus? existing,
    GuideLessonStatus incoming,
  ) {
    if (existing == null) {
      return incoming;
    }

    if (existing == GuideLessonStatus.read ||
        incoming == GuideLessonStatus.read) {
      return GuideLessonStatus.read;
    }

    if (existing == GuideLessonStatus.studying ||
        incoming == GuideLessonStatus.studying) {
      return GuideLessonStatus.studying;
    }

    return incoming;
  }
}
