import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hebrew_language_flutter/app.dart';
import 'package:hebrew_language_flutter/models/learning_bundle.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
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
      readingLessons: const [],
    );
  }
}

void main() {
  testWidgets('supports bottom navigation and word search', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HebrewFlutterApp(loader: FakeLearningBundleLoader()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hebrew Language App'), findsOneWidget);
    expect(find.text('Android Migration'), findsOneWidget);
    expect(find.text('Open Words'), findsOneWidget);

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
}
