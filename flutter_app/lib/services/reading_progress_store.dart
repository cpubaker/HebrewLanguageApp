import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guide_lesson_status.dart';

abstract class ReadingProgressStore {
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses();

  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  );
}

class SharedPreferencesReadingProgressStore implements ReadingProgressStore {
  static const String _storageKey = 'reading_lesson_statuses_v1';

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStatuses = prefs.getString(_storageKey);
      if (storedStatuses == null || storedStatuses.trim().isEmpty) {
        return <String, GuideLessonStatus>{};
      }

      return _decodeStatuses(storedStatuses);
    } catch (error) {
      debugPrint(
        'Ignoring reading progress for $_storageKey because it could not be loaded: $error',
      );
      return <String, GuideLessonStatus>{};
    }
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatuses = await loadLessonStatuses();
    final sanitizedAssetPath = assetPath.trim();
    if (sanitizedAssetPath.isEmpty) {
      return;
    }

    if (status == GuideLessonStatus.unread) {
      storedStatuses.remove(sanitizedAssetPath);
    } else {
      storedStatuses[sanitizedAssetPath] = status;
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
      if (rawPath.isEmpty ||
          status == null ||
          status == GuideLessonStatus.unread) {
        continue;
      }

      statuses[rawPath] = status;
    }

    return statuses;
  }
}
