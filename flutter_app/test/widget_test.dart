import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
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
          transcription: 'ish',
          correct: 1,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_man_01',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'The man is walking in the street.',
            ),
          ],
        ),
        LearningWord(
          wordId: 'word_woman',
          hebrew: 'אישה',
          english: 'woman',
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
          assetPath: 'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
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
        title: 'Walk',
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hebrew Language App'), findsOneWidget);
    expect(find.text('Android Migration'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    expect(
      find.text('Search by English, transcription, Hebrew, or internal word id.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), 'woman');
    await tester.pumpAndSettle();

    expect(find.text('woman'), findsWidgets);
    expect(find.text('man'), findsNothing);

    await tester.tap(find.text('woman').last);
    await tester.pumpAndSettle();

    expect(find.text('Word id: word_woman'), findsOneWidget);
  });

  testWidgets('opens guide lesson details', (WidgetTester tester) async {
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Intro Alphabet'), findsOneWidget);

    await tester.tap(find.text('Intro Alphabet'));
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
        audioPlayerFactory: () => audioPlayer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_lesson_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Walk'), findsOneWidget);

    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();

    expect(find.text('Walk'), findsOneWidget);
    expect(find.byTooltip('Play audio'), findsOneWidget);

    await tester.tap(find.byTooltip('Play audio'));
    await tester.pumpAndSettle();

    expect(audioPlayer.playedAssets, ['assets/learning/input/audio/verbs/walk.mp3']);
    expect(find.byTooltip('Stop audio'), findsOneWidget);
  });

  testWidgets('opens reading lesson details', (WidgetTester tester) async {
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('Beginner'), findsWidgets);

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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.text('האיש הולך ברחוב.'), findsOneWidget);
    expect(find.text('man'), findsNothing);

    await tester.ensureVisible(find.text('Know'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Know'));
    await tester.pumpAndSettle();

    expect(find.text('man'), findsOneWidget);
    expect(find.text('The man is walking in the street.'), findsOneWidget);
    expect(find.text('See Summary'), findsOneWidget);
    expect(store.savedWordIds, contains('word_man'));
    expect(store.savedByWordId['word_man']?.correct, 2);
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Know'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Know'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('See Summary'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Deck complete'), findsOneWidget);
    expect(find.text('Restart Deck'), findsOneWidget);
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('man').last);
    await tester.pumpAndSettle();

    expect(find.text('Correct: 9'), findsOneWidget);
    expect(find.text('Wrong: 2'), findsOneWidget);
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Study Progress'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Study Progress'), findsOneWidget);
    expect(find.text('2 of 2 words have progress on this device'), findsOneWidget);
    expect(find.text('Needs Review'), findsOneWidget);
    expect(find.text('Unseen'), findsOneWidget);
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Flashcard Focus'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Resume Review'), findsOneWidget);

    await tester.tap(find.text('Resume Review'));
    await tester.pumpAndSettle();

    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.text('Card 1 of 1'), findsOneWidget);
    expect(find.text('woman'), findsNothing);
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Reading Preview'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Reading Preview'), findsOneWidget);
    expect(find.text('Yosi Goes To School'), findsWidgets);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Open Reading'), findsOneWidget);
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
          transcription: 'ish',
          correct: 1,
          wrong: 0,
          contexts: [
            LearningContext(
              contextId: 'ctx_man_01',
              hebrew: 'האיש הולך ברחוב.',
              translation: 'The man is walking in the street.',
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

class FakeWordProgressStore implements WordProgressStore {
  FakeWordProgressStore({
    Map<String, StoredWordProgress>? initialProgress,
  }) : savedByWordId = <String, StoredWordProgress>{
          ...?initialProgress,
        };

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
    );
  }
}

class FakeGuideProgressStore implements GuideProgressStore {
  FakeGuideProgressStore({
    Set<String>? initialReadLessons,
  }) : readLessons = {...?initialReadLessons};

  final Set<String> readLessons;

  @override
  Future<Set<String>> loadReadLessons() async {
    return {...readLessons};
  }

  @override
  Future<void> setLessonRead(String assetPath, bool isRead) async {
    if (isRead) {
      readLessons.add(assetPath);
    } else {
      readLessons.remove(assetPath);
    }
  }
}

class FakeVerbAudioPlayer implements VerbAudioPlayer {
  FakeVerbAudioPlayer({
    this.availableAssets = const {'assets/learning/input/audio/verbs/walk.mp3'},
  });

  final Set<String> availableAssets;
  final List<String> playedAssets = <String>[];
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
