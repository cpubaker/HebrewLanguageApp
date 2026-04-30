import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/app_dependencies.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  test(
    'resolved progress repository uses provided stores and loader',
    () async {
      final progressStore = _FakeWordProgressStore(
        initialProgress: const {
          'word_peace': StoredWordProgress(
            wordId: 'word_peace',
            correct: 4,
            wrong: 1,
            lastCorrect: '2026-04-01T08:00:00',
          ),
        },
      );
      final dependencies = AppDependencies(
        loader: const _FakeBundleLoader(),
        progressStore: progressStore,
        guideProgressStore: _FakeGuideProgressStore(
          initialStatuses: const {
            'assets/learning/input/guide/01_intro.md': GuideLessonStatus.read,
          },
        ),
        readingProgressStore: _FakeReadingProgressStore(
          initialStatuses: const {
            'assets/learning/input/reading/01_story.md':
                GuideLessonStatus.studying,
          },
        ),
      );

      final state = await dependencies.resolveProgressRepository().load();

      expect(state.bundle.words.single.correct, 4);
      expect(state.bundle.words.single.wrong, 1);
      expect(
        state.guideLessonStatuses['assets/learning/input/guide/01_intro.md'],
        GuideLessonStatus.read,
      );
      expect(
        state
            .readingLessonStatuses['assets/learning/input/reading/01_story.md'],
        GuideLessonStatus.studying,
      );
    },
  );

  test('legacy-style overrides keep unspecified base dependencies', () {
    const baseLoader = _FakeBundleLoader();
    final progressStore = _FakeWordProgressStore();

    final dependencies = const AppDependencies(
      loader: baseLoader,
    ).withOverrides(progressStore: progressStore);

    expect(dependencies.loader, same(baseLoader));
    expect(dependencies.progressStore, same(progressStore));
  });
}

class _FakeBundleLoader implements LearningBundleLoader {
  const _FakeBundleLoader();

  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'shalom',
          english: 'peace',
          ukrainian: 'myr',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
      ],
      guideLessons: [],
      verbLessons: [],
      readingLessons: [],
    );
  }
}

class _FakeWordProgressStore implements WordProgressStore {
  _FakeWordProgressStore({Map<String, StoredWordProgress>? initialProgress})
    : savedByWordId = <String, StoredWordProgress>{...?initialProgress};

  final Map<String, StoredWordProgress> savedByWordId;

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return Map<String, StoredWordProgress>.from(savedByWordId);
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    savedByWordId[word.wordId] = StoredWordProgress(
      wordId: word.wordId,
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
}

class _FakeGuideProgressStore implements GuideProgressStore {
  _FakeGuideProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
    : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

  final Map<String, GuideLessonStatus> lessonStatuses;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return Map<String, GuideLessonStatus>.from(lessonStatuses);
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    if (status == GuideLessonStatus.unread) {
      lessonStatuses.remove(assetPath);
    } else {
      lessonStatuses[assetPath] = status;
    }
  }
}

class _FakeReadingProgressStore implements ReadingProgressStore {
  _FakeReadingProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
    : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

  final Map<String, GuideLessonStatus> lessonStatuses;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return Map<String, GuideLessonStatus>.from(lessonStatuses);
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    if (status == GuideLessonStatus.unread) {
      lessonStatuses.remove(assetPath);
    } else {
      lessonStatuses[assetPath] = status;
    }
  }
}
