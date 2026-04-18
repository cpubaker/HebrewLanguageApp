import 'dart:math';

import '../models/learning_word.dart';

class ConstructorBlock {
  const ConstructorBlock({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  final String id;
  final String text;
  final bool isCorrect;
}

class ConstructorPuzzle {
  const ConstructorPuzzle({
    required this.solution,
    required this.availableBlocks,
  });

  final List<String> solution;
  final List<ConstructorBlock> availableBlocks;
}

class WritingPrompt {
  const WritingPrompt({
    required this.word,
    required this.prompt,
    required this.constructorPuzzle,
  });

  final LearningWord word;
  final String prompt;
  final ConstructorPuzzle constructorPuzzle;
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

    return WritingPrompt(
      word: currentWord!,
      prompt: currentWord!.translation,
      constructorPuzzle: _buildConstructorPuzzle(currentWord!),
    );
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

  ConstructorPuzzle _buildConstructorPuzzle(LearningWord word) {
    final solution = _splitWordIntoBlocks(word);
    final distractorCount = solution.length <= 1 ? 1 : min(2, solution.length);
    final distractors = _buildDistractors(
      word: word,
      solution: solution,
      count: distractorCount,
    );

    final blocks = <ConstructorBlock>[
      for (var index = 0; index < solution.length; index += 1)
        ConstructorBlock(
          id: 'solution_${word.wordId}_$index',
          text: solution[index],
          isCorrect: true,
        ),
      for (var index = 0; index < distractors.length; index += 1)
        ConstructorBlock(
          id: 'distractor_${word.wordId}_$index',
          text: distractors[index],
          isCorrect: false,
        ),
    ]..shuffle(_rng);

    return ConstructorPuzzle(solution: solution, availableBlocks: blocks);
  }

  List<String> _buildDistractors({
    required LearningWord word,
    required List<String> solution,
    required int count,
  }) {
    final distractors = <String>[];
    final seen = <String>{...solution};

    for (final candidate in _words) {
      if (candidate.wordId == word.wordId) {
        continue;
      }

      for (final block in _splitWordIntoBlocks(candidate)) {
        if (!seen.add(block)) {
          continue;
        }

        distractors.add(block);
        if (distractors.length >= count) {
          return distractors;
        }
      }
    }

    final fallbackCandidates = _buildFallbackDistractors(word.hebrew, solution)
      ..shuffle(_rng);

    for (final candidate in fallbackCandidates) {
      if (!seen.add(candidate)) {
        continue;
      }

      distractors.add(candidate);
      if (distractors.length >= count) {
        break;
      }
    }

    return distractors;
  }

  List<String> _buildFallbackDistractors(
    String hebrew,
    List<String> solution,
  ) {
    final clusters = _splitIntoClusters(hebrew);
    final candidates = <String>{};
    final maxChunkLength = min(2, clusters.length);

    for (var chunkLength = 1; chunkLength <= maxChunkLength; chunkLength += 1) {
      for (
        var start = 0;
        start <= clusters.length - chunkLength;
        start += 1
      ) {
        final candidate = clusters.sublist(start, start + chunkLength).join();
        if (candidate == hebrew || solution.contains(candidate)) {
          continue;
        }

        candidates.add(candidate);
      }
    }

    return candidates.toList(growable: false);
  }

  List<String> _splitWordIntoBlocks(LearningWord word) {
    final clusters = _splitIntoClusters(word.hebrew);
    if (clusters.length <= 1) {
      return <String>[word.hebrew];
    }

    final desiredCount = min(
      clusters.length,
      max(1, _estimateSyllableCount(word.transcription)),
    );
    final niqqudBlocks = _splitUsingNiqqud(clusters);

    if (niqqudBlocks.length > 1) {
      if (niqqudBlocks.length <= desiredCount) {
        return niqqudBlocks;
      }

      return _mergeBlocksToCount(niqqudBlocks, desiredCount);
    }

    return _splitByDistribution(clusters, desiredCount);
  }

  int _estimateSyllableCount(String transcription) {
    final normalized = transcription.toLowerCase().replaceAll(
      RegExp(r"[^a-z']"),
      '',
    );
    final matches = RegExp(r'[aeiou]+').allMatches(normalized);
    return matches.isEmpty ? 1 : matches.length;
  }

  List<String> _splitUsingNiqqud(List<String> clusters) {
    final vowelIndexes = <int>[];

    for (var index = 0; index < clusters.length; index += 1) {
      if (_hasNiqqudVowel(clusters[index])) {
        vowelIndexes.add(index);
      }
    }

    if (vowelIndexes.length <= 1) {
      return const <String>[];
    }

    final blocks = <String>[];
    for (var index = 0; index < vowelIndexes.length; index += 1) {
      final start = index == 0 ? 0 : vowelIndexes[index];
      final end = index == vowelIndexes.length - 1
          ? clusters.length
          : vowelIndexes[index + 1];
      blocks.add(clusters.sublist(start, end).join());
    }

    return blocks;
  }

  bool _hasNiqqudVowel(String cluster) {
    return RegExp(r'[\u05B0-\u05BB\u05C7]').hasMatch(cluster);
  }

  List<String> _mergeBlocksToCount(List<String> blocks, int desiredCount) {
    final merged = List<String>.from(blocks);

    while (merged.length > desiredCount) {
      var shortestIndex = 0;
      for (var index = 1; index < merged.length; index += 1) {
        if (merged[index].length < merged[shortestIndex].length) {
          shortestIndex = index;
        }
      }

      if (shortestIndex == merged.length - 1) {
        merged[shortestIndex - 1] += merged.removeAt(shortestIndex);
      } else {
        merged[shortestIndex] += merged.removeAt(shortestIndex + 1);
      }
    }

    return merged;
  }

  List<String> _splitByDistribution(List<String> clusters, int desiredCount) {
    if (desiredCount <= 1) {
      return <String>[clusters.join()];
    }

    final blocks = <String>[];
    final baseSize = clusters.length ~/ desiredCount;
    final remainder = clusters.length % desiredCount;
    var start = 0;

    for (var index = 0; index < desiredCount; index += 1) {
      final shouldTakeExtra = index >= desiredCount - remainder;
      final size = baseSize + (shouldTakeExtra ? 1 : 0);
      final end = start + size;
      blocks.add(clusters.sublist(start, end).join());
      start = end;
    }

    return blocks;
  }

  List<String> _splitIntoClusters(String text) {
    final clusters = <String>[];

    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      final isHebrewMark = rune >= 0x0591 && rune <= 0x05C7;

      if (isHebrewMark && clusters.isNotEmpty) {
        clusters[clusters.length - 1] += character;
        continue;
      }

      clusters.add(character);
    }

    return clusters;
  }
}
