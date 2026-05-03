import 'dart:math';

import '../models/learning_word.dart';
import 'progress_snapshot.dart';

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
       _now = now ?? DateTime.now {
    _words.removeWhere((word) => !isSprintLearningWord(word));
  }

  final List<LearningWord> _words;
  final Random _rng;
  final DateTime Function() _now;
  final Set<String> _seenWordKeys = <String>{};

  LearningWord? currentWord;
  List<String> currentOptions = const <String>[];
  int correctCount = 0;
  int wrongCount = 0;

  int get availableWordCount => _eligibleWords.length;

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

    final candidates = eligibleWords
        .where((word) => !_seenWordKeys.contains(_wordKey(word)))
        .toList(growable: false);

    if (candidates.isEmpty) {
      currentWord = null;
      currentOptions = const <String>[];
      return null;
    }

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
    _seenWordKeys.add(_wordKey(nextWord));

    return SprintPrompt(word: nextWord, options: currentOptions);
  }

  SprintAnswerResult? submitAnswer(String selectedTranslation) {
    final activeWord = currentWord;
    if (activeWord == null) {
      return null;
    }

    final correctTranslation = activeWord.translation.trim();
    final isCorrect = selectedTranslation == correctTranslation;
    final reviewedAt = _now().toIso8601String();
    final updatedWord = activeWord.copyWith(
      correct: isCorrect ? activeWord.correct + 1 : activeWord.correct,
      wrong: isCorrect ? activeWord.wrong : activeWord.wrong + 1,
      lastCorrect: isCorrect ? reviewedAt : activeWord.lastCorrect,
      lastReviewedAt: reviewedAt,
      lastReviewCorrect: isCorrect,
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

  String _wordKey(LearningWord word) {
    final wordId = word.wordId.trim();
    if (wordId.isNotEmpty) {
      return 'id:$wordId';
    }

    return 'object:${identityHashCode(word)}';
  }
}

bool isSprintLearningWord(LearningWord word) {
  return classifyWordLearningState(word) != WordLearningState.known;
}
