import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_word.dart';
import 'json_value_readers.dart';

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
      correct: readNonNegativeInt(json['correct']),
      wrong: readNonNegativeInt(json['wrong']),
      lastCorrect: readOptionalString(json['last_correct']),
      lastReviewedAt: readOptionalString(json['last_reviewed_at']),
      lastReviewCorrect: readOptionalBool(json['last_review_correct']),
      writingCorrect: readNonNegativeInt(json['writing_correct']),
      writingWrong: readNonNegativeInt(json['writing_wrong']),
      writingLastCorrect: readOptionalString(json['writing_last_correct']),
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
}

abstract class WordProgressStore {
  Future<Map<String, StoredWordProgress>> load();

  Future<void> saveWord(LearningWord word);
}

class SharedPreferencesWordProgressStore implements WordProgressStore {
  SharedPreferencesWordProgressStore();

  static const String _indexKey = 'learning_word_progress_index';
  static const String _entryKeyPrefix = 'learning_word_progress_word_';

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final indexedWordIds = prefs.getStringList(_indexKey) ?? const <String>[];
      return _loadIndexedProgress(prefs, indexedWordIds);
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

    final indexedWordIds = _loadIndexedWordIds(prefs).toSet();

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

  List<String> _loadIndexedWordIds(SharedPreferences prefs) {
    return (prefs.getStringList(_indexKey) ?? const <String>[])
        .map((wordId) => wordId.trim())
        .where((wordId) => wordId.isNotEmpty)
        .toList(growable: false);
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
