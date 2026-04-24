import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guide_lesson_status.dart';
import '../models/lesson_progress_key.dart';

abstract class ReadingProgressStore {
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses();

  Future<void> setLessonStatus(String lessonKey, GuideLessonStatus status);
}

class SharedPreferencesReadingProgressStore implements ReadingProgressStore {
  static const String _legacyStorageKey = 'reading_lesson_statuses_v1';
  static const String _storageKey = 'reading_lesson_statuses_v2';

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStatuses = prefs.getString(_storageKey);
      if (storedStatuses != null && storedStatuses.trim().isNotEmpty) {
        return _decodeStatuses(storedStatuses);
      }
      final legacyStatuses = prefs.getString(_legacyStorageKey);
      if (legacyStatuses == null || legacyStatuses.trim().isEmpty) {
        return <String, GuideLessonStatus>{};
      }

      return _decodeStatuses(legacyStatuses);
    } catch (error) {
      debugPrint(
        'Ignoring reading progress for $_storageKey because it could not be loaded: $error',
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

    await prefs.setString(_storageKey, jsonEncode(encodedStatuses));
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

      statuses[canonicalKey] = status;
    }

    return statuses;
  }
}
