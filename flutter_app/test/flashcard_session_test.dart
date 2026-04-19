import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/flashcard_session.dart';

void main() {
  test('withContexts deck keeps only words that have shared contexts', () {
    final session = FlashcardSession(
      [
        const LearningWord(
          wordId: 'word_man',
          hebrew: 'איש',
          english: 'man',
          transcription: 'ish',
          correct: 0,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_1',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'The man is walking in the street.',
            ),
          ],
        ),
        const LearningWord(
          wordId: 'word_woman',
          hebrew: 'אישה',
          english: 'woman',
          transcription: 'isha',
          correct: 0,
          wrong: 0,
        ),
      ],
      deckMode: FlashcardDeckMode.withContexts,
      rng: Random(1),
    );

    expect(session.wordCount, 1);

    final card = session.nextCard();
    expect(card, isNotNull);
    expect(card!.word.wordId, 'word_man');
  });

  test('needsReview deck keeps only words that have mistakes', () {
    final session = FlashcardSession(
      [
        const LearningWord(
          wordId: 'word_tree',
          hebrew: 'עץ',
          english: 'tree',
          transcription: 'etz',
          correct: 2,
          wrong: 0,
        ),
        const LearningWord(
          wordId: 'word_book',
          hebrew: 'ספר',
          english: 'book',
          transcription: 'sefer',
          correct: 1,
          wrong: 3,
        ),
      ],
      deckMode: FlashcardDeckMode.needsReview,
      rng: Random(2),
    );

    expect(session.wordCount, 1);

    final card = session.nextCard();
    expect(card, isNotNull);
    expect(card!.word.wordId, 'word_book');
  });

  test('seen progress resets when deck mode changes', () {
    final session = FlashcardSession(
      [
        const LearningWord(
          wordId: 'word_man',
          hebrew: 'איש',
          english: 'man',
          transcription: 'ish',
          correct: 0,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_1',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'The man is walking in the street.',
            ),
          ],
        ),
        const LearningWord(
          wordId: 'word_book',
          hebrew: 'ספר',
          english: 'book',
          transcription: 'sefer',
          correct: 0,
          wrong: 2,
        ),
      ],
      rng: Random(3),
    );

    session.nextCard();
    expect(session.seenCount, 1);
    expect(session.wordCount, 2);

    session.setDeckMode(FlashcardDeckMode.needsReview);

    expect(session.seenCount, 0);
    expect(session.answeredCount, 0);
    expect(session.wordCount, 1);
  });

  test('single-word deck completes after one context-backed card', () {
    final session = FlashcardSession(
      [
        const LearningWord(
          wordId: 'word_dog',
          hebrew: 'כלב',
          english: 'dog',
          transcription: 'kelev',
          correct: 0,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_1',
              hebrew: 'הכלב רץ בפארק.',
              translation: 'The dog is running in the park.',
            ),
            LearningContext(
              contextId: 'ctx_2',
              hebrew: 'הכלב ישן ליד הבית.',
              translation: 'The dog is sleeping next to the house.',
            ),
          ],
        ),
      ],
      rng: Random(4),
    );

    final firstCard = session.nextCard();
    final secondCard = session.nextCard();

    expect(firstCard, isNotNull);
    expect(secondCard, isNull);
    expect(firstCard!.context, isNotNull);
    expect(session.seenCount, 1);
    expect(session.sessionProgress, 1);
  });

  test('deck ends after each card has been seen once', () {
    final session = FlashcardSession(
      [
        const LearningWord(
          wordId: 'word_sun',
          hebrew: 'שמש',
          english: 'sun',
          transcription: 'shemesh',
          correct: 0,
          wrong: 0,
        ),
        const LearningWord(
          wordId: 'word_moon',
          hebrew: 'ירח',
          english: 'moon',
          transcription: 'yareakh',
          correct: 0,
          wrong: 0,
        ),
      ],
      rng: Random(5),
    );

    final firstCard = session.nextCard();
    final secondCard = session.nextCard();
    final thirdCard = session.nextCard();

    expect(firstCard, isNotNull);
    expect(secondCard, isNotNull);
    expect(firstCard!.word.wordId, isNot(secondCard!.word.wordId));
    expect(thirdCard, isNull);
    expect(session.seenCount, 2);
    expect(session.sessionProgress, 1);
  });

  test('answerCard stores last review outcome and review timestamp', () {
    final session = FlashcardSession(
      const [
        LearningWord(
          wordId: 'word_book',
          hebrew: 'ЧЎЧ¤ЧЁ',
          english: 'book',
          transcription: 'sefer',
          correct: 0,
          wrong: 0,
        ),
      ],
      rng: Random(7),
      now: () => DateTime.parse('2026-04-19T11:00:00Z'),
    );

    session.nextCard();
    final result = session.answerCard(false);

    expect(result, isNotNull);
    expect(result!.word.lastReviewedAt, '2026-04-19T11:00:00.000Z');
    expect(result.word.lastReviewCorrect, isFalse);
    expect(result.word.lastCorrect, isNull);
  });
}
