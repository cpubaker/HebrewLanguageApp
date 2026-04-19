import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/sprint_session.dart';

void main() {
  test('requires at least two distinct translations to start', () {
    final session = SprintSession(const [
      LearningWord(
        wordId: 'word_1',
        hebrew: 'שלום',
        english: 'peace',
        ukrainian: 'мир',
        transcription: 'shalom',
        correct: 0,
        wrong: 0,
      ),
      LearningWord(
        wordId: 'word_2',
        hebrew: 'היי',
        english: 'hi',
        ukrainian: 'мир',
        transcription: 'hey',
        correct: 0,
        wrong: 0,
      ),
    ]);

    expect(session.canStart, isFalse);
    expect(session.nextPrompt(), isNull);
  });

  test(
    'nextPrompt returns two answer options and avoids immediate repeats',
    () {
      final session = SprintSession(const [
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
          hebrew: 'בית',
          english: 'house',
          ukrainian: 'будинок',
          transcription: 'bayit',
          correct: 0,
          wrong: 0,
        ),
        LearningWord(
          wordId: 'word_book',
          hebrew: 'ספר',
          english: 'book',
          ukrainian: 'книга',
          transcription: 'sefer',
          correct: 0,
          wrong: 0,
        ),
      ], rng: Random(1));

      final firstPrompt = session.nextPrompt();
      final secondPrompt = session.nextPrompt();

      expect(firstPrompt, isNotNull);
      expect(firstPrompt!.options, hasLength(2));
      expect(firstPrompt.options, contains(firstPrompt.word.translation));
      expect(secondPrompt, isNotNull);
      expect(secondPrompt!.word.wordId, isNot(firstPrompt.word.wordId));
    },
  );

  test('submitAnswer increments correct answers and stores lastCorrect', () {
    final session = SprintSession(
      const [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'שלום',
          english: 'peace',
          ukrainian: 'мир',
          transcription: 'shalom',
          correct: 2,
          wrong: 1,
        ),
        LearningWord(
          wordId: 'word_house',
          hebrew: 'בית',
          english: 'house',
          ukrainian: 'будинок',
          transcription: 'bayit',
          correct: 0,
          wrong: 0,
        ),
      ],
      rng: Random(2),
      now: () => DateTime.parse('2026-04-19T10:00:00Z'),
    );

    final prompt = session.nextPrompt()!;
    final result = session.submitAnswer(prompt.word.translation);

    expect(result, isNotNull);
    expect(result!.isCorrect, isTrue);
    expect(result.word.correct, prompt.word.correct + 1);
    expect(result.word.lastCorrect, '2026-04-19T10:00:00.000Z');
    expect(session.correctCount, 1);
    expect(session.wrongCount, 0);
  });

  test('submitAnswer increments wrong answers and keeps lastCorrect', () {
    final session = SprintSession(const [
      LearningWord(
        wordId: 'word_peace',
        hebrew: 'שלום',
        english: 'peace',
        ukrainian: 'мир',
        transcription: 'shalom',
        correct: 2,
        wrong: 1,
        lastCorrect: '2026-04-18T08:00:00Z',
      ),
      LearningWord(
        wordId: 'word_house',
        hebrew: 'בית',
        english: 'house',
        ukrainian: 'будинок',
        transcription: 'bayit',
        correct: 0,
        wrong: 0,
      ),
    ], rng: Random(3));

    final prompt = session.nextPrompt()!;
    final wrongAnswer = prompt.options.firstWhere(
      (option) => option != prompt.word.translation,
    );
    final result = session.submitAnswer(wrongAnswer);

    expect(result, isNotNull);
    expect(result!.isCorrect, isFalse);
    expect(result.word.wrong, prompt.word.wrong + 1);
    expect(result.word.lastCorrect, prompt.word.lastCorrect);
    expect(session.correctCount, 0);
    expect(session.wrongCount, 1);
  });
}
