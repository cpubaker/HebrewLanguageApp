import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_word.dart';

class StoredWordProgress {
  const StoredWordProgress({
    required this.wordId,
    required this.correct,
    required this.wrong,
    required this.lastCorrect,
    this.lastReviewedAt,
    this.lastReviewCorrect,
    this.writingCorrect = 0,
    this.writingWrong = 0,
    this.writingLastCorrect,
  });

  factory StoredWordProgress.fromJson(
    String wordId,
    Map<String, dynamic> json,
  ) {
    return StoredWordProgress(
      wordId: wordId,
      correct: _readNonNegativeInt(json['correct']),
      wrong: _readNonNegativeInt(json['wrong']),
      lastCorrect: _readOptionalString(json['last_correct']),
      lastReviewedAt: _readOptionalString(json['last_reviewed_at']),
      lastReviewCorrect: _readOptionalBool(json['last_review_correct']),
      writingCorrect: _readNonNegativeInt(json['writing_correct']),
      writingWrong: _readNonNegativeInt(json['writing_wrong']),
      writingLastCorrect: _readOptionalString(json['writing_last_correct']),
    );
  }

  final String wordId;
  final int correct;
  final int wrong;
  final String? lastCorrect;
  final String? lastReviewedAt;
  final bool? lastReviewCorrect;
  final int writingCorrect;
  final int writingWrong;
  final String? writingLastCorrect;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'correct': correct,
      'wrong': wrong,
      if (lastCorrect != null && lastCorrect!.trim().isNotEmpty)
        'last_correct': lastCorrect,
      if (lastReviewedAt != null && lastReviewedAt!.trim().isNotEmpty)
        'last_reviewed_at': lastReviewedAt,
      if (lastReviewCorrect != null) 'last_review_correct': lastReviewCorrect,
      'writing_correct': writingCorrect,
      'writing_wrong': writingWrong,
      if (writingLastCorrect != null && writingLastCorrect!.trim().isNotEmpty)
        'writing_last_correct': writingLastCorrect,
    };
  }

  static int _readNonNegativeInt(Object? value) {
    final parsedValue = switch (value) {
      final num numericValue => numericValue.toInt(),
      final String textValue => int.tryParse(textValue.trim()),
      _ => null,
    };

    if (parsedValue == null || parsedValue < 0) {
      return 0;
    }

    return parsedValue;
  }

  static String? _readOptionalString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  static bool? _readOptionalBool(Object? value) {
    return switch (value) {
      final bool booleanValue => booleanValue,
      final num numericValue => numericValue != 0,
      final String textValue => switch (textValue.trim().toLowerCase()) {
        'true' => true,
        'false' => false,
        '1' => true,
        '0' => false,
        _ => null,
      },
      _ => null,
    };
  }
}

abstract class WordProgressStore {
  Future<Map<String, StoredWordProgress>> load();

  Future<void> saveWord(LearningWord word);
}

class SharedPreferencesWordProgressStore implements WordProgressStore {
  SharedPreferencesWordProgressStore();

