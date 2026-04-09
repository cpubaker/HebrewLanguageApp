import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/home_screen.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/reading_progress_store.dart';
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

void main() {
  testWidgets('supports bottom navigation and word search', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Вчимо іврит'), findsOneWidget);
    expect(find.text('Мобільна версія'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Пошук за українською, англійською, транскрипцією, івритом або ID.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), 'woman');
    await tester.pumpAndSettle();

    expect(find.text('жінка'), findsWidgets);
    expect(find.text('чоловік'), findsNothing);

    await tester.tap(find.text('жінка').last);
    await tester.pumpAndSettle();

    expect(find.text('ID: word_woman'), findsOneWidget);
  });

  testWidgets('collapses bottom navigation on scroll and restores it from handle', (
    WidgetTester tester,
  ) async {
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

    expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsNothing);

    await tester.drag(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(ListView),
      ).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('app-shell-nav-handle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-shell-nav-handle')), findsNothing);
  });

  testWidgets('matches Hebrew search without requiring niqqud', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '\u05d1\u05d9\u05ea');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('\u0431\u0443\u0434\u0438\u043d\u043e\u043a'), findsWidgets);
    expect(find.text('\u043c\u0438\u0440'), findsNothing);
  });

  testWidgets('opens guide lesson details', (WidgetTester tester) async {
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

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Alphabet Basics'), findsOneWidget);

    await tester.tap(find.text('Alphabet Basics'));
    await tester.pumpAndSettle();

    expect(find.text('Alphabet Basics'), findsOneWidget);
    expect(find.text('First concept'), findsOneWidget);
    expect(find.text('Hebrew is read from right to left.'), findsOneWidget);
  });

  testWidgets('opens verb lesson details', (WidgetTester tester) async {
    final audioPlayer = FakeVerbAudioPlayer();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FakeBundleWithVerbLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: FakeReadingProgressStore(),
        audioPlayerFactory: () => audioPlayer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_lesson_outlined));
    await tester.pumpAndSettle();

    expect(find.text('\u0425\u043e\u0434\u0438\u0442\u0438'), findsOneWidget);
    expect(find.text('Walk'), findsNothing);

    await tester.tap(find.text('\u0425\u043e\u0434\u0438\u0442\u0438'));
    await tester.pumpAndSettle();

    expect(find.text('\u0425\u043e\u0434\u0438\u0442\u0438'), findsOneWidget);
    expect(find.byTooltip('Увімкнути вимову'), findsOneWidget);

    await tester.tap(find.byTooltip('Увімкнути вимову'));
    await tester.pumpAndSettle();

    expect(audioPlayer.playedAssets, [
      'assets/learning/input/audio/verbs/walk.mp3',
    ]);
    expect(find.byTooltip('Зупинити вимову'), findsOneWidget);
  });

  testWidgets('opens reading lesson details', (WidgetTester tester) async {
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

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
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

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Картки'), findsWidgets);
    expect(find.text('האיש הולך ברחוב.'), findsOneWidget);
    expect(find.text('чоловік'), findsNothing);

    await tester.ensureVisible(find.text('Знаю'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Знаю'));
    await tester.pumpAndSettle();

    expect(find.text('чоловік'), findsOneWidget);
    expect(find.text('Чоловік іде вулицею.'), findsOneWidget);
    expect(find.text('До підсумку'), findsOneWidget);
    expect(store.savedWordIds, contains('word_man'));
    expect(store.savedByWordId['word_man']?.correct, 2);
  });

  testWidgets('checks writing answers and persists writing progress', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Письмо'), findsWidgets);
    expect(find.text('мир'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'בית');
    await tester.ensureVisible(find.text('Перевірити'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Перевірити'));
    await tester.pumpAndSettle();

    expect(find.text('Потрібно ще раз'), findsOneWidget);
    expect(find.text('שלום'), findsOneWidget);
    expect(store.savedWordIds, contains('word_peace'));
    expect(store.savedByWordId['word_peace']?.writingWrong, 1);

    await tester.ensureVisible(find.text('Далі'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далі'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'שלום');
    await tester.ensureVisible(find.text('Перевірити'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Перевірити'));
    await tester.pumpAndSettle();

    expect(find.text('Правильно'), findsWidgets);
    expect(store.savedByWordId['word_peace']?.writingCorrect, 1);
  });

  testWidgets('shows a completion state after the last flashcard in the deck', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Знаю'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Знаю'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('До підсумку'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('До підсумку'));
    await tester.pumpAndSettle();

    expect(find.text('Готово'), findsOneWidget);
    expect(find.text('Почати ще раз'), findsOneWidget);
  });

  testWidgets('hydrates persisted word progress into the shared bundle', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('чоловік').last);
    await tester.pumpAndSettle();

    expect(find.text('Правильно: 9'), findsOneWidget);
    expect(find.text('Помилки: 2'), findsOneWidget);
  });

  testWidgets('shows persisted study progress on the home screen', (
    WidgetTester tester,
  ) async {
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

    await tester.scrollUntilVisible(find.text('Ваш поступ'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Ваш поступ'), findsOneWidget);
    expect(find.text('Опрацьовано 2 із 2 слів'), findsOneWidget);
    expect(find.text('Повторити'), findsOneWidget);
    expect(find.text('Нові'), findsOneWidget);
  });

  testWidgets('opens flashcards in review mode from the home screen', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Картки'), findsWidgets);
    expect(find.text('1 на повторенні'), findsOneWidget);
    expect(find.text('жінка'), findsNothing);
  });

  testWidgets('shows the dedicated reading preview block on the home screen', (
    WidgetTester tester,
  ) async {
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
