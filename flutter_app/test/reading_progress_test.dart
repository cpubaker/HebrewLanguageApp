import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('reading list allows cycling lesson status manually', (
    WidgetTester tester,
  ) async {
    final readingStore = FakeReadingProgressStore();

    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _ReadingOnlyBundleLoader(),
        documentLoader: _ReadingDocumentLoader(),
        progressStore: FakeWordProgressStore(),
        guideProgressStore: FakeGuideProgressStore(),
        readingProgressStore: readingStore,
        audioPlayerFactory: () => FakeVerbAudioPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(find.text('Вивчається'), findsWidgets);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(
      readingStore.lessonStatuses[
        'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md'
      ],
      GuideLessonStatus.read,
    );
    expect(find.text('Прочитано'), findsWidgets);
  });
}

class _ReadingOnlyBundleLoader implements LearningBundleLoader {
  @override
  Future<LearningBundle> load() async {
    return const LearningBundle(
      words: <LearningWord>[],
      guideLessons: <LessonEntry>[],
      verbLessons: <LessonEntry>[],
      readingLessons: [
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

class FakeGuideProgressStore implements GuideProgressStore {
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

class FakeReadingProgressStore implements ReadingProgressStore {
  FakeReadingProgressStore({
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
  Future<bool> prepareAsset(String assetPath) async => false;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
