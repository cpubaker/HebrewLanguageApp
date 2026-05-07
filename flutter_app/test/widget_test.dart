import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/home_screen.dart';
import 'package:hebrew_language_flutter/screens/sprint_screen.dart';
import 'package:hebrew_language_flutter/services/app_shell_settings_store.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';
import 'package:hebrew_language_flutter/services/feature_access_service.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
import 'package:hebrew_language_flutter/services/sprint_stats_store.dart';
import 'package:hebrew_language_flutter/services/theme_mode_store.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

class FakeLearningBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [
        LearningWord(
          wordId: 'word_man',
          hebrew: 'איש',
          english: 'man',
          ukrainian: 'чоловік',
          transcription: 'ish',
          correct: 1,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_man_01',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'Чоловік іде вулицею.',
            ),
          ],
        ),
        LearningWord(
          wordId: 'word_woman',
          hebrew: 'אישה',
          english: 'woman',
          ukrainian: 'жінка',
          transcription: 'isha',
          correct: 3,
          wrong: 1,
        ),
      ],
      guideLessons: const [
        LessonEntry(
          assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
          displayName: '01 Intro Alphabet',
        ),
      ],
      verbLessons: const [],
      readingLessons: const [
        LessonEntry(
          assetPath:
              'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
          displayName: '01 Yosi Goes To School',
        ),
      ],
    );
  }
}

class FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('/verbs/')) {
      return const LessonDocument(
        title: '\u0425\u043e\u0434\u0438\u0442\u0438',
        body: '## Present\n\n- holekh\n- holekhet',
      );
    }

    if (assetPath.contains('/reading/')) {
      return const LessonDocument(
        title: 'Yosi Goes To School',
        body: '## Key words\n\n- yosi\n- school',
      );
    }

    return const LessonDocument(
      title: 'Alphabet Basics',
      body: '## First concept\n\n- Hebrew is read from right to left.',
    );
  }
}

