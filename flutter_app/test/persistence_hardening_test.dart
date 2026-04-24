import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('word progress store ignores corrupted JSON payloads', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'learning_word_progress_v1': '{not-valid-json',
    });

    final store = SharedPreferencesWordProgressStore();

    final loadedProgress = await store.load();

    expect(loadedProgress, isEmpty);
  });

  test('word progress store sanitizes malformed entries', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'learning_word_progress_v1': jsonEncode(<String, Object?>{
        ' word_walk ': <String, Object?>{
          'correct': '3',
          'wrong': -7,
          'last_correct': ' 2026-04-04T10:00:00Z ',
          'writing_correct': '5',
          'writing_wrong': -2,
          'writing_last_correct': ' 2026-04-04T12:00:00Z ',
        },
        'broken_value': 'not-a-map',
        '': <String, Object?>{'correct': 1},
      }),
    });

    final store = SharedPreferencesWordProgressStore();

    final loadedProgress = await store.load();

    expect(loadedProgress, hasLength(1));
    expect(loadedProgress.keys.single, 'word_walk');
    expect(loadedProgress['word_walk']?.correct, 3);
    expect(loadedProgress['word_walk']?.wrong, 0);
    expect(loadedProgress['word_walk']?.lastCorrect, '2026-04-04T10:00:00Z');
    expect(loadedProgress['word_walk']?.writingCorrect, 5);
    expect(loadedProgress['word_walk']?.writingWrong, 0);
    expect(
      loadedProgress['word_walk']?.writingLastCorrect,
      '2026-04-04T12:00:00Z',
    );
  });

  test(
    'word progress store persists writing stats alongside review stats',
    () async {
      final store = SharedPreferencesWordProgressStore();

      await store.saveWord(
        const LearningWord(
          wordId: 'word_shalom',
          hebrew: 'שלום',
          english: 'peace',
          transcription: 'shalom',
          correct: 2,
          wrong: 1,
          lastCorrect: '2026-04-04T10:00:00Z',
          writingCorrect: 4,
          writingWrong: 3,
          writingLastCorrect: '2026-04-04T12:30:00Z',
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final rawPayload = prefs.getString('learning_word_progress_v1');

      expect(rawPayload, isNotNull);
      expect(jsonDecode(rawPayload!), <String, Object?>{
        'word_shalom': <String, Object?>{
          'correct': 2,
          'wrong': 1,
          'last_correct': '2026-04-04T10:00:00Z',
          'writing_correct': 4,
          'writing_wrong': 3,
          'writing_last_correct': '2026-04-04T12:30:00Z',
        },
      });
    },
  );

  test('guide progress store migrates legacy read lessons', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guide_read_lessons_v1': <String>[
        ' assets/learning/input/guide/01_intro_alphabet.md ',
        ' assets/learning/input/guide/42_infinitive_constructions.md ',
        '',
        '   ',
      ],
    });

    final store = SharedPreferencesGuideProgressStore();

    final loadedStatuses = await store.loadLessonStatuses();

    expect(loadedStatuses, <String, GuideLessonStatus>{
      'intro_alphabet': GuideLessonStatus.read,
      'infinitive_constructions': GuideLessonStatus.read,
    });
  });

  test(
    'guide progress store remaps renamed lesson paths in status payloads',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'guide_lesson_statuses_v2': jsonEncode(<String, Object?>{
          'assets/learning/input/guide/42_infinitive_constructions.md':
              'studying',
          'assets/learning/input/guide/49_register_formal_vs_spoken.md': 'read',
          'assets/learning/input/guide/47_relative_clause_expansion.md': 'read',
        }),
      });

      final store = SharedPreferencesGuideProgressStore();

      final loadedStatuses = await store.loadLessonStatuses();

      expect(loadedStatuses, <String, GuideLessonStatus>{
        'infinitive_constructions': GuideLessonStatus.studying,
        'relative_and_she': GuideLessonStatus.read,
        'register_formal_vs_spoken': GuideLessonStatus.read,
      });
    },
  );

  test('guide progress store sanitizes malformed status payloads', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guide_lesson_statuses_v2': jsonEncode(<String, Object?>{
        ' assets/learning/input/guide/01_intro_alphabet.md ': 'studying',
        'assets/learning/input/guide/02_numbers.md': 'read',
        'assets/learning/input/guide/03_colors.md': 'unknown',
        'assets/learning/input/guide/04_animals.md': 'unread',
        '': 'read',
      }),
    });

    final store = SharedPreferencesGuideProgressStore();

    final loadedStatuses = await store.loadLessonStatuses();

    expect(loadedStatuses, <String, GuideLessonStatus>{
      'intro_alphabet': GuideLessonStatus.studying,
      'numbers': GuideLessonStatus.read,
    });
  });

  test('reading progress store sanitizes malformed status payloads', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'reading_lesson_statuses_v1': jsonEncode(<String, Object?>{
        ' assets/learning/input/reading/beginner/01_yosi_goes_to_school.md ':
            'studying',
        'assets/learning/input/reading/intermediate/02_city_trip.md': 'read',
        'assets/learning/input/reading/advanced/03_market_day.md': 'unknown',
        'assets/learning/input/reading/proficient/04_news_digest.md': 'unread',
        '': 'read',
      }),
    });

    final store = SharedPreferencesReadingProgressStore();

    final loadedStatuses = await store.loadLessonStatuses();

    expect(loadedStatuses, <String, GuideLessonStatus>{
      'yosi_goes_to_school': GuideLessonStatus.studying,
      'city_trip': GuideLessonStatus.read,
    });
  });

  test('guide progress store writes stable lesson keys', () async {
    final store = SharedPreferencesGuideProgressStore();

    await store.setLessonStatus(
      'assets/learning/input/guide/01_intro_alphabet.md',
      GuideLessonStatus.studying,
    );

    final prefs = await SharedPreferences.getInstance();
    final rawPayload = prefs.getString('guide_lesson_statuses_v3');

    expect(rawPayload, isNotNull);
    expect(jsonDecode(rawPayload!), <String, Object?>{
      'intro_alphabet': 'studying',
    });
  });

  test('reading progress store writes stable lesson keys', () async {
    final store = SharedPreferencesReadingProgressStore();

    await store.setLessonStatus(
      'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
      GuideLessonStatus.read,
    );

    final prefs = await SharedPreferences.getInstance();
    final rawPayload = prefs.getString('reading_lesson_statuses_v2');

    expect(rawPayload, isNotNull);
    expect(jsonDecode(rawPayload!), <String, Object?>{
      'yosi_goes_to_school': 'read',
    });
  });

  testWidgets('guide progress rolls back when persistence fails', (
    WidgetTester tester,
  ) async {
    final guideStore = _ThrowingGuideProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _GuideOnlyBundleLoader(),
        documentLoader: _GuideDocumentLoader(),
        progressStore: _FakeWordProgressStore(),
        guideProgressStore: guideStore,
        readingProgressStore: _FakeReadingProgressStore(),
        audioPlayerFactory: () => _FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.library_books_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(guideStore.attemptedWrites, 1);
    expect(find.text('Не прочитано'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('reading progress rolls back when persistence fails', (
    WidgetTester tester,
  ) async {
    final readingStore = _ThrowingReadingProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _ReadingOnlyBundleLoader(),
        documentLoader: _ReadingDocumentLoader(),
        progressStore: _FakeWordProgressStore(),
        guideProgressStore: _FakeGuideProgressStore(),
        readingProgressStore: readingStore,
        audioPlayerFactory: () => _FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.library_books_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Читання').last);
    await tester.pumpAndSettle();

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(readingStore.attemptedWrites, 1);
    expect(find.text('Не прочитано'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class _GuideOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: <LessonEntry>[
        LessonEntry(
          assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
          displayName: '01 Intro Alphabet',
        ),
      ],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[],
    );
  }
}

class _GuideDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(
      title: 'Alphabet Basics',
      body: '## First concept\n\n- Hebrew is read from right to left.',
    );
  }
}

class _ReadingOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: <LessonEntry>[
        LessonEntry(
          assetPath:
              'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
          displayName: '01 Yosi Goes To School',
        ),
      ],
    );
  }
}

