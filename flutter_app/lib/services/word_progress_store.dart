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
      writingCorrect: _readNonNegativeInt(json['writing_correct']),
      writingWrong: _readNonNegativeInt(json['writing_wrong']),
      writingLastCorrect: _readOptionalString(json['writing_last_correct']),
    );
  }

  final String wordId;
  final int correct;
  final int wrong;
  final String? lastCorrect;
  final int writingCorrect;
  final int writingWrong;
  final String? writingLastCorrect;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'correct': correct,
      'wrong': wrong,
      if (lastCorrect != null && lastCorrect!.trim().isNotEmpty)
        'last_correct': lastCorrect,
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
}

abstract class WordProgressStore {
  Future<Map<String, StoredWordProgress>> load();

  Future<void> saveWord(LearningWord word);
}

class SharedPreferencesWordProgressStore implements WordProgressStore {
  SharedPreferencesWordProgressStore();

  static const String _storageKey = 'learning_word_progress_v1';

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _loadFromPrefs(prefs);
    } catch (error) {
      debugPrint(
        'Ignoring word progress for $_storageKey because it could not be loaded: $error',
      );
      return <String, StoredWordProgress>{};
    }
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    final prefs = await SharedPreferences.getInstance();
    final currentMap = await _loadRawMap(prefs);

    final hasProgress =
        word.correct > 0 ||
        word.wrong > 0 ||
        (word.lastCorrect?.trim().isNotEmpty ?? false) ||
        word.writingCorrect > 0 ||
        word.writingWrong > 0 ||
        (word.writingLastCorrect?.trim().isNotEmpty ?? false);

    if (hasProgress) {
      currentMap[word.wordId] = StoredWordProgress(
        wordId: word.wordId,
        correct: word.correct,
        wrong: word.wrong,
        lastCorrect: word.lastCorrect,
        writingCorrect: word.writingCorrect,
        writingWrong: word.writingWrong,
        writingLastCorrect: word.writingLastCorrect,
      ).toJson();
    } else {
      currentMap.remove(word.wordId);
    }

    await prefs.setString(_storageKey, jsonEncode(currentMap));
  }

  Future<Map<String, dynamic>> _loadRawMap(SharedPreferences prefs) async {
    final rawValue = prefs.getString(_storageKey);
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
        'Ignoring corrupted word progress payload for $_storageKey: $error',
      );
      return <String, dynamic>{};
    }
  }

  Future<Map<String, StoredWordProgress>> _loadFromPrefs(
    SharedPreferences prefs,
  ) async {
    final rawMap = await _loadRawMap(prefs);
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
}
