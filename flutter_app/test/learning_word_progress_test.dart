import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/learning_word_progress.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  test('copies progress fields from an active word onto a loaded word', () {
    const activeWord = LearningWord(
      wordId: 'word_active',
      hebrew: 'active',
      english: 'active',
      transcription: 'active',
      correct: 7,
      wrong: 2,
      lastCorrect: '2026-04-01T08:00:00Z',
      lastReviewedAt: '2026-04-02T09:00:00Z',
      lastReviewCorrect: false,
      writingCorrect: 3,
      writingWrong: 1,
      writingLastCorrect: '2026-04-03T10:00:00Z',
    );
    const loadedWord = LearningWord(
      wordId: 'word_loaded',
      hebrew: 'loaded',
      english: 'loaded',
      transcription: 'loaded',
      correct: 0,
      wrong: 0,
    );

    final hydratedWord = LearningWordProgress.fromWord(
      activeWord,
    ).applyTo(loadedWord);

    expect(hydratedWord.wordId, 'word_loaded');
    expect(hydratedWord.correct, 7);
    expect(hydratedWord.wrong, 2);
    expect(hydratedWord.lastCorrect, '2026-04-01T08:00:00Z');
    expect(hydratedWord.lastReviewedAt, '2026-04-02T09:00:00Z');
    expect(hydratedWord.lastReviewCorrect, isFalse);
    expect(hydratedWord.writingCorrect, 3);
    expect(hydratedWord.writingWrong, 1);
    expect(hydratedWord.writingLastCorrect, '2026-04-03T10:00:00Z');
  });

  test('copies progress fields from stored progress onto a word', () {
    const storedProgress = StoredWordProgress(
      wordId: 'word_stored',
      correct: 5,
      wrong: 4,
      lastCorrect: '2026-04-04T08:00:00Z',
      lastReviewedAt: '2026-04-05T09:00:00Z',
      lastReviewCorrect: true,
      writingCorrect: 6,
      writingWrong: 2,
      writingLastCorrect: '2026-04-06T10:00:00Z',
    );
    const word = LearningWord(
      wordId: 'word_target',
      hebrew: 'target',
      english: 'target',
      transcription: 'target',
      correct: 0,
      wrong: 0,
    );

    final hydratedWord = LearningWordProgress.fromStored(
      storedProgress,
    ).applyTo(word);

    expect(hydratedWord.wordId, 'word_target');
    expect(hydratedWord.correct, 5);
    expect(hydratedWord.wrong, 4);
    expect(hydratedWord.lastCorrect, '2026-04-04T08:00:00Z');
    expect(hydratedWord.lastReviewedAt, '2026-04-05T09:00:00Z');
    expect(hydratedWord.lastReviewCorrect, isTrue);
    expect(hydratedWord.writingCorrect, 6);
    expect(hydratedWord.writingWrong, 2);
    expect(hydratedWord.writingLastCorrect, '2026-04-06T10:00:00Z');
  });
}
