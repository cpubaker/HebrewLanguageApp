import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/theme_mode_store.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('navigates to words and filters the shared bundle', (
    WidgetTester tester,
  ) async {
    await pumpHebrewTestApp(tester);

    expect(find.text('Слово дня'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.translate_rounded).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'woman');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Видимі: 1'), findsOneWidget);
    expect(find.text('Усього: 2'), findsOneWidget);
  });

  testWidgets('selects dark theme from settings and persists it', (
    WidgetTester tester,
  ) async {
    final themeModeStore = FakeThemeModeStore();

    await pumpHebrewTestApp(tester, themeModeStore: themeModeStore);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('theme-mode-tile')),
      500,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-tile')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(themeModeStore.savedPreferences, [AppThemePreference.dark]);
  });

  testWidgets('opens verb lesson details and prepares audio', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeVerbAudioPlayer();

    await pumpHebrewTestApp(
      tester,
      loader: _VerbOnlyBundleLoader(),
      audioPlayerFactory: () => audioPlayer,
      audioPlaybackAwarenessFactory: () => const NoopAudioPlaybackAwareness(),
    );

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_lesson_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ходити').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Увімкнути вимову'));
    await tester.pump();

    expect(audioPlayer.preparedAssets, [
      'assets/learning/input/audio/verbs/walk.mp3',
    ]);
  });

  testWidgets('flashcards save word review progress', (
    WidgetTester tester,
  ) async {
    final store = FakeWordProgressStore();

    await pumpHebrewTestApp(
      tester,
      loader: _BundleLoader(words: const [testManWord]),
      progressStore: store,
    );

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Картки').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('чоловік'), findsOneWidget);
    expect(store.savedByWordId['word_man']?.correct, 2);
  });

  testWidgets('writing practice saves writing progress', (
    WidgetTester tester,
  ) async {
    final store = FakeWordProgressStore();

    await pumpHebrewTestApp(
      tester,
      loader: _BundleLoader(words: const [testPeaceWord]),
      progressStore: store,
    );

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Написання'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'בית');
    await tester.tap(find.widgetWithIcon(FilledButton, Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(store.savedByWordId['word_peace']?.writingWrong, 1);
  });

  testWidgets('opens sprint from practice hub and persists an answer', (
    WidgetTester tester,
  ) async {
    final store = FakeWordProgressStore();

    await pumpHebrewTestApp(
      tester,
      loader: _BundleLoader(words: const [testPeaceWord, testHouseWord]),
      progressStore: store,
    );

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Спринт'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pumpAndSettle();

    expect(store.savedWordIds, isNotEmpty);
  });

  testWidgets('opens flashcards in review mode from the home screen', (
    WidgetTester tester,
  ) async {
    await pumpHebrewTestApp(tester);

    // Home should surface a single primary action card pointing at review,
    // since testWomanWord has a wrong attempt recorded.
    expect(find.text('Продовжити повторення'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'До повторення'));
    await tester.pumpAndSettle();

    expect(find.text('Знаю'), findsOneWidget);
    expect(find.text('Продовжити повторення'), findsNothing);
  });

  testWidgets('hydrates the word of day context after summary load', (
    WidgetTester tester,
  ) async {
    final loader = _LazyWordOfDayContextLoader();

    await pumpHebrewTestApp(tester, loader: loader);

    expect(loader.summaryLoadCount, 1);
    expect(loader.fullLoadCount, 1);
    expect(find.text('word of day context sentence'), findsOneWidget);
    expect(find.text('word of day context translation'), findsOneWidget);
  });
}

class _LazyWordOfDayContextLoader
    implements LearningBundleLoader, LazyLearningBundleLoader {
  int summaryLoadCount = 0;
  int fullLoadCount = 0;

  @override
  Future<LearningBundle> load() {
    return loadWithFullWordContexts();
  }

  @override
  Future<LearningBundle> loadSummary() async {
    summaryLoadCount += 1;
    return _bundle(
      hasFullWordContexts: false,
      contextHebrew: '',
      contextTranslation: '',
    );
  }

  @override
  Future<LearningBundle> loadWithFullWordContexts() async {
    fullLoadCount += 1;
    return _bundle(
      hasFullWordContexts: true,
      contextHebrew: 'word of day context sentence',
      contextTranslation: 'word of day context translation',
    );
  }

  LearningBundle _bundle({
    required bool hasFullWordContexts,
    required String contextHebrew,
    required String contextTranslation,
  }) {
    return LearningBundle(
      words: [
        LearningWord(
          wordId: 'word_of_day',
          hebrew: 'word',
          english: 'word',
          ukrainian: 'word',
          transcription: 'word',
          correct: 0,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_word_of_day',
              hebrew: contextHebrew,
              translation: contextTranslation,
            ),
          ],
        ),
      ],
      guideLessons: const [],
      verbLessons: const [],
      readingLessons: const [],
      hasFullWordContexts: hasFullWordContexts,
    );
  }
}

class _VerbOnlyBundleLoader extends _BundleLoader {
  _VerbOnlyBundleLoader()
    : super(
        words: const [],
        verbLessons: const [
          LessonEntry(
            assetPath: 'assets/learning/input/verbs/01_walk.md',
            displayName: '01 Walk',
          ),
        ],
      );
}

class _BundleLoader implements LearningBundleLoader {
  const _BundleLoader({required this.words, this.verbLessons = const []});

  final List<LearningWord> words;
  final List<LessonEntry> verbLessons;

  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: words,
      guideLessons: const [],
      verbLessons: verbLessons,
      readingLessons: const [],
    );
  }
}
