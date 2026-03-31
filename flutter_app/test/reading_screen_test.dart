import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(
      groups.map((group) => group.levelLabel).toList(growable: false),
      ['Beginner', 'Intermediate', 'Advanced'],
    );
    expect(
      groups.first.lessons.map(readingLessonTitle).toList(growable: false),
      ['Yosi Goes To School', 'My Room'],
    );
  });

  testWidgets('filters reading lessons by selected level', (
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
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level'));
    await tester.pumpAndSettle();

    expect(find.text('Choose reading level'), findsOneWidget);

    await tester.tap(find.text('Beginner').last);
    await tester.pumpAndSettle();

    expect(find.text('2 reading lessons shown'), findsOneWidget);
    expect(find.text('Beginner (2)'), findsOneWidget);
    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('My Room'), findsOneWidget);
    expect(find.text('Neighborhood Library'), findsNothing);
  });
}

class _FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(title: 'Stub', body: 'Stub');
  }
}