Future<void> _useTallMobileViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('supports bottom navigation and word search', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Слово дня'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Профіль'), findsWidgets);
    expect(
      find.text(
        'Стислий огляд того, що є в системі, і як рухається прогрес у словах та практиці.',
      ),
      findsOneWidget,
    );
    expect(find.text('У системі'), findsOneWidget);
    expect(find.text('Слова і практика'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.translate_rounded).first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Шукайте українською, англійською, івритом або за транскрипцією.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), 'woman');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Видимі: 1'), findsOneWidget);
    expect(find.text('Усього: 2'), findsOneWidget);
  });

  testWidgets('selects dark theme from settings and persists it', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final themeModeStore = FakeThemeModeStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        themeModeStore: themeModeStore,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Тема застосунку'), 500);
    await tester.pumpAndSettle();

    expect(find.text('Тема застосунку'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(themeModeStore.savedPreferences, [AppThemePreference.dark]);
  });

  testWidgets('selects system theme from settings and persists it', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final themeModeStore = FakeThemeModeStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        themeModeStore: themeModeStore,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Тема застосунку'), 500);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('theme-mode-system')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(themeModeStore.savedPreferences, [AppThemePreference.system]);
  });

  testWidgets('selects automatic theme and resolves it from the current time', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final themeModeStore = FakeThemeModeStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        themeModeStore: themeModeStore,
        currentDateTime: () => DateTime(2026, 5, 5, 21),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Тема застосунку'), 500);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('theme-mode-automatic')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(themeModeStore.savedPreferences, [AppThemePreference.automatic]);
  });

  testWidgets('shows locked state when night mode is not available', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final themeModeStore = FakeThemeModeStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        themeModeStore: themeModeStore,
        featureAccessService: const StaticFeatureAccessService(
          enabledFeatures: <AppFeature>{
            AppFeature.advancedPractice,
            AppFeature.extraLessons,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Тема застосунку'), 500);
    await tester.pumpAndSettle();

    expect(find.text('Тема застосунку'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(themeModeStore.savedPreferences, isEmpty);
    expect(
      find.text('Нічний режим: Нічний режим доступний у Pro-версії.'),
      findsOneWidget,
    );
  });

  testWidgets('persists bottom navigation auto-hide setting', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final appShellSettingsStore = FakeAppShellSettingsStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        appShellSettingsStore: appShellSettingsStore,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('auto-hide-bottom-nav-switch')),
      500,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('auto-hide-bottom-nav-switch')));
    await tester.pumpAndSettle();

    expect(appShellSettingsStore.savedAutoHideBottomNavValues, [false]);
  });

  testWidgets('restores disabled bottom navigation auto-hide setting', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        appShellSettingsStore: FakeAppShellSettingsStore(
          initialAutoHideBottomNavOnScroll: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find
          .descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(ListView),
          )
          .first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsNothing);
  });

  testWidgets(
    'collapses bottom navigation on scroll and restores it from handle',
    (WidgetTester tester) async {
      await _useTallMobileViewport(tester);
      await tester.pumpWidget(
        HebrewFlutterApp(
          loader: FakeLearningBundleLoader(),
          documentLoader: FakeLessonDocumentLoader(),
          progressStore: FakeWordProgressStore(),
          guideProgressStore: FakeGuideProgressStore(),
          readingProgressStore: FakeReadingProgressStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('app-shell-bottom-nav')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsNothing);

      await tester.drag(
        find
            .descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(ListView),
            )
            .first,
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('app-shell-nav-handle')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('app-shell-nav-handle')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('app-shell-bottom-nav')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsNothing);
    },
  );

  testWidgets('matches Hebrew search without requiring niqqud', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _WordsSearchBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.translate_rounded).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '\u05d1\u05d9\u05ea');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Видимі: 1'), findsOneWidget);
    expect(find.text('Усього: 2'), findsOneWidget);
  });

  testWidgets('opens guide lesson details', (WidgetTester tester) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Alphabet Basics'), findsOneWidget);

    await tester.tap(find.text('Alphabet Basics'));
    await tester.pumpAndSettle();

    expect(find.text('Alphabet Basics'), findsOneWidget);
    expect(find.text('First concept'), findsOneWidget);
    expect(find.text('Hebrew is read from right to left.'), findsOneWidget);
  });

  testWidgets('opens verb lesson details', (WidgetTester tester) async {
    await _useTallMobileViewport(tester);
    final audioPlayer = FakeVerbAudioPlayer();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FakeBundleWithVerbLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        audioPlayerFactory: () => audioPlayer,
        audioPlaybackAwarenessFactory: () => const NoopAudioPlaybackAwareness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_lesson_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('\u0425\u043e\u0434\u0438\u0442\u0438'), findsOneWidget);
    expect(find.text('Walk'), findsNothing);

    final walkLesson = find.ancestor(
      of: find.text('\u0425\u043e\u0434\u0438\u0442\u0438'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(walkLesson.first);
    await tester.tap(walkLesson.first);
    await tester.pumpAndSettle();

    expect(find.text('\u0425\u043e\u0434\u0438\u0442\u0438'), findsOneWidget);
    expect(find.byTooltip('Увімкнути вимову'), findsOneWidget);

    await tester.tap(find.byTooltip('Увімкнути вимову'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(audioPlayer.preparedAssets, [
      'assets/learning/input/audio/verbs/walk.mp3',
    ]);
    expect(find.byTooltip('Зупинити вимову'), findsOneWidget);
  });

  testWidgets('opens reading lesson details', (WidgetTester tester) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Читання').last);
    await tester.pumpAndSettle();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('Початковий'), findsWidgets);

    await tester.tap(find.text('Yosi Goes To School').first);
    await tester.pumpAndSettle();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('Key words'), findsOneWidget);
    expect(find.text('school'), findsOneWidget);
  });

  testWidgets('reveals flashcard answer and advances to the next card', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final store = FakeWordProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FlashcardOnlyBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: store,
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Картки').last);
    await tester.pumpAndSettle();

    expect(find.text('האיש הולך ברחוב.'), findsOneWidget);
    expect(find.text('чоловік'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('чоловік'), findsOneWidget);
    expect(find.text('Чоловік іде вулицею.'), findsOneWidget);
    expect(
      find.widgetWithIcon(FilledButton, Icons.arrow_forward_rounded),
      findsOneWidget,
    );
    expect(store.savedWordIds, contains('word_man'));
    expect(store.savedByWordId['word_man']?.correct, 2);
  });

  testWidgets('checks writing answers and persists writing progress', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final store = FakeWordProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _WritingOnlyBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: store,
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Написання'));
    await tester.pumpAndSettle();

    expect(find.text('мир'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'בית');
    await tester.ensureVisible(
      find.widgetWithIcon(FilledButton, Icons.check_rounded),
    );
    await tester.tap(find.widgetWithIcon(FilledButton, Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(find.text('שלום'), findsOneWidget);
    expect(store.savedWordIds, contains('word_peace'));
    expect(store.savedByWordId['word_peace']?.writingWrong, 1);

    await tester.ensureVisible(
      find.widgetWithIcon(OutlinedButton, Icons.arrow_forward_rounded),
    );
    await tester.tap(
      find.widgetWithIcon(OutlinedButton, Icons.arrow_forward_rounded),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'שלום');
    await tester.ensureVisible(
      find.widgetWithIcon(FilledButton, Icons.check_rounded),
    );
    await tester.tap(find.widgetWithIcon(FilledButton, Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(store.savedByWordId['word_peace']?.writingCorrect, 1);
  });

  testWidgets('opens sprint from practice hub and persists an answer', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final store = FakeWordProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _SprintOnlyBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: store,
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Спринт'));
    await tester.pumpAndSettle();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.byKey(const ValueKey('sprint-option-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('sprint-option-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pumpAndSettle();

    expect(store.savedWordIds, isNotEmpty);
  });

  testWidgets(
    'sprint swipes select first option left and second option right',
    (WidgetTester tester) async {
      await _useTallMobileViewport(tester);
      final updatedWords = <LearningWord>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SprintScreen(
              words: const [
                LearningWord(
                  wordId: 'word_alpha',
                  hebrew: 'alpha',
                  english: 'alpha',
                  transcription: 'alpha',
                  correct: 0,
                  wrong: 0,
                ),
                LearningWord(
                  wordId: 'word_beta',
                  hebrew: 'beta',
                  english: 'beta',
                  transcription: 'beta',
                  correct: 0,
                  wrong: 0,
                ),
              ],
              onWordProgressChanged: updatedWords.add,
              audioPlayerFactory: FakeVerbAudioPlayer.new,
              statsStore: FakeSprintStatsStore(),
              rng: _FixedRandom(),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.fling(
        find.byKey(const ValueKey('sprint-active-card')),
        const Offset(-420, 0),
        1000,
      );
      await tester.pump();

      expect(updatedWords, hasLength(1));
      expect(updatedWords.single.wordId, 'word_alpha');
      expect(updatedWords.single.correct, 0);
      expect(updatedWords.single.wrong, 1);

      await tester.fling(
        find.byKey(const ValueKey('sprint-active-card')),
        const Offset(420, 0),
        1000,
      );
      await tester.pump();

      expect(updatedWords, hasLength(2));
      expect(updatedWords.last.wordId, 'word_beta');
      expect(updatedWords.last.correct, 1);
      expect(updatedWords.last.wrong, 0);
    },
  );

  testWidgets('sprint timeout summary does not duplicate the expired label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SprintScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                correct: 0,
                wrong: 0,
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                ukrainian: 'будинок',
                transcription: 'bayit',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: FakeVerbAudioPlayer.new,
            duration: const Duration(seconds: 1),
            rng: _FixedRandom(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Час вийшов'), findsOneWidget);
    expect(
      find.text(
        'Хвилина завершилася. Подивіться на результат і, якщо хочете, спробуйте ще раз.',
      ),
      findsNothing,
    );
  });

  testWidgets('sprint completion shows record and above-average feedback', (
    WidgetTester tester,
  ) async {
    final statsStore = FakeSprintStatsStore(
      const SprintStats(sessions: 2, bestCorrect: 1, totalCorrect: 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SprintScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                correct: 0,
                wrong: 0,
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                ukrainian: 'будинок',
                transcription: 'bayit',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: FakeVerbAudioPlayer.new,
            statsStore: statsStore,
            duration: const Duration(seconds: 1),
            rng: _FixedRandom(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('sprint-option-1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Рекорд досягнуто'), findsOneWidget);
    expect(
      find.textContaining('Ви досягли свого рекорду: 1 вірних відповідей.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Це на 0,3 вище вашого середнього.'),
      findsOneWidget,
    );
    expect(statsStore.savedStats.last.bestCorrect, 1);
    expect(statsStore.savedStats.last.sessions, 3);
  });

  testWidgets('sprint ends early after all learning words are answered', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SprintScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                correct: 0,
                wrong: 0,
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                ukrainian: 'будинок',
                transcription: 'bayit',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: FakeVerbAudioPlayer.new,
            statsStore: FakeSprintStatsStore(),
            rng: _FixedRandom(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('мир'));
    await tester.pump();
    await tester.tap(find.text('будинок'));
    await tester.pump();

    expect(
      find.textContaining('Усі слова на вивченні пройдено.'),
      findsOneWidget,
    );
  });

  testWidgets('sprint auto-plays audio for the first and second prompts', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeVerbAudioPlayer(
      availableAssets: const {
        'assets/audio/shalom.mp3',
        'assets/audio/bayit.mp3',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SprintScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                audioAssetPath: 'assets/audio/shalom.mp3',
                correct: 0,
                wrong: 0,
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                ukrainian: 'будинок',
                transcription: 'bayit',
                audioAssetPath: 'assets/audio/bayit.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: () => audioPlayer,
            rng: _FixedRandom(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, [
      'assets/audio/shalom.mp3',
      'assets/audio/bayit.mp3',
    ]);
  });

  testWidgets('sprint stays silent when the next prompt has no audio', (
    WidgetTester tester,
  ) async {
    final audioPlayer = FakeVerbAudioPlayer(
      availableAssets: const {'assets/audio/shalom.mp3'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SprintScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                audioAssetPath: 'assets/audio/shalom.mp3',
                correct: 0,
                wrong: 0,
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                ukrainian: 'будинок',
                transcription: 'bayit',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: () => audioPlayer,
            rng: _FixedRandom(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('sprint-option-0')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);
  });

  testWidgets('shows a completion state after the last flashcard in the deck', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FlashcardOnlyBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Картки').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithIcon(FilledButton, Icons.arrow_forward_rounded),
    );
    await tester.pumpAndSettle();

    expect(find.text('Картки'), findsWidgets);
  });

  testWidgets('hydrates persisted word progress into the shared bundle', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final store = FakeWordProgressStore(
      initialProgress: const {
        'word_man': StoredWordProgress(
          wordId: 'word_man',
          correct: 9,
          wrong: 2,
          lastCorrect: '2026-03-31T09:30:00',
        ),
      },
    );

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: store,
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.translate_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('чоловік'), findsOneWidget);
    await tester.tap(find.text('чоловік'));
    await tester.pumpAndSettle();

    expect(find.text('Правильно: 9'), findsOneWidget);
    expect(find.text('Помилки: 2'), findsOneWidget);
  });

  testWidgets('shows persisted study progress on the home screen', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final store = FakeWordProgressStore(
      initialProgress: const {
        'word_man': StoredWordProgress(
          wordId: 'word_man',
          correct: 5,
          wrong: 0,
          lastCorrect: '2026-03-31T09:30:00',
        ),
        'word_woman': StoredWordProgress(
          wordId: 'word_woman',
          correct: 1,
          wrong: 2,
          lastCorrect: '2026-03-31T09:40:00',
        ),
      },
    );

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: store,
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Серія занять'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Серія занять'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Прогрес навчання'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Прогрес навчання'), findsOneWidget);
    expect(find.text('Опрацьовано 2 із 2 слів'), findsOneWidget);
    expect(find.text('Повторити'), findsWidgets);
    expect(find.text('Нові'), findsOneWidget);
  });

  testWidgets('opens flashcards in review mode from the home screen', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Картки на сьогодні'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Продовжити'), findsOneWidget);

    await tester.tap(find.text('Продовжити'));
    await tester.pumpAndSettle();

    expect(find.text('Знаю'), findsOneWidget);
    expect(find.text('Продовжити'), findsNothing);
  });

  testWidgets('shows the dedicated reading preview block on the home screen', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Що почитати'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Що почитати'), findsOneWidget);
    expect(find.text('Yosi Goes To School'), findsWidgets);
    expect(find.text('Початковий'), findsOneWidget);
    expect(find.text('До читання'), findsOneWidget);
  });

  testWidgets('hydrates the word of day context after summary load', (
    WidgetTester tester,
  ) async {
    await _useTallMobileViewport(tester);
    final loader = _LazyWordOfDayContextLoader();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: loader,
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

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

class _FakeBundleWithVerbLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [],
      guideLessons: const [],
      verbLessons: const [
        LessonEntry(
          assetPath: 'assets/learning/input/verbs/01_walk.md',
          displayName: '01 Walk',
        ),
      ],
      readingLessons: const [],
    );
  }
}

