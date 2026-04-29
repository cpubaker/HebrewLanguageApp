import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/word_of_day_service.dart';

void main() {
  test('prefers words with contexts', () {
    final entry = const WordOfDayService().select(
      words: const [
        LearningWord(
          wordId: 'word_plain',
          hebrew: 'plain',
          english: 'plain',
          transcription: 'plain',
          correct: 0,
          wrong: 0,
        ),
        LearningWord(
          wordId: 'word_contextual',
          hebrew: 'contextual',
          english: 'contextual',
          transcription: 'contextual',
          correct: 0,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_1',
              hebrew: 'context sentence',
              translation: 'context translation',
            ),
          ],
        ),
      ],
      date: DateTime.utc(2026, 3, 27),
    );

    expect(entry, isNotNull);
    expect(entry!.word.wordId, 'word_contextual');
    expect(entry.context?.contextId, 'ctx_1');
  });

  test('is stable for the same date and moves on the next day', () {
    const service = WordOfDayService();
    final words = const [
      LearningWord(
        wordId: 'word_dog',
        hebrew: 'dog',
        english: 'dog',
        transcription: 'dog',
        correct: 0,
        wrong: 0,
        contexts: [
          LearningContext(contextId: 'ctx_dog', hebrew: 'dog context'),
        ],
      ),
      LearningWord(
        wordId: 'word_house',
        hebrew: 'house',
        english: 'house',
        transcription: 'house',
        correct: 0,
        wrong: 0,
        contexts: [
          LearningContext(contextId: 'ctx_house', hebrew: 'house context'),
        ],
      ),
    ];

    final today = service.select(
      words: words,
      date: DateTime.utc(2026, 3, 27),
    );
    final repeated = service.select(
      words: words,
      date: DateTime.utc(2026, 3, 27),
    );
    final nextDay = service.select(
      words: words,
      date: DateTime.utc(2026, 3, 28),
    );

    expect(today?.word.wordId, repeated?.word.wordId);
    expect(today?.word.wordId, isNot(nextDay?.word.wordId));
  });

  test('rotates context when the same word is selected again', () {
    const service = WordOfDayService();
    final words = const [
      LearningWord(
        wordId: 'word_dog',
        hebrew: 'dog',
        english: 'dog',
        transcription: 'dog',
        correct: 0,
        wrong: 0,
        contexts: [
          LearningContext(contextId: 'ctx_1', hebrew: 'context one'),
          LearningContext(contextId: 'ctx_2', hebrew: 'context two'),
        ],
      ),
    ];

    final today = service.select(
      words: words,
      date: DateTime.utc(2026, 3, 27),
    );
    final nextDay = service.select(
      words: words,
      date: DateTime.utc(2026, 3, 28),
    );

    expect(today?.word.wordId, 'word_dog');
    expect(nextDay?.word.wordId, 'word_dog');
    expect(today?.context?.contextId, isNot(nextDay?.context?.contextId));
  });
}
