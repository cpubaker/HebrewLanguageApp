import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
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
  testWidgets('guide list allows cycling lesson status manually', (
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

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(find.text('Вивчається'), findsWidgets);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(
      guideStore.lessonStatuses['assets/learning/input/guide/01_intro_alphabet.md'],
      GuideLessonStatus.read,
    );
    expect(find.text('Прочитано'), findsWidgets);
  });

  testWidgets('guide lesson becomes studying when opened', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
          ),
          documentLoader: _GuideDocumentLoader(),
          initialStatus: GuideLessonStatus.unread,
          onStatusChanged: (status) {
            latestStatus = status;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.studying);
    expect(find.text('Вивчається'), findsWidgets);
  });

  testWidgets('guide lesson is marked as read after scrolling to the end', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: GuideDetailScreen(
          lesson: const LessonEntry(
            assetPath: 'assets/learning/input/guide/01_intro_alphabet.md',
            displayName: '01 Intro Alphabet',
          ),
          documentLoader: _LongGuideDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (status) {
            latestStatus = status;
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

    expect(latestStatus, GuideLessonStatus.read);
    expect(find.text('Прочитано'), findsWidgets);
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
    Map<String, GuideLessonStatus>? initialStatuses,
  }) : lessonStatuses = <String, GuideLessonStatus>{...?initialStatuses};

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
