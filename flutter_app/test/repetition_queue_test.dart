import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/repetition_queue.dart';

void main() {
  test('prioritizes words with the last mistake', () {
    final queue = RepetitionQueue.fromWords(const [
      LearningWord(
        wordId: 'word_book',
        hebrew: 'ЧЎЧ¤ЧЁ',
        english: 'book',
        transcription: 'sefer',
        correct: 1,
        wrong: 2,
        lastCorrect: '2026-04-18T08:00:00Z',
        lastReviewedAt: '2026-04-19T09:30:00Z',
        lastReviewCorrect: false,
      ),
      LearningWord(
        wordId: 'word_house',
        hebrew: 'Ч‘Ч™ЧЄ',
        english: 'house',
        transcription: 'bayit',
        correct: 1,
        wrong: 0,
        lastCorrect: '2026-04-19T08:00:00Z',
        lastReviewedAt: '2026-04-19T08:00:00Z',
        lastReviewCorrect: true,
      ),
    ]);

    expect(queue.total, 2);
    expect(queue.entries.first.word.wordId, 'word_book');
    expect(queue.entries.first.kind, RepetitionKind.lastMistake);
    expect(queue.entries.last.kind, RepetitionKind.recentStart);
  });

  test('keeps only started words and ignores untouched ones', () {
    final queue = RepetitionQueue.fromWords(const [
      LearningWord(
        wordId: 'word_peace',
        hebrew: 'Ч©ЧњЧ•Чќ',
        english: 'peace',
        transcription: 'shalom',
        correct: 0,
        wrong: 0,
      ),
      LearningWord(
        wordId: 'word_light',
        hebrew: 'ЧђЧ•ЧЁ',
        english: 'light',
        transcription: 'or',
        correct: 1,
        wrong: 0,
        lastCorrect: '2026-04-19T07:00:00Z',
        lastReviewedAt: '2026-04-19T07:00:00Z',
        lastReviewCorrect: true,
      ),
    ]);

    expect(queue.total, 1);
    expect(queue.entries.single.word.wordId, 'word_light');
    expect(queue.entries.single.kind, RepetitionKind.recentStart);
  });

  test('falls back to legacy mistake-heavy progress when last result is missing', () {
    final queue = RepetitionQueue.fromWords(const [
      LearningWord(
        wordId: 'word_city',
        hebrew: 'ЧўЧ™ЧЁ',
        english: 'city',
        transcription: 'ir',
        correct: 1,
        wrong: 3,
        lastReviewedAt: '2026-04-17T10:00:00Z',
      ),
    ]);

    expect(queue.total, 1);
    expect(queue.entries.single.kind, RepetitionKind.lastMistake);
  });
}