class _ReadingDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(
      title: 'Yosi Goes To School',
      body: '## Key words\n\n- yosi\n- school',
    );
  }
}

class _FakeWordProgressStore implements WordProgressStore {
  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return <String, StoredWordProgress>{};
  }

  @override
  Future<void> saveWord(LearningWord word) async {}
}

class _ThrowingGuideProgressStore implements GuideProgressStore {
  int attemptedWrites = 0;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return <String, GuideLessonStatus>{};
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    attemptedWrites += 1;
    throw StateError('Simulated persistence failure');
  }
}

class _FakeGuideProgressStore implements GuideProgressStore {
  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return <String, GuideLessonStatus>{};
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {}
}

class _ThrowingReadingProgressStore implements ReadingProgressStore {
  int attemptedWrites = 0;

  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return <String, GuideLessonStatus>{};
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {
    attemptedWrites += 1;
    throw StateError('Simulated persistence failure');
  }
}

class _FakeReadingProgressStore implements ReadingProgressStore {
  @override
  Future<Map<String, GuideLessonStatus>> loadLessonStatuses() async {
    return <String, GuideLessonStatus>{};
  }

  @override
  Future<void> setLessonStatus(
    String assetPath,
    GuideLessonStatus status,
  ) async {}
}

class _FakeVerbAudioPlayer implements VerbAudioPlayer {
  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => false;

  @override
  Future<bool> prepareAsset(String assetPath) async => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