class _FlashcardOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [
        LearningWord(
          wordId: 'word_man',
          hebrew: 'איש',
          english: 'man',
          ukrainian: 'чоловік',
          transcription: 'ish',
          correct: 1,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_man_01',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'Чоловік іде вулицею.',
            ),
          ],
        ),
      ],
      guideLessons: const [],
      verbLessons: const [],
      readingLessons: const [],
    );
  }
}

class _SprintOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'שלום',
          english: 'peace',
          ukrainian: 'мир',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
        LearningWord(
          wordId: 'word_house',
          hebrew: 'בית',
          english: 'house',
          ukrainian: 'будинок',
          transcription: 'bayit',
          correct: 0,
          wrong: 0,
        ),
      ],
      guideLessons: const [],
      verbLessons: const [],
      readingLessons: const [],
    );
  }
}

class _WordsSearchBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [
        LearningWord(
          wordId: 'word_house',
          hebrew: '\u05d1\u05b7\u05bc\u05d9\u05b4\u05ea',
          english: 'house',
          ukrainian: '\u0431\u0443\u0434\u0438\u043d\u043e\u043a',
          transcription: 'bayit',
          correct: 0,
          wrong: 0,
        ),
        LearningWord(
          wordId: 'word_peace',
          hebrew: '\u05e9\u05b8\u05c1\u05dc\u05d5\u05b9\u05dd',
          english: 'peace',
          ukrainian: '\u043c\u0438\u0440',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
      ],
      guideLessons: const [],
      verbLessons: const [],
      readingLessons: const [],
    );
  }
}

