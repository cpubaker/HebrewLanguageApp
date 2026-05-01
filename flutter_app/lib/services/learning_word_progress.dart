import '../models/learning_word.dart';
import 'word_progress_store.dart';

class LearningWordProgress {
  const LearningWordProgress({
    required this.correct,
    required this.wrong,
    required this.writingCorrect,
    required this.writingWrong,
    this.lastCorrect,
    this.lastReviewedAt,
    this.lastReviewCorrect,
    this.writingLastCorrect,
  });

  factory LearningWordProgress.fromWord(LearningWord word) {
    return LearningWordProgress(
      correct: word.correct,
      wrong: word.wrong,
      lastCorrect: word.lastCorrect,
      lastReviewedAt: word.lastReviewedAt,
      lastReviewCorrect: word.lastReviewCorrect,
      writingCorrect: word.writingCorrect,
      writingWrong: word.writingWrong,
      writingLastCorrect: word.writingLastCorrect,
    );
  }

  factory LearningWordProgress.fromStored(StoredWordProgress progress) {
    return LearningWordProgress(
      correct: progress.correct,
      wrong: progress.wrong,
      lastCorrect: progress.lastCorrect,
      lastReviewedAt: progress.lastReviewedAt,
      lastReviewCorrect: progress.lastReviewCorrect,
      writingCorrect: progress.writingCorrect,
      writingWrong: progress.writingWrong,
      writingLastCorrect: progress.writingLastCorrect,
    );
  }

  final int correct;
  final int wrong;
  final String? lastCorrect;
  final String? lastReviewedAt;
  final bool? lastReviewCorrect;
  final int writingCorrect;
  final int writingWrong;
  final String? writingLastCorrect;

  LearningWord applyTo(LearningWord word) {
    return word.copyWith(
      correct: correct,
      wrong: wrong,
      lastCorrect: lastCorrect,
      lastReviewedAt: lastReviewedAt,
      lastReviewCorrect: lastReviewCorrect,
      writingCorrect: writingCorrect,
      writingWrong: writingWrong,
      writingLastCorrect: writingLastCorrect,
    );
  }
}
