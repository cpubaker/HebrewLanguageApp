import 'dart:math';

import '../models/learning_word.dart';

class SprintPrompt {
  const SprintPrompt({required this.word, required this.options});

  final LearningWord word;
  final List<String> options;
}

class SprintAnswerResult {
  const SprintAnswerResult({
    required this.isCorrect,
    required this.selectedTranslation,
    required this.correctTranslation,
    required this.word,
  });

  final bool isCorrect;
  final String selectedTranslation;
  final String correctTranslation;
  final LearningWord word;
}

class SprintSession {
  SprintSession(
    List<LearningWord> words, {
    Random? rng,
    DateTime Function()? now,
  }) : _words = List<LearningWord>.from(words),
       _rng = rng ?? Random(),
       _now = now ?? DateTime.now;

  final List<LearningWord> _words;
  final Random _rng;
  final DateTime Function() _now;

  LearningWord? currentWord;
  List<String> currentOptions = const <String>[];
  int correctCount = 0;
  int wrongCount = 0;

  bool get canStart {
    final eligibleWords = _eligibleWords;
    if (eligibleWords.length < 2) {
      return false;
    }

    final uniqueTranslations = eligibleWords
        .map((word) => word.translation.trim())
        .where((translation) => translation.isNotEmpty)
        .toSet();
    return uniqueTranslations.length >= 2;
  }

  int get attempts => correctCount + wrongCount;

  SprintPrompt? nextPrompt() {
    final eligibleWords = _eligibleWords;
    if (eligibleWords.length < 2) {
      currentWord = null;
      currentOptions = const <String>[];
      return null;
    }

    final candidates = currentWord != null && eligibleWords.length > 1
        ? eligibleWords
              .where((word) => !_isSameWord(word, currentWord!))
              .toList(growable: false)
        : eligibleWords;

    final nextWord = candidates[_rng.nextInt(candidates.length)];
    final correctTranslation = nextWord.translation.trim();
    final distractors = eligibleWords
        .where(
          (word) =>
              !_isSameWord(word, nextWord) &&
              word.translation.trim() != correctTranslation,
        )
        .map((word) => word.translation.trim())
        .toList(growable: false);

    if (distractors.isEmpty) {
      currentWord = null;
      currentOptions = const <String>[];
      return null;
    }

    final options = <String>[
      correctTranslation,
      distractors[_rng.nextInt(distractors.length)],
    ]..shuffle(_rng);

    currentWord = nextWord;
    currentOptions = List<String>.unmodifiable(options);

    return SprintPrompt(word: nextWord, options: currentOptions);
  }

  SprintAnswerResult? submitAnswer(String selectedTranslation) {
    final activeWord = currentWord;
    if (activeWord == null) {
      return null;
    }

    final correctTranslation = activeWord.translation.trim();
    final isCorrect = selectedTranslation == correctTranslation;
    final updatedWord = activeWord.copyWith(
      correct: isCorrect ? activeWord.correct + 1 : activeWord.correct,
      wrong: isCorrect ? activeWord.wrong : activeWord.wrong + 1,
      lastCorrect: isCorrect
          ? _now().toIso8601String()
          : activeWord.lastCorrect,
    );

    _replaceWord(updatedWord);
    currentWord = updatedWord;

    if (isCorrect) {
      correctCount += 1;
    } else {
      wrongCount += 1;
    }

    return SprintAnswerResult(
      isCorrect: isCorrect,
      selectedTranslation: selectedTranslation,
      correctTranslation: correctTranslation,
      word: updatedWord,
    );
  }

  List<LearningWord> get _eligibleWords => _words
      .where((word) => word.translation.trim().isNotEmpty)
      .toList(growable: false);

  bool _isSameWord(LearningWord left, LearningWord right) {
    if (left.wordId.trim().isNotEmpty && right.wordId.trim().isNotEmpty) {
      return left.wordId == right.wordId;
    }

    return identical(left, right);
  }

  void _replaceWord(LearningWord updatedWord) {
    final index = _words.indexWhere(
      (word) => word.wordId == updatedWord.wordId,
    );
    if (index >= 0) {
      _words[index] = updatedWord;
    }
  }
}