class _WritingOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return LearningBundle(
      words: const [
        LearningWord(
          wordId: 'word_peace',
          hebrew: 'שלום',
          english: 'peace',
          ukrainian: 'мир',
          transcription: 'shalom',
          correct: 0,
          wrong: 0,
        ),
      ],
      guideLessons: const [],
      verbLessons: const [],
      readingLessons: const [],
    );
  }
}

class FakeWordProgressStore implements WordProgressStore {
  FakeWordProgressStore({Map<String, StoredWordProgress>? initialProgress})
    : savedByWordId = <String, StoredWordProgress>{...?initialProgress};

  final Map<String, StoredWordProgress> savedByWordId;
  final List<String> savedWordIds = <String>[];

  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return Map<String, StoredWordProgress>.from(savedByWordId);
  }

  @override
  Future<void> saveWord(LearningWord word) async {
    savedWordIds.add(word.wordId);
    savedByWordId[word.wordId] = StoredWordProgress(
      wordId: word.wordId,
      correct: word.correct,
      wrong: word.wrong,
      lastCorrect: word.lastCorrect,
      writingCorrect: word.writingCorrect,
      writingWrong: word.writingWrong,
      writingLastCorrect: word.writingLastCorrect,
    );
  }
}

class FakeGuideProgressStore implements GuideProgressStore {
  FakeGuideProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
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

class FakeReadingProgressStore implements ReadingProgressStore {
  FakeReadingProgressStore({Map<String, GuideLessonStatus>? initialStatuses})
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

class FakeSprintStatsStore implements SprintStatsStore {
  FakeSprintStatsStore([this.stats = const SprintStats.empty()]);

