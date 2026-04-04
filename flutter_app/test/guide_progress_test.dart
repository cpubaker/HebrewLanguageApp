import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/guide_screen.dart';
import 'package:hebrew_language_flutter/services/guide_progress_store.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';
import 'package:hebrew_language_flutter/services/verb_audio_player.dart';
import 'package:hebrew_language_flutter/services/word_progress_store.dart';

void main() {
  testWidgets('guide list allows marking a lesson as read', (
    WidgetTester tester,
  ) async {
    final guideStore = FakeGuideProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _GuideOnlyBundleLoader(),
        documentLoader: _GuideDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: guideStore,
        audioPlayerFactory: () => FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ще не читали'), findsOneWidget);

    await tester.tap(find.byTooltip('Позначити як прочитаний'));
    await tester.pumpAndSettle();

    expect(
      guideStore.readLessons,
      contains('assets/learning/input/guide/01_intro_alphabet.md'),
    );
    expect(find.text('Прочитано'), findsOneWidget);
    expect(find.byTooltip('Позначити як непрочитаний'), findsOneWidget);
  });

  testWidgets('guide lesson is marked as read after scrolling to the end', (
    WidgetTester tester,
  ) async {
    var markedRead = false;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
          ),
          documentLoader: _LongGuideDocumentLoader(),
          isRead: false,
          onReadChanged: (isRead) {
            markedRead = isRead;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Paragraph 80 about Hebrew grammar.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(markedRead, isTrue);
    expect(find.text('Прочитано'), findsOneWidget);
  });
}

class _GuideOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: [
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

class _LongGuideDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    final body = List<String>.generate(
      80,
      (index) => 'Paragraph ${index + 1} about Hebrew grammar.',
    ).join('\n\n');

    return LessonDocument(
      title: 'Long Lesson',
      body: body,
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

class FakeWordProgressStore implements WordProgressStore {
  @override
  Future<Map<String, StoredWordProgress>> load() async {
    return <String, StoredWordProgress>{};
  }

  @override
  Future<void> saveWord(LearningWord word) async {}
}

class FakeVerbAudioPlayer implements VerbAudioPlayer {
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
