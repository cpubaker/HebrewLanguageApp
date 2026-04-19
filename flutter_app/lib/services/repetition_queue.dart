import '../models/learning_word.dart';

enum RepetitionKind { recentStart, lastMistake }

class RepetitionEntry {
  const RepetitionEntry({
    required this.word,
    required this.kind,
  });

  final LearningWord word;
  final RepetitionKind kind;
}

class RepetitionQueue {
  const RepetitionQueue(this.entries);

  factory RepetitionQueue.fromWords(
    List<LearningWord> words, {
    DateTime Function()? now,
  }) {
    final entries = words
        .map((word) {
          final kind = classifyRepetitionKind(
            word,
            now: now,
          );
          return kind == null ? null : RepetitionEntry(word: word, kind: kind);
        })
        .whereType<RepetitionEntry>()
        .toList(growable: false)
      ..sort(_compareEntries);

    return RepetitionQueue(entries);
  }

  final List<RepetitionEntry> entries;

  bool get isEmpty => entries.isEmpty;
  int get total => entries.length;

  List<RepetitionEntry> entriesFor(RepetitionKind kind) {
    return entries.where((entry) => entry.kind == kind).toList(growable: false);
  }

  int get recentStartCount => entriesFor(RepetitionKind.recentStart).length;
  int get lastMistakeCount => entriesFor(RepetitionKind.lastMistake).length;

  static int _compareEntries(RepetitionEntry left, RepetitionEntry right) {
    final kindComparison = _kindPriority(
      left.kind,
    ).compareTo(_kindPriority(right.kind));
    if (kindComparison != 0) {
      return kindComparison;
    }

    final leftReviewedAt = _parseReviewedAt(left.word.lastReviewedAt);
    final rightReviewedAt = _parseReviewedAt(right.word.lastReviewedAt);
    if (leftReviewedAt != null && rightReviewedAt != null) {
      final reviewedComparison = rightReviewedAt.compareTo(leftReviewedAt);
      if (reviewedComparison != 0) {
        return reviewedComparison;
      }
    } else if (leftReviewedAt != null || rightReviewedAt != null) {
      return leftReviewedAt == null ? 1 : -1;
    }

    return left.word.translation.toLowerCase().compareTo(
      right.word.translation.toLowerCase(),
    );
  }

  static int _kindPriority(RepetitionKind kind) {
    return switch (kind) {
      RepetitionKind.lastMistake => 0,
      RepetitionKind.recentStart => 1,
    };
  }
}

RepetitionKind? classifyRepetitionKind(
  LearningWord word, {
  DateTime Function()? now,
}) {
  if (word.lastReviewCorrect == false) {
    return RepetitionKind.lastMistake;
  }

  if (_looksLikeLegacyLastMistake(word)) {
    return RepetitionKind.lastMistake;
  }

  final totalAttempts =
      word.correct + word.wrong + word.writingCorrect + word.writingWrong;
  if (totalAttempts == 0) {
    return null;
  }

  if (totalAttempts <= 2) {
    return RepetitionKind.recentStart;
  }

  return null;
}

bool _looksLikeLegacyLastMistake(LearningWord word) {
  if (word.lastReviewCorrect != null) {
    return false;
  }

  if (word.wrong == 0) {
    return false;
  }

  return word.lastCorrect == null || word.wrong >= word.correct;
}

DateTime? _parseReviewedAt(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
