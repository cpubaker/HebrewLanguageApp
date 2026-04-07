import 'dart:math';

import '../models/learning_word.dart';

class WritingPrompt {
  const WritingPrompt({required this.word, required this.prompt});

  final LearningWord word;
  final String prompt;
}

class WritingAnswerResult {
  const WritingAnswerResult._({
    required this.status,
    required this.word,
    this.isCorrect,
    this.correctAnswer,
  });

  const WritingAnswerResult.empty({required LearningWord word})
    : this._(status: WritingAnswerStatus.empty, word: word);

  const WritingAnswerResult.submitted({
    required bool isCorrect,
    required LearningWord word,
    required String correctAnswer,
  }) : this._(
         status: WritingAnswerStatus.submitted,
         word: word,
         isCorrect: isCorrect,
         correctAnswer: correctAnswer,
       );

  final WritingAnswerStatus status;
  final LearningWord word;
  final bool? isCorrect;
  final String? correctAnswer;
}

enum WritingAnswerStatus { empty, submitted }

class WritingStats {
  const WritingStats({
    required this.correct,
    required this.wrong,
    required this.total,
    required this.lastCorrect,
  });

  final int correct;
  final int wrong;
  final int total;
  final String? lastCorrect;
}

class WritingSession {
  WritingSession(
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
  bool answered = false;
  int answeredCount = 0;

  int get wordCount => _words.length;

  WritingPrompt? nextPrompt() {
    if (_words.isEmpty) {
      currentWord = null;
      answered = false;
      return null;
    }

    var candidates = _words;
    if (currentWord != null && _words.length > 1) {
      candidates = _words
          .where((word) => word.wordId != currentWord!.wordId)
          .toList(growable: false);
    }

    currentWord = candidates[_rng.nextInt(candidates.length)];
    answered = false;

    return WritingPrompt(word: currentWord!, prompt: currentWord!.translation);
  }

  WritingAnswerResult? submitAnswer(String userAnswer) {
    final activeWord = currentWord;
    if (answered || activeWord == null) {
      return null;
    }

    final normalizedAnswer = _normalizeHebrew(userAnswer);
    final correctAnswer = _normalizeHebrew(activeWord.hebrew);

    if (normalizedAnswer.isEmpty) {
      return WritingAnswerResult.empty(word: activeWord);
    }

    answered = true;
    final isCorrect = normalizedAnswer == correctAnswer;
    answeredCount += 1;

    final updatedWord = activeWord.copyWith(
      writingCorrect: isCorrect
          ? activeWord.writingCorrect + 1
          : activeWord.writingCorrect,
      writingWrong: isCorrect
          ? activeWord.writingWrong
          : activeWord.writingWrong + 1,
      writingLastCorrect: isCorrect
          ? _now().toIso8601String()
          : activeWord.writingLastCorrect,
    );

    final index = _words.indexWhere((word) => word.wordId == activeWord.wordId);
    if (index != -1) {
      _words[index] = updatedWord;
    }

    currentWord = updatedWord;

    return WritingAnswerResult.submitted(
      isCorrect: isCorrect,
      word: updatedWord,
      correctAnswer: activeWord.hebrew,
    );
  }

  WritingStats currentWordStats() {
    final activeWord = currentWord;
    if (activeWord == null) {
      return const WritingStats(
        correct: 0,
        wrong: 0,
        total: 0,
        lastCorrect: null,
      );
    }

    return WritingStats(
      correct: activeWord.writingCorrect,
      wrong: activeWord.writingWrong,
      total: activeWord.writingCorrect + activeWord.writingWrong,
      lastCorrect: activeWord.writingLastCorrect,
    );
  }

  String _normalizeHebrew(String text) {
    return text
        .replaceAll(RegExp(r'[\u0591-\u05C7]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
