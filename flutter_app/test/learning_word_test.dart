import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';

void main() {
  test('fromJson reads writing progress fields when present', () {
    final word = LearningWord.fromJson(<String, Object?>{
      'word_id': 'word_shalom',
      'hebrew': 'שלום',
      'english': 'peace',
      'ukrainian': 'мир',
      'transcription': 'shalom',
      'correct': 2,
      'wrong': 1,
      'last_correct': '2026-04-04T10:00:00Z',
      'writing_correct': 5,
      'writing_wrong': 2,
      'writing_last_correct': '2026-04-04T12:30:00Z',
    });

    expect(word.wordId, 'word_shalom');
    expect(word.translation, 'мир');
    expect(word.writingCorrect, 5);
    expect(word.writingWrong, 2);
    expect(word.writingLastCorrect, '2026-04-04T12:30:00Z');
  });

  test('copyWith keeps and overrides writing progress independently', () {
    const baseWord = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'peace',
      ukrainian: 'мир',
      transcription: 'shalom',
      correct: 2,
      wrong: 1,
      writingCorrect: 3,
      writingWrong: 0,
      writingLastCorrect: '2026-04-04T12:30:00Z',
    );

    final updatedWord = baseWord.copyWith(writingCorrect: 4, writingWrong: 1);

    expect(updatedWord.correct, 2);
    expect(updatedWord.wrong, 1);
    expect(updatedWord.writingCorrect, 4);
    expect(updatedWord.writingWrong, 1);
    expect(updatedWord.writingLastCorrect, '2026-04-04T12:30:00Z');
  });

  test('translation falls back to english when ukrainian is missing', () {
    const word = LearningWord(
      wordId: 'word_shalom',
      hebrew: 'שלום',
      english: 'peace',
      transcription: 'shalom',
      correct: 0,
      wrong: 0,
    );

    expect(word.translation, 'peace');
  });
}
