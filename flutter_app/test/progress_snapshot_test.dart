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
}
