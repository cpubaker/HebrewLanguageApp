import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/guide_lesson_status.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/reading_lesson_catalog.dart';
import 'package:hebrew_language_flutter/screens/reading_screen.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';

void main() {
  test('groups and sorts reading lessons by level and order', () {
    final groups = buildReadingLessonGroups(const [
      LessonEntry(
        assetPath:
            'assets/learning/input/reading/advanced/01_neighborhood_library.md',
        displayName: '01 Neighborhood Library',
      ),
      LessonEntry(
        assetPath: 'assets/learning/input/reading/beginner/02_my_room.md',
        displayName: '02 My Room',
      ),
      LessonEntry(
        assetPath:
            'assets/learning/input/reading/intermediate/01_first_day_at_ulpan.md',
        displayName: '01 First Day At Ulpan',
      ),
      LessonEntry(
        assetPath:
            'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
        displayName: '01 Yosi Goes To School',
      ),
    ]);

    expect(groups.length, 3);
    expect(groups.first.lessons.map(readingLessonTitle).toList(growable: false), [
      'Yosi Goes To School',
      'My Room',
    ]);
  });

  testWidgets('filters reading lessons by selected levels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReadingScreen(
            lessons: const [
              LessonEntry(
                assetPath:
                    'assets/learning/input/reading/advanced/01_neighborhood_library.md',
                displayName: '01 Neighborhood Library',
              ),
              LessonEntry(
                assetPath:
                    'assets/learning/input/reading/beginner/02_my_room.md',
                displayName: '02 My Room',
              ),
              LessonEntry(
                assetPath:
                    'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
                displayName: '01 Yosi Goes To School',
              ),
            ],
            documentLoader: _FakeLessonDocumentLoader(),
            lessonStatuses: const <String, GuideLessonStatus>{},
            onStatusChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('My Room'), findsOneWidget);
    expect(find.text('Neighborhood Library'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .text(
            readingLevelLabelFromAssetPath(
              'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
            ),
          )
          .last,
    );
    await tester.pump();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('My Room'), findsOneWidget);
    expect(find.text('Neighborhood Library'), findsNothing);
  });

  testWidgets('reading lesson becomes studying when opened', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: ReadingDetailScreen(
          lesson: const LessonEntry(
            assetPath:
                'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
            displayName: '01 Yosi Goes To School',
          ),
          documentLoader: _FakeLessonDocumentLoader(),
          initialStatus: GuideLessonStatus.unread,
          onStatusChanged: (status) {
            latestStatus = status;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.studying);
  });

  testWidgets('reading lesson is marked as read after scrolling to the end', (
    WidgetTester tester,
  ) async {
    GuideLessonStatus? latestStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: ReadingDetailScreen(
          lesson: const LessonEntry(
            assetPath:
                'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
            displayName: '01 Yosi Goes To School',
          ),
          documentLoader: _LongReadingDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (status) {
            latestStatus = status;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Paragraph 80 about reading practice.'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(latestStatus, GuideLessonStatus.read);
  });

  testWidgets('reading detail opens glossary sheet for tapped phrase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReadingDetailScreen(
          lesson: const LessonEntry(
            assetPath:
                'assets/learning/input/reading/beginner/01_yosi_goes_to_school.md',
            displayName: '01 Yosi Goes To School',
          ),
          documentLoader: _GlossaryLessonDocumentLoader(),
          initialStatus: GuideLessonStatus.studying,
          onStatusChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final richTextFinder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == 'בֹּקֶר טוֹב!',
    );

    await tester.tapAt(tester.getTopRight(richTextFinder) + const Offset(-24, 12));
    await tester.pumpAndSettle();

    expect(find.text('доброго ранку'), findsOneWidget);
  });
}

class _FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    if (assetPath.contains('yosi_goes_to_school')) {
      return const LessonDocument(
        title: 'Yosi Goes To School',
        body: 'Stub',
      );
    }

    if (assetPath.contains('my_room')) {
      return const LessonDocument(
        title: 'My Room',
        body: 'Stub',
      );
    }

    if (assetPath.contains('neighborhood_library')) {
      return const LessonDocument(
        title: 'Neighborhood Library',
        body: 'Stub',
      );
    }

    return const LessonDocument(title: 'Stub', body: 'Stub');
  }
}

class _LongReadingDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    final body = List<String>.generate(
      80,
      (index) => 'Paragraph ${index + 1} about reading practice.',
    ).join('\n\n');

    return LessonDocument(
      title: 'Long Reading',
      body: body,
    );
  }
}

class _GlossaryLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(
      title: 'Glossary Reading',
      body: 'בֹּקֶר טוֹב!',
      glossary: <String, String>{
        'בֹּקֶר טוֹב': 'доброго ранку',
      },
    );
  }
}
