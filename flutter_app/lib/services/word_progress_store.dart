import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_word.dart';

class StoredWordProgress {
  const StoredWordProgress({
    required this.wordId,
    required this.correct,
    required this.wrong,
    required this.lastCorrect,
  });

  factory StoredWordProgress.fromJson(String wordId, Map<String, dynamic> json) {
    return StoredWordProgress(
      wordId: wordId,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      lastCorrect: json['last_correct'] as String?,
    );
  }

  final String wordId;
  final int correct;
  final int wrong;
  final String? lastCorrect;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'correct': correct,
      'wrong': wrong,
      if (lastCorrect != null && lastCorrect!.trim().isNotEmpty)
        'last_correct': lastCorrect,
    };
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
    final prefs = await SharedPreferences.getInstance();
    return _loadFromPrefs(prefs);
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    final prefs = await SharedPreferences.getInstance();
    final currentMap = await _loadRawMap(prefs);

    final hasProgress =
        word.correct > 0 || word.wrong > 0 || (word.lastCorrect?.trim().isNotEmpty ?? false);

    if (hasProgress) {
      currentMap[word.wordId] = StoredWordProgress(
        wordId: word.wordId,
        correct: word.correct,
        wrong: word.wrong,
        lastCorrect: word.lastCorrect,
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

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    return decoded;
  }

  Future<Map<String, StoredWordProgress>> _loadFromPrefs(SharedPreferences prefs) async {
    final rawMap = await _loadRawMap(prefs);
    return rawMap.map(
      (wordId, value) => MapEntry(
        wordId,
        StoredWordProgress.fromJson(
          wordId,
          (value as Map).cast<String, dynamic>(),
        ),
      ),
    );
  }
}
