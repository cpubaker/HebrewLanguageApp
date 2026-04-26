import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/writing_session.dart';

void main() {
  test('nextPrompt returns ukrainian prompt and avoids immediate repeats', () {
    final session = WritingSession(const [
      LearningWord(
        wordId: 'word_peace',
        hebrew: 'שלום',
        english: 'peace',
        ukrainian: 'мир',
        transcription: 'shalom',
        correct: 0,
        wrong: 0,
      ),
      LearningWord(
        wordId: 'word_house',
        hebrew: 'בַּיִת',
        english: 'house',
        ukrainian: 'будинок',
        transcription: 'bayit',
        correct: 0,
        wrong: 0,
      ),
    ], rng: Random(1));

    final firstPrompt = session.nextPrompt();
    final secondPrompt = session.nextPrompt();

    expect(firstPrompt, isNotNull);
    expect(secondPrompt, isNotNull);
    expect(firstPrompt!.prompt, isNotEmpty);
    expect(secondPrompt!.prompt, isNotEmpty);
    expect(<String>{firstPrompt.prompt, secondPrompt.prompt}, contains('мир'));
    expect(firstPrompt.word.wordId, isNot(secondPrompt.word.wordId));
  });

  test('submitAnswer returns empty for blank input without changing stats', () {
    final session = WritingSession(const [
      LearningWord(
        wordId: 'word_peace',
        hebrew: 'שלום',
        english: 'peace',
        ukrainian: 'мир',
        transcription: 'shalom',
        correct: 0,
        wrong: 0,
      ),
    ], rng: Random(2));
    session.nextPrompt();

    final result = session.submitAnswer('   ');

    expect(result, isNotNull);
    expect(result!.status, WritingAnswerStatus.empty);
    expect(session.currentWordStats().correct, 0);
    expect(session.currentWordStats().wrong, 0);
  });

  test('nextPrompt exposes constructor puzzle with syllable blocks', () {
    final session = WritingSession(const [
      LearningWord(
        wordId: 'word_house',
        hebrew: 'בַּיִת',
        english: 'house',
        ukrainian: 'будинок',
        transcription: 'bayit',
        correct: 0,
        wrong: 0,
      ),
    ], rng: Random(5));

    final prompt = session.nextPrompt();

    expect(prompt, isNotNull);
    expect(prompt!.constructorPuzzle.solution, <String>['בַּ', 'יִת']);
    expect(
      prompt.constructorPuzzle.availableBlocks.map((block) => block.text),
      containsAll(<String>['בַּ', 'יִת']),
    );
  });

  test(
    'constructor puzzle falls back to transcription when word has no niqqud',
    () {
      final session = WritingSession(const [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'שלום',
          english: 'peace',
          ukrainian: 'мир',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
      ], rng: Random(6));

      final prompt = session.nextPrompt();

      expect(prompt, isNotNull);
      expect(prompt!.constructorPuzzle.solution.length, 2);
      expect(prompt.constructorPuzzle.solution.join(), 'שלום');
      expect(
        prompt.constructorPuzzle.availableBlocks.length,
        greaterThan(prompt.constructorPuzzle.solution.length),
      );
    },
  );

  test('submitAnswer updates writing stats and tolerates missing niqqud', () {
    final session = WritingSession(
      const [
        LearningWord(
          wordId: 'word_following',
          hebrew: 'בְּעִקְבוֹת',
          english: 'following',
          ukrainian: 'слідом за; внаслідок, через',
          transcription: 'be\'ikvot',
          correct: 0,
          wrong: 0,
        ),
      ],
      rng: Random(3),
      now: () => DateTime.parse('2026-04-07T10:30:00Z'),
    );
    session.nextPrompt();

    final result = session.submitAnswer('בעקבות');

    expect(result, isNotNull);
    expect(result!.status, WritingAnswerStatus.submitted);
    expect(result.isCorrect, isTrue);
    expect(result.word.writingCorrect, 1);
    expect(result.word.writingWrong, 0);
    expect(result.word.lastReviewedAt, '2026-04-07T10:30:00.000Z');
    expect(result.word.lastReviewCorrect, isTrue);
    expect(result.word.writingLastCorrect, '2026-04-07T10:30:00.000Z');
  });

  test(
    'wrong answers increment writingWrong and keep last correct timestamp',
    () {
      final session = WritingSession(
        const [
          LearningWord(
            wordId: 'word_peace',
            hebrew: 'שלום',
            english: 'peace',
            ukrainian: 'мир',
            transcription: 'shalom',
            correct: 0,
            wrong: 0,
            writingCorrect: 2,
            writingWrong: 1,
            writingLastCorrect: '2026-04-06T08:00:00Z',
          ),
        ],
        rng: Random(4),
        now: () => DateTime.parse('2026-04-19T10:45:00Z'),
      );
      session.nextPrompt();

      final result = session.submitAnswer('בית');

      expect(result, isNotNull);
      expect(result!.isCorrect, isFalse);
      expect(result.word.writingCorrect, 2);
      expect(result.word.writingWrong, 2);
      expect(result.word.lastReviewedAt, '2026-04-19T10:45:00.000Z');
      expect(result.word.lastReviewCorrect, isFalse);
      expect(result.word.writingLastCorrect, '2026-04-06T08:00:00Z');
    },
  );

  test('submitUnknown records a wrong writing answer without user input', () {
    final session = WritingSession(
      const [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'שלום',
          english: 'peace',
          ukrainian: 'мир',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
      ],
      rng: Random(7),
      now: () => DateTime.parse('2026-04-26T09:50:00Z'),
    );
    session.nextPrompt();

    final result = session.submitUnknown();

    expect(result, isNotNull);
    expect(result!.status, WritingAnswerStatus.submitted);
    expect(result.isCorrect, isFalse);
    expect(result.correctAnswer, 'שלום');
    expect(result.word.writingCorrect, 0);
    expect(result.word.writingWrong, 1);
    expect(result.word.lastReviewedAt, '2026-04-26T09:50:00.000Z');
    expect(result.word.lastReviewCorrect, isFalse);
    expect(session.answeredCount, 1);
  });
}