  SprintStats stats;
  final List<SprintStats> savedStats = <SprintStats>[];

  @override
  Future<SprintStats> load() async => stats;

  @override
  Future<void> save(SprintStats stats) async {
    this.stats = stats;
    savedStats.add(stats);
  }
}

class FakeVerbAudioPlayer implements VerbAudioPlayer {
  FakeVerbAudioPlayer({
    this.availableAssets = const {'assets/learning/input/audio/verbs/walk.mp3'},
  });

  final Set<String> availableAssets;
  final List<String> playedAssets = <String>[];
  final List<String> preparedAssets = <String>[];
  final StreamController<bool> _isPlayingController =
      StreamController<bool>.broadcast();
  bool stopped = false;
  bool disposed = false;

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Future<bool> assetExists(String assetPath) async {
    return availableAssets.contains(assetPath);
  }

  @override
  Future<bool> prepareAsset(String assetPath) async {
    if (!availableAssets.contains(assetPath)) {
      return false;
    }
    preparedAssets.add(assetPath);
    return true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _isPlayingController.close();
  }

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
    _isPlayingController.add(true);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    _isPlayingController.add(false);
  }
}

class FakeThemeModeStore implements ThemeModeStore {
  FakeThemeModeStore({this.initialPreference = AppThemePreference.light});

  final AppThemePreference initialPreference;
  final List<AppThemePreference> savedPreferences = <AppThemePreference>[];

  @override
  Future<AppThemePreference> load() async => initialPreference;

  @override
  Future<void> save(AppThemePreference preference) async {
    savedPreferences.add(preference);
  }
}

class FakeAppShellSettingsStore implements AppShellSettingsStore {
  FakeAppShellSettingsStore({this.initialAutoHideBottomNavOnScroll = true});

  final bool initialAutoHideBottomNavOnScroll;
  final List<bool> savedAutoHideBottomNavValues = <bool>[];

  @override
  Future<bool> loadAutoHideBottomNavOnScroll() async {
    return initialAutoHideBottomNavOnScroll;
  }

  @override
  Future<void> saveAutoHideBottomNavOnScroll(bool enabled) async {
    savedAutoHideBottomNavValues.add(enabled);
  }
}

class _FixedRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
