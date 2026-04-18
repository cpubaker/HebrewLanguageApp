import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/writing_screen.dart';

void main() {
  testWidgets('constructor mode assembles a word and updates writing progress', (
    WidgetTester tester,
  ) async {
    LearningWord? updatedWord;
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (word) {
              updatedWord = word;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('writing_mode_constructor')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('של').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ום').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Перевірити'),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Перевірити'));
    await tester.pumpAndSettle();

    expect(updatedWord, isNotNull);
    expect(updatedWord!.wordId, 'word_peace');
    expect(updatedWord!.writingCorrect, 1);
    expect(updatedWord!.writingWrong, 0);
    expect(find.text('שלום'), findsOneWidget);
  });
}
