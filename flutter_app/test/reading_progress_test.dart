import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('reading list allows cycling lesson status manually', (
    WidgetTester tester,
  ) async {
    final readingStore = FakeReadingProgressStore();

    await pumpHebrewTestApp(
      tester,
      loader: _ReadingOnlyBundleLoader(),
      documentLoader: _ReadingDocumentLoader(),
      readingProgressStore: readingStore,
      audioPlayerFactory: () => FakeVerbAudioPlayer(),
    );

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Читання').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Читання').last);
    await tester.pumpAndSettle();

    expect(find.text('Не прочитано'), findsOneWidget);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(find.text('Вивчається'), findsWidgets);

    await tester.tap(find.byTooltip('Змінити статус уроку'));
    await tester.pumpAndSettle();

    expect(
      readingStore.lessonStatuses['yosi_goes_to_school'],
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
