import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/models/lesson_document.dart';
import 'package:hebrew_language_flutter/screens/home_screen.dart';
import 'package:hebrew_language_flutter/services/feature_access_service.dart';
import 'package:hebrew_language_flutter/services/flashcard_session.dart';
import 'package:hebrew_language_flutter/services/lesson_document_loader.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('shows the word of the day on the home screen', (tester) async {
    FlashcardDeckMode? openedDeckMode;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: HomeScreen(
            bundle: const LearningBundle(
              words: [
                LearningWord(
                  wordId: 'word_plain',
                  hebrew: 'plain',
                  english: 'plain',
                  transcription: 'plain',
                  correct: 0,
                  wrong: 0,
                ),
                LearningWord(
                  wordId: 'word_dog',
                  hebrew: 'kelev',
                  english: 'dog',
                  ukrainian: 'pes',
                  transcription: 'kelev',
                  correct: 0,
                  wrong: 0,
                  contexts: [
                    LearningContext(
                      contextId: 'ctx_dog',
                      hebrew: 'dog context',
                      translation: 'dog translation',
                    ),
                  ],
                ),
              ],
              guideLessons: [],
              verbLessons: [],
              readingLessons: [],
            ),
            documentLoader: _FakeLessonDocumentLoader(),
            isDarkMode: false,
            nightModeAccess: const FeatureAccessDecision(
              feature: AppFeature.nightMode,
              isEnabled: true,
              title: 'Night mode',
              description: 'Night mode is available.',
            ),
            onToggleThemeMode: () {},
            onOpenWords: () {},
            onOpenFlashcards: (mode) {
              openedDeckMode = mode;
            },
            onOpenWriting: () {},
            onOpenSprint: () {},
            onOpenGuide: () {},
            onOpenVerbs: () {},
            onOpenReading: () {},
            onOpenReadingLesson: (_) {},
            wordOfDayDateProvider: () => DateTime.utc(2026, 3, 27),
          ),
        ),
      ),
    );

    expect(find.text('Слово дня'), findsOneWidget);
    expect(find.text('kelev'), findsWidgets);
    expect(find.text('pes'), findsOneWidget);
    expect(find.text('dog context'), findsOneWidget);
    expect(find.text('dog translation'), findsOneWidget);

    final flashcardsButton = find.widgetWithText(OutlinedButton, 'До карток');
    await tester.ensureVisible(flashcardsButton);
    await tester.pumpAndSettle();
    await tester.tap(flashcardsButton);
    await tester.pump();

    expect(openedDeckMode, FlashcardDeckMode.withContexts);
  });
}

class _FakeLessonDocumentLoader implements LessonDocumentLoader {
  @override
  Future<LessonDocument> load(String assetPath) async {
    return const LessonDocument(title: 'Title', body: 'Body');
  }
}
