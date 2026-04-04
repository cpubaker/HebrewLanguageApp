import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
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
        },
        'broken_value': 'not-a-map',
        '': <String, Object?>{
          'correct': 1,
        },
      }),
    });

    final store = SharedPreferencesWordProgressStore();

    final loadedProgress = await store.load();

    expect(loadedProgress, hasLength(1));
    expect(loadedProgress.keys.single, 'word_walk');
    expect(loadedProgress['word_walk']?.correct, 3);
    expect(loadedProgress['word_walk']?.wrong, 0);
    expect(
      loadedProgress['word_walk']?.lastCorrect,
      '2026-04-04T10:00:00Z',
    );
  });

  test('guide progress store trims empty lesson paths', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guide_read_lessons_v1': <String>[
        ' assets/learning/input/guide/01_intro_alphabet.md ',
        '',
        '   ',
      ],
    });

    final store = SharedPreferencesGuideProgressStore();

    final loadedLessons = await store.loadReadLessons();

    expect(
      loadedLessons,
      <String>{'assets/learning/input/guide/01_intro_alphabet.md'},
    );
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
        audioPlayerFactory: () => _FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(guideStore.attemptedWrites, 1);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
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
  Future<Set<String>> loadReadLessons() async {
    return <String>{};
  }

  @override
  Future<void> setLessonRead(String assetPath, bool isRead) async {
    attemptedWrites += 1;
    throw StateError('Simulated persistence failure');
  }
}

class _FakeVerbAudioPlayer implements VerbAudioPlayer {
  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
