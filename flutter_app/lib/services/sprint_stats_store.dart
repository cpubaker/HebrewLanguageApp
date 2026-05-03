import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SprintStats {
  const SprintStats({
    required this.sessions,
    required this.bestCorrect,
    required this.totalCorrect,
  });

  const SprintStats.empty() : sessions = 0, bestCorrect = 0, totalCorrect = 0;

  factory SprintStats.fromJson(Map<String, dynamic> json) {
    final sessions = _readNonNegativeInt(json['sessions']);
    if (sessions == 0) {
      return const SprintStats.empty();
    }

    final bestCorrect = _readNonNegativeInt(json['best_correct']);
    final totalCorrect = max(
      _readNonNegativeInt(json['total_correct']),
      bestCorrect,
    );

    return SprintStats(
      sessions: sessions,
      bestCorrect: bestCorrect,
      totalCorrect: totalCorrect,
    );
  }

  final int sessions;
  final int bestCorrect;
  final int totalCorrect;

  bool get hasResults => sessions > 0;

  double get averageCorrect => hasResults ? totalCorrect / sessions : 0;

  SprintStats recordScore(int correctCount) {
    final normalizedScore = max(0, correctCount);
    return SprintStats(
      sessions: sessions + 1,
      bestCorrect: max(bestCorrect, normalizedScore),
      totalCorrect: totalCorrect + normalizedScore,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessions': sessions,
      'best_correct': bestCorrect,
      'total_correct': totalCorrect,
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
}

abstract class SprintStatsStore {
  Future<SprintStats> load();

  Future<void> save(SprintStats stats);
}

class SharedPreferencesSprintStatsStore implements SprintStatsStore {
  const SharedPreferencesSprintStatsStore();

  static const String _storageKey = 'sprint_stats';

  @override
  Future<SprintStats> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawStats = prefs.getString(_storageKey);
      if (rawStats == null || rawStats.trim().isEmpty) {
        return const SprintStats.empty();
      }

      final decodedStats = jsonDecode(rawStats);
      if (decodedStats is! Map) {
        return const SprintStats.empty();
      }

      return SprintStats.fromJson(
        decodedStats.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (error) {
      debugPrint(
        'Ignoring sprint stats for $_storageKey because it could not be loaded: $error',
      );
      return const SprintStats.empty();
    }
  }

  @override
  Future<void> save(SprintStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(stats.toJson()));
  }
}
