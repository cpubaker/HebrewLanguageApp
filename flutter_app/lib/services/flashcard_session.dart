import 'dart:math';

import '../models/learning_context.dart';
import '../models/learning_word.dart';

enum FlashcardDeckMode {
  allWords,
  withContexts,
  needsReview,
}

class FlashcardCard {
  const FlashcardCard({
    required this.word,
    required this.context,
  });

  final LearningWord word;
  final LearningContext? context;
}

class FlashcardAnswerResult {
  const FlashcardAnswerResult({
    required this.known,
    required this.word,
    required this.context,
  });

  final bool known;
  final LearningWord word;
  final LearningContext? context;
}

typedef WordProgressCallback = void Function(LearningWord word);

class FlashcardStats {
  const FlashcardStats({
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

class FlashcardSession {
  FlashcardSession(
    List<LearningWord> words, {
    Random? rng,
    this.deckMode = FlashcardDeckMode.allWords,
  })  : _sourceWords = List<LearningWord>.from(words),
        _rng = rng ?? Random() {
    _rebuildDeck();
  }

  final Random _rng;
  final Map<String, String> _lastContextIds = <String, String>{};
  final List<LearningWord> _sourceWords;
  final Set<String> _seenWordIds = <String>{};
  List<LearningWord> _words = <LearningWord>[];

  FlashcardDeckMode deckMode;

  LearningWord? currentWord;
  LearningContext? currentContext;
  bool? lastAnswerKnown;
  int answeredCount = 0;

  int get wordCount => _words.length;
  int get seenCount => _seenWordIds.length;
  double get sessionProgress => wordCount == 0 ? 0 : seenCount / wordCount;

  int get wordsWithContextsCount {
    return _words.where((word) => word.contexts.isNotEmpty).length;
  }

  void setDeckMode(FlashcardDeckMode mode) {
    if (deckMode == mode) {
      return;
    }

    deckMode = mode;
    _rebuildDeck();
  }

  FlashcardCard? nextCard() {
    if (_words.isEmpty) {
      currentWord = null;
      currentContext = null;
      lastAnswerKnown = null;
      return null;
    }

    var candidates = _words;
    if (currentWord != null && _words.length > 1) {
      candidates = _words
          .where((word) => word.wordId != currentWord!.wordId)
          .toList(growable: false);
    }

    currentWord = candidates[_rng.nextInt(candidates.length)];
    currentContext = _selectContext(currentWord!);
    lastAnswerKnown = null;
    _seenWordIds.add(currentWord!.wordId);

    return FlashcardCard(
      word: currentWord!,
      context: currentContext,
    );
  }

  FlashcardAnswerResult? answerCard(bool known) {
    final activeWord = currentWord;
    if (activeWord == null) {
      return null;
    }

    final updatedWord = activeWord.copyWith(
      correct: known ? activeWord.correct + 1 : activeWord.correct,
      wrong: known ? activeWord.wrong : activeWord.wrong + 1,
      lastCorrect: known ? DateTime.now().toIso8601String() : activeWord.lastCorrect,
    );

    final index = _words.indexWhere((word) => word.wordId == activeWord.wordId);
    if (index != -1) {
      _words[index] = updatedWord;
    }

    currentWord = updatedWord;
    lastAnswerKnown = known;
    answeredCount += 1;

    return FlashcardAnswerResult(
      known: known,
      word: updatedWord,
      context: currentContext,
    );
  }

  FlashcardStats currentWordStats() {
    final activeWord = currentWord;
    if (activeWord == null) {
      return const FlashcardStats(
        correct: 0,
        wrong: 0,
        total: 0,
        lastCorrect: null,
      );
    }

    return FlashcardStats(
      correct: activeWord.correct,
      wrong: activeWord.wrong,
      total: activeWord.correct + activeWord.wrong,
      lastCorrect: activeWord.lastCorrect,
    );
  }

  LearningContext? _selectContext(LearningWord word) {
    final contexts = word.contexts;
    if (contexts.isEmpty) {
      return null;
    }

    late final LearningContext context;
    if (contexts.length == 1) {
      context = contexts.first;
    } else {
      final previousContextId = _lastContextIds[word.wordId];
      final candidates = contexts
          .where((entry) => entry.contextId != previousContextId)
          .toList(growable: false);
      final pool = candidates.isEmpty ? contexts : candidates;
      context = pool[_rng.nextInt(pool.length)];
    }

    if (context.contextId.isNotEmpty) {
      _lastContextIds[word.wordId] = context.contextId;
    }

    return context;
  }

  void _rebuildDeck() {
    _words = _buildDeck(_sourceWords, deckMode);
    currentWord = null;
    currentContext = null;
    lastAnswerKnown = null;
    answeredCount = 0;
    _lastContextIds.clear();
    _seenWordIds.clear();
  }

  List<LearningWord> _buildDeck(
    List<LearningWord> words,
    FlashcardDeckMode mode,
  ) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return List<LearningWord>.from(words);
      case FlashcardDeckMode.withContexts:
        return words
            .where((word) => word.contexts.isNotEmpty)
            .toList(growable: false);
      case FlashcardDeckMode.needsReview:
        final reviewWords = words
            .where((word) => word.wrong > 0 || word.wrong > word.correct)
            .toList(growable: false);
        return reviewWords;
    }
  }
}