  static const String _legacyStorageKey = 'learning_word_progress_v1';
  static const String _indexKey = 'learning_word_progress_v2_index';
  static const String _entryKeyPrefix = 'learning_word_progress_v2_word_';

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _loadFromPrefs(prefs);
    } catch (error) {
      debugPrint(
        'Ignoring word progress for $_indexKey because it could not be loaded: $error',
      );
      return <String, StoredWordProgress>{};
    }
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    final prefs = await SharedPreferences.getInstance();
    final wordId = word.wordId.trim();
    if (wordId.isEmpty) {
      return;
    }

    final indexedWordIds = (await _loadIndexedWordIds(prefs)).toSet();

    if (_hasProgress(word)) {
      await prefs.setString(
        _entryKeyFor(wordId),
        jsonEncode(
          StoredWordProgress(
            wordId: wordId,
            correct: word.correct,
            wrong: word.wrong,
            lastCorrect: word.lastCorrect,
            lastReviewedAt: word.lastReviewedAt,
            lastReviewCorrect: word.lastReviewCorrect,
            writingCorrect: word.writingCorrect,
            writingWrong: word.writingWrong,
            writingLastCorrect: word.writingLastCorrect,
          ).toJson(),
        ),
      );
      indexedWordIds.add(wordId);
    } else {
      await prefs.remove(_entryKeyFor(wordId));
      indexedWordIds.remove(wordId);
    }

    await prefs.setStringList(_indexKey, _sortedWordIds(indexedWordIds));
  }

  bool _hasProgress(LearningWord word) {
    return word.correct > 0 ||
        word.wrong > 0 ||
        (word.lastCorrect?.trim().isNotEmpty ?? false) ||
        (word.lastReviewedAt?.trim().isNotEmpty ?? false) ||
        word.lastReviewCorrect != null ||
        word.writingCorrect > 0 ||
        word.writingWrong > 0 ||
        (word.writingLastCorrect?.trim().isNotEmpty ?? false);
  }

  Future<Map<String, StoredWordProgress>> _loadFromPrefs(
    SharedPreferences prefs,
  ) async {
    final indexedWordIds = prefs.getStringList(_indexKey);
    if (indexedWordIds != null) {
      return _loadIndexedProgress(prefs, indexedWordIds);
    }

    final legacyProgress = await _loadLegacyProgress(prefs);
    if (legacyProgress.isNotEmpty) {
      await _persistMigratedProgress(prefs, legacyProgress);
    }

    return legacyProgress;
  }

  Map<String, StoredWordProgress> _loadIndexedProgress(
    SharedPreferences prefs,
    List<String> indexedWordIds,
  ) {
    final progressByWordId = <String, StoredWordProgress>{};

    for (final rawWordId in indexedWordIds) {
      final wordId = rawWordId.trim();
      if (wordId.isEmpty) {
        continue;
      }

      final rawProgress = prefs.getString(_entryKeyFor(wordId));
      if (rawProgress == null || rawProgress.trim().isEmpty) {
        continue;
      }

      try {
        final decoded = jsonDecode(rawProgress);
        if (decoded is! Map) {
          continue;
        }

        progressByWordId[wordId] = StoredWordProgress.fromJson(
          wordId,
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      } on FormatException catch (error) {
        debugPrint(
          'Ignoring corrupted word progress entry for $wordId: $error',
        );
      }
    }

    return progressByWordId;
  }

  Future<Map<String, StoredWordProgress>> _loadLegacyProgress(
    SharedPreferences prefs,
  ) async {
    final rawMap = await _loadLegacyRawMap(prefs);
    final progressByWordId = <String, StoredWordProgress>{};

    rawMap.forEach((wordId, value) {
      final trimmedWordId = wordId.trim();
      if (trimmedWordId.isEmpty || value is! Map) {
        return;
      }

      progressByWordId[trimmedWordId] = StoredWordProgress.fromJson(
        trimmedWordId,
        value.map((key, entryValue) => MapEntry(key.toString(), entryValue)),
      );
    });

    return progressByWordId;
  }

  Future<void> _persistMigratedProgress(
    SharedPreferences prefs,
    Map<String, StoredWordProgress> progressByWordId,
  ) async {
    final indexedWordIds = <String>{};

    for (final entry in progressByWordId.entries) {
      final wordId = entry.key.trim();
      if (wordId.isEmpty) {
        continue;
      }

      final progress = entry.value;
      await prefs.setString(
        _entryKeyFor(wordId),
        jsonEncode(
          StoredWordProgress(
            wordId: wordId,
            correct: progress.correct,
            wrong: progress.wrong,
            lastCorrect: progress.lastCorrect,
            lastReviewedAt: progress.lastReviewedAt,
            lastReviewCorrect: progress.lastReviewCorrect,
            writingCorrect: progress.writingCorrect,
            writingWrong: progress.writingWrong,
            writingLastCorrect: progress.writingLastCorrect,
          ).toJson(),
        ),
      );
      indexedWordIds.add(wordId);
    }

    await prefs.setStringList(_indexKey, _sortedWordIds(indexedWordIds));
  }

  Future<Map<String, dynamic>> _loadLegacyRawMap(
    SharedPreferences prefs,
  ) async {
    final rawValue = prefs.getString(_legacyStorageKey);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return <String, dynamic>{};
      }

      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } on FormatException catch (error) {
      debugPrint(
        'Ignoring corrupted word progress payload for $_legacyStorageKey: $error',
      );
      return <String, dynamic>{};
    }
  }

  Future<List<String>> _loadIndexedWordIds(SharedPreferences prefs) async {
    final indexedWordIds = prefs.getStringList(_indexKey);
    if (indexedWordIds != null) {
      return indexedWordIds
          .map((wordId) => wordId.trim())
          .where((wordId) => wordId.isNotEmpty)
          .toList(growable: false);
    }

    final legacyProgress = await _loadLegacyProgress(prefs);
    if (legacyProgress.isEmpty) {
      return const <String>[];
    }

    await _persistMigratedProgress(prefs, legacyProgress);
    return _sortedWordIds(legacyProgress.keys);
  }

  List<String> _sortedWordIds(Iterable<String> wordIds) {
    return wordIds
        .map((wordId) => wordId.trim())
        .where((wordId) => wordId.isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
  }

  String _entryKeyFor(String wordId) => '$_entryKeyPrefix$wordId';
}
