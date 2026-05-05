import '../models/learning_word.dart';
import 'progress_snapshot.dart';

WordLearningState nextWordLearningState(WordLearningState state) {
  return switch (state) {
    WordLearningState.unseen => WordLearningState.needsReview,
    WordLearningState.needsReview => WordLearningState.known,
    WordLearningState.known => WordLearningState.unseen,
  };
}

LearningWord applyWordLearningState(
  LearningWord word,
  WordLearningState targetState, {
  DateTime? reviewedAt,
}) {
  final reviewedAtValue = (reviewedAt ?? DateTime.now()).toIso8601String();

  switch (targetState) {
    case WordLearningState.known:
      return word.copyWith(
        correct: 0,
        wrong: 0,
        lastCorrect: reviewedAtValue,
        lastReviewedAt: reviewedAtValue,
        lastReviewCorrect: true,
      );
    case WordLearningState.needsReview:
      return word.copyWith(
        correct: 0,
        wrong: 0,
        lastReviewedAt: reviewedAtValue,
        lastReviewCorrect: false,
      );
    case WordLearningState.unseen:
      return LearningWord(
        wordId: word.wordId,
        hebrew: word.hebrew,
        english: word.english,
        ukrainian: word.ukrainian,
        transcription: word.transcription,
        audioAssetPath: word.audioAssetPath,
        correct: 0,
        wrong: 0,
        writingCorrect: word.writingCorrect,
        writingWrong: word.writingWrong,
        writingLastCorrect: word.writingLastCorrect,
        contexts: word.contexts,
      );
  }
}
