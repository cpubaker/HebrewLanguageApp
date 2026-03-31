import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/services/learning_bundle_loader.dart';

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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('01 Intro Alphabet'), findsOneWidget);

    await tester.tap(find.text('01 Intro Alphabet'));
    await tester.pumpAndSettle();

    expect(find.text('Alphabet Basics'), findsOneWidget);
    expect(find.text('First concept'), findsOneWidget);
    expect(find.text('Hebrew is read from right to left.'), findsOneWidget);
  });

  testWidgets('opens verb lesson details', (WidgetTester tester) async {
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FakeBundleWithVerbLoader(),
        documentLoader: FakeLessonDocumentLoader(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_lesson_outlined));
    await tester.pumpAndSettle();

    expect(find.text('01 Walk'), findsOneWidget);

    await tester.tap(find.text('01 Walk'));
    await tester.pumpAndSettle();

    expect(find.text('Walk'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Audio wiring is the next media step.'),
      300,
    );
    await tester.pumpAndSettle();
    expect(find.text('Audio wiring is the next media step.'), findsOneWidget);
  });

  testWidgets('opens reading lesson details', (WidgetTester tester) async {
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: FakeLearningBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();

    expect(find.text('01 Yosi Goes To School'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);

    await tester.tap(find.text('01 Yosi Goes To School'));
    await tester.pumpAndSettle();

    expect(find.text('Yosi Goes To School'), findsOneWidget);
    expect(find.text('Key words'), findsOneWidget);
    expect(find.text('school'), findsOneWidget);
  });

  testWidgets('reveals flashcard answer and advances to the next card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HebrewFlutterApp(
        loader: _FlashcardOnlyBundleLoader(),
        documentLoader: FakeLessonDocumentLoader(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Flashcards'), findsOneWidget);
    expect(find.text('האיש הולך ברחוב.'), findsOneWidget);
    expect(find.text('man'), findsNothing);

    await tester.scrollUntilVisible(find.text('Know'), 200);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Know'));
    await tester.pumpAndSettle();

    expect(find.text('man'), findsOneWidget);
    expect(find.text('The man is walking in the street.'), findsOneWidget);
    expect(find.text('Next Card'), findsOneWidget);
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
