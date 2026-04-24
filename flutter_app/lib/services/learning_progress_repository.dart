import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import 'guide_progress_store.dart';
import 'learning_bundle_loader.dart';
import 'reading_progress_store.dart';
import 'word_progress_store.dart';

class LearningProgressState {
  const LearningProgressState({
    required this.bundle,
    required this.guideLessonStatuses,
    required this.readingLessonStatuses,
  });

  final LearningBundle bundle;
  final Map<String, GuideLessonStatus> guideLessonStatuses;
  final Map<String, GuideLessonStatus> readingLessonStatuses;
}

abstract class LearningProgressRepository {
  Future<LearningProgressState> load();

  Future<LearningProgressState> loadWithFullWordContexts();

  Future<void> saveWord(LearningWord word);

  Future<void> setGuideLessonStatus(String lessonKey, GuideLessonStatus status);

  Future<void> setReadingLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  );
}

class StoreBackedLearningProgressRepository
    implements LearningProgressRepository {
  const StoreBackedLearningProgressRepository({
    required this.loader,
    required this.wordProgressStore,
    required this.guideProgressStore,
    required this.readingProgressStore,
  });

  final LearningBundleLoader loader;
  final WordProgressStore wordProgressStore;
  final GuideProgressStore guideProgressStore;
  final ReadingProgressStore readingProgressStore;

  @override
  Future<LearningProgressState> load() async {
    final bundle = await loader.loadLazySummary();
    return _loadStateForBundle(bundle);
  }

  @override
  Future<LearningProgressState> loadWithFullWordContexts() async {
    final bundle = await loader.loadLazyWithFullWordContexts();
    return _loadStateForBundle(bundle);
  }

  Future<LearningProgressState> _loadStateForBundle(
    LearningBundle bundle,
  ) async {
    final storedProgress = await wordProgressStore.load();
    final guideLessonStatuses = await guideProgressStore.loadLessonStatuses();
    final readingLessonStatuses = await readingProgressStore
        .loadLessonStatuses();

    return LearningProgressState(
      bundle: _hydrateWords(bundle, storedProgress),
      guideLessonStatuses: guideLessonStatuses,
      readingLessonStatuses: readingLessonStatuses,
    );
  }

  @override
  Future<void> saveWord(LearningWord word) {
    return wordProgressStore.saveWord(word);
  }

  @override
  Future<void> setGuideLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) {
    return guideProgressStore.setLessonStatus(lessonKey, status);
  }

  @override
  Future<void> setReadingLessonStatus(
    String lessonKey,
    GuideLessonStatus status,
  ) {
    return readingProgressStore.setLessonStatus(lessonKey, status);
  }

  LearningBundle _hydrateWords(
    LearningBundle bundle,
    Map<String, StoredWordProgress> storedProgress,
  ) {
    if (storedProgress.isEmpty) {
      return bundle;
    }

    return bundle.copyWith(
      words: bundle.words
          .map((word) {
            final progress = storedProgress[word.wordId];
            if (progress == null) {
              return word;
            }

            return word.copyWith(
              correct: progress.correct,
              wrong: progress.wrong,
              lastCorrect: progress.lastCorrect,
              lastReviewedAt: progress.lastReviewedAt,
              lastReviewCorrect: progress.lastReviewCorrect,
              writingCorrect: progress.writingCorrect,
              writingWrong: progress.writingWrong,
              writingLastCorrect: progress.writingLastCorrect,
            );
          })
          .toList(growable: false),
    );
  }
}
