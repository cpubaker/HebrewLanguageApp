import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/progress_snapshot.dart';
import 'package:hebrew_language_flutter/services/word_learning_status_update.dart';

void main() {
  test('cycles word learning states in the dictionary order', () {
    expect(
      nextWordLearningState(WordLearningState.unseen),
      WordLearningState.needsReview,
    );
    expect(
      nextWordLearningState(WordLearningState.needsReview),
      WordLearningState.known,
    );
    expect(
      nextWordLearningState(WordLearningState.known),
      WordLearningState.unseen,
    );
  });

  test('marks a word as needing review with review metadata', () {
    final reviewedAt = DateTime.utc(2026, 5, 5, 12);
    final updated = applyWordLearningState(
      _word(correct: 3, wrong: 1),
      WordLearningState.needsReview,
      reviewedAt: reviewedAt,
    );

    expect(updated.correct, 0);
    expect(updated.wrong, 0);
    expect(updated.lastReviewedAt, reviewedAt.toIso8601String());
    expect(updated.lastReviewCorrect, isFalse);
  });

  test('marks a word as known with correct review metadata', () {
    final reviewedAt = DateTime.utc(2026, 5, 5, 13);
    final updated = applyWordLearningState(
      _word(wrong: 2),
      WordLearningState.known,
      reviewedAt: reviewedAt,
    );

    expect(updated.correct, 0);
    expect(updated.wrong, 0);
    expect(updated.lastCorrect, reviewedAt.toIso8601String());
    expect(updated.lastReviewedAt, reviewedAt.toIso8601String());
    expect(updated.lastReviewCorrect, isTrue);
  });

  test(
    'resets a word to unseen while preserving static and writing fields',
    () {
      const context = LearningContext(
        contextId: 'context_hello',
        hebrew: 'שלום',
        translation: 'hello',
        source: LearningContextSource.curated,
      );
      final updated = applyWordLearningState(
        _word(
          correct: 4,
          wrong: 1,
          lastCorrect: 'old-correct',
          lastReviewedAt: 'old-reviewed',
          lastReviewCorrect: true,
          writingCorrect: 2,
          writingWrong: 1,
          writingLastCorrect: 'writing-time',
          contexts: const [context],
        ),
        WordLearningState.unseen,
      );

      expect(updated.wordId, 'word_test');
      expect(updated.hebrew, 'שלום');
      expect(updated.english, 'hello');
      expect(updated.ukrainian, 'привіт');
      expect(updated.transcription, 'shalom');
      expect(updated.audioAssetPath, 'audio.mp3');
      expect(updated.correct, 0);
      expect(updated.wrong, 0);
      expect(updated.lastCorrect, isNull);
      expect(updated.lastReviewedAt, isNull);
      expect(updated.lastReviewCorrect, isNull);
      expect(updated.writingCorrect, 2);
      expect(updated.writingWrong, 1);
      expect(updated.writingLastCorrect, 'writing-time');
      expect(updated.contexts, const [context]);
    },
  );
}

LearningWord _word({
  int correct = 0,
  int wrong = 0,
  String? lastCorrect,
  String? lastReviewedAt,
  bool? lastReviewCorrect,
  int writingCorrect = 0,
  int writingWrong = 0,
  String? writingLastCorrect,
  List<LearningContext> contexts = const <LearningContext>[],
}) {
  return LearningWord(
    wordId: 'word_test',
    hebrew: 'שלום',
    english: 'hello',
    ukrainian: 'привіт',
    transcription: 'shalom',
    audioAssetPath: 'audio.mp3',
    correct: correct,
    wrong: wrong,
    lastCorrect: lastCorrect,
    lastReviewedAt: lastReviewedAt,
    lastReviewCorrect: lastReviewCorrect,
    writingCorrect: writingCorrect,
    writingWrong: writingWrong,
    writingLastCorrect: writingLastCorrect,
    contexts: contexts,
  );
}
