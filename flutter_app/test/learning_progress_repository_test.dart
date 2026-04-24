import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/learning_progress_repository.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  test('loads a hydrated progress state from the backing stores', () async {
    final repository = StoreBackedLearningProgressRepository(
      loader: const _FakeBundleLoader(),
      wordProgressStore: _FakeWordProgressStore(
        initialProgress: const {
          'word_man': StoredWordProgress(
            wordId: 'word_man',
            correct: 4,
            wrong: 1,
            lastCorrect: '2026-04-20T10:00:00Z',
            lastReviewedAt: '2026-04-20T11:00:00Z',
            lastReviewCorrect: true,
            writingCorrect: 2,
            writingWrong: 1,
            writingLastCorrect: '2026-04-20T12:00:00Z',
          ),
        },
      ),
      guideProgressStore: _FakeGuideProgressStore(
        initialStatuses: const {'intro_alphabet': GuideLessonStatus.read},
      ),
      readingProgressStore: _FakeReadingProgressStore(
        initialStatuses: const {
          'yosi_goes_to_school': GuideLessonStatus.studying,
        },
      ),
    );

    final state = await repository.load();

    final hydratedWord = state.bundle.words.singleWhere(
      (word) => word.wordId == 'word_man',
    );
    expect(hydratedWord.correct, 4);
    expect(hydratedWord.wrong, 1);
    expect(hydratedWord.lastCorrect, '2026-04-20T10:00:00Z');
    expect(hydratedWord.lastReviewedAt, '2026-04-20T11:00:00Z');
    expect(hydratedWord.lastReviewCorrect, isTrue);
    expect(hydratedWord.writingCorrect, 2);
    expect(hydratedWord.writingWrong, 1);
    expect(hydratedWord.writingLastCorrect, '2026-04-20T12:00:00Z');
    expect(state.guideLessonStatuses['intro_alphabet'], GuideLessonStatus.read);
    expect(
      state.readingLessonStatuses['yosi_goes_to_school'],
      GuideLessonStatus.studying,
    );
  });

  test('saves word and lesson progress through the backing stores', () async {
    final wordStore = _FakeWordProgressStore();
    final guideStore = _FakeGuideProgressStore();
    final readingStore = _FakeReadingProgressStore();
    final repository = StoreBackedLearningProgressRepository(
      loader: const _FakeBundleLoader(),
      wordProgressStore: wordStore,
      guideProgressStore: guideStore,
      readingProgressStore: readingStore,
    );

    await repository.saveWord(
      const LearningWord(
        wordId: 'word_woman',
        hebrew: 'אישה',
        english: 'woman',
        ukrainian: 'жінка',
        transcription: 'isha',
        correct: 3,
        wrong: 0,
      ),
    );
    await repository.setGuideLessonStatus(
      'intro_alphabet',
      GuideLessonStatus.read,
    );
    await repository.setReadingLessonStatus(
      'yosi_goes_to_school',
      GuideLessonStatus.studying,
    );

    expect(wordStore.savedWordIds, ['word_woman']);
    expect(guideStore.lessonStatuses['intro_alphabet'], GuideLessonStatus.read);
    expect(
      readingStore.lessonStatuses['yosi_goes_to_school'],
      GuideLessonStatus.studying,
    );
  });
}

class _FakeBundleLoader implements LearningBundleLoader {
  const _FakeBundleLoader();

  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[
        LearningWord(
          wordId: 'word_man',
          hebrew: 'איש',
          english: 'man',
          ukrainian: 'чоловік',
          transcription: 'ish',
          correct: 0,
          wrong: 0,
        ),
      ],
      guideLessons: <LessonEntry>[
        LessonEntry(
          assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
          displayName: '01 Intro Alphabet',
          lessonId: 'intro_alphabet',
        ),
      ],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[
        LessonEntry(
          assetPath:
              'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
          displayName: '01 Yosi Goes To School',
          lessonId: 'yosi_goes_to_school',
        ),
      ],
    );
  }
}

class _FakeWordProgressStore implements WordProgressStore {
  _FakeWordProgressStore({Map<String, StoredWordProgress>? initialProgress})
    : progress = <String, StoredWordProgress>{...?initialProgress};

  final Map<String, StoredWordProgress> progress;
  final List<String> savedWordIds = <String>[];

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return Map<String, StoredWordProgress>.from(progress);
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    savedWordIds.add(word.wordId);
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
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    lessonStatuses[lessonKey] = status;
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
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    lessonStatuses[lessonKey] = status;
  }
}
