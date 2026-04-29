import '../models/learning_context.dart';
import '../models/learning_word.dart';

class WordOfDayEntry {
  const WordOfDayEntry({
    required this.word,
    required this.context,
  });

  final LearningWord word;
  final LearningContext? context;
}

class WordOfDayService {
  const WordOfDayService();

  WordOfDayEntry? select({
    required List<LearningWord> words,
    required DateTime date,
  }) {
    if (words.isEmpty) {
      return null;
    }

    final wordsWithContexts = words
        .where((word) => word.contexts.isNotEmpty)
        .toList(growable: false);
    final candidates = wordsWithContexts.isNotEmpty
        ? wordsWithContexts
        : List<LearningWord>.from(words);
    final dayIndex = _daysSinceEpoch(date);
    final word = candidates[dayIndex % candidates.length];
    final context = _selectContext(
      word: word,
      dayIndex: dayIndex,
      wordCount: candidates.length,
    );

    return WordOfDayEntry(word: word, context: context);
  }

  LearningContext? _selectContext({
    required LearningWord word,
    required int dayIndex,
    required int wordCount,
  }) {
    final contexts = word.contexts
        .where(
          (context) =>
              context.hebrew.trim().isNotEmpty ||
              context.translation.trim().isNotEmpty,
        )
        .toList(growable: false);
    if (contexts.isEmpty) {
      return null;
    }

    final contextIndex = (dayIndex ~/ wordCount) % contexts.length;
    return contexts[contextIndex];
  }

  int _daysSinceEpoch(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    return normalizedDate.difference(DateTime.utc(1970)).inDays;
  }
}
