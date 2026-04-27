import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/progress_snapshot.dart';

void main() {
  test('classifies explicit review decisions without answer counters', () {
    const knownWord = LearningWord(
      wordId: 'word_known',
      hebrew: 'שלום',
      english: 'peace',
      transcription: 'shalom',
      correct: 0,
      wrong: 0,
      lastReviewCorrect: true,
    );
    const learningWord = LearningWord(
      wordId: 'word_learning',
      hebrew: 'איש',
      english: 'man',
      transcription: 'ish',
      correct: 0,
      wrong: 0,
      lastReviewCorrect: false,
    );

    expect(classifyWordLearningState(knownWord), WordLearningState.known);
    expect(
      classifyWordLearningState(learningWord),
      WordLearningState.needsReview,
    );
  });

  test('counts study streak from reviewed and writing activity dates', () {
    const words = [
      LearningWord(
        wordId: 'word_today',
        hebrew: 'שלום',
        english: 'peace',
        transcription: 'shalom',
        correct: 1,
        wrong: 0,
        lastReviewedAt: '2026-04-19T08:15:00Z',
      ),
      LearningWord(
        wordId: 'word_yesterday',
        hebrew: 'בית',
        english: 'house',
        transcription: 'bayit',
        correct: 1,
        wrong: 0,
        writingLastCorrect: '2026-04-18T17:30:00Z',
      ),
      LearningWord(
        wordId: 'word_before_yesterday',
        hebrew: 'איש',
        english: 'man',
        transcription: 'ish',
        correct: 1,
        wrong: 0,
        lastCorrect: '2026-04-17T10:00:00Z',
      ),
      LearningWord(
        wordId: 'word_old',
        hebrew: 'אישה',
        english: 'woman',
        transcription: 'isha',
        correct: 1,
        wrong: 0,
        lastReviewedAt: '2026-04-12T10:00:00Z',
      ),
    ];

    final streak = StudyStreakSnapshot.fromWords(
      words,
      now: () => DateTime.parse('2026-04-19T20:00:00Z'),
    );

    expect(streak.currentDays, 3);
    expect(streak.activityDays, 4);
    expect(streak.wasActiveToday, isTrue);
    expect(streak.wasActiveYesterday, isTrue);
    expect(streak.hasActivity, isTrue);
  });

  test('keeps yesterday streak alive until the next missed day', () {
    const words = [
      LearningWord(
        wordId: 'word_yesterday',
        hebrew: 'בית',
        english: 'house',
        transcription: 'bayit',
        correct: 1,
        wrong: 0,
        lastReviewedAt: '2026-04-18T17:30:00Z',
      ),
      LearningWord(
        wordId: 'word_before_yesterday',
        hebrew: 'איש',
        english: 'man',
        transcription: 'ish',
        correct: 1,
        wrong: 0,
        lastReviewedAt: '2026-04-17T10:00:00Z',
      ),
    ];

    final streak = StudyStreakSnapshot.fromWords(
      words,
      now: () => DateTime.parse('2026-04-19T20:00:00Z'),
    );

    expect(streak.currentDays, 2);
    expect(streak.wasActiveToday, isFalse);
    expect(streak.wasActiveYesterday, isTrue);
  });

  test('resets current study streak after a missed day', () {
    const words = [
      LearningWord(
        wordId: 'word_old',
        hebrew: 'בית',
        english: 'house',
        transcription: 'bayit',
        correct: 1,
        wrong: 0,
        lastReviewedAt: '2026-04-16T17:30:00Z',
      ),
    ];

    final streak = StudyStreakSnapshot.fromWords(
      words,
      now: () => DateTime.parse('2026-04-19T20:00:00Z'),
    );

    expect(streak.currentDays, 0);
    expect(streak.activityDays, 1);
    expect(streak.wasActiveToday, isFalse);
    expect(streak.wasActiveYesterday, isFalse);
  });
}
