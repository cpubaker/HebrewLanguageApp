import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/writing_screen.dart';

void main() {
  testWidgets(
    'constructor mode assembles a word and updates writing progress',
    (WidgetTester tester) async {
      LearningWord? updatedWord;
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WritingScreen(
              initialMode: WritingPracticeMode.constructor,
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

      await tester.tap(find.text('של').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ום').first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Перевірити'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Не знаю'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Перевірити'), findsNothing);

      final errorsLeft = tester.getTopLeft(find.textContaining('Помилки')).dx;
      final correctLeft = tester.getTopLeft(find.textContaining('Вірно')).dx;
      expect(errorsLeft, lessThan(correctLeft));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Перевірити'));
      await tester.pumpAndSettle();

      expect(updatedWord, isNotNull);
      expect(updatedWord!.wordId, 'word_peace');
      expect(updatedWord!.writingCorrect, 1);
      expect(updatedWord!.writingWrong, 0);
      expect(find.text('Доступні блоки'), findsNothing);
      expect(find.text('Правильно'), findsOneWidget);
      expect(find.text('שלום'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Далі'));
      await tester.pumpAndSettle();

      expect(find.text('Доступні блоки'), findsOneWidget);
    },
  );

  testWidgets('constructor mode unknown button records a writing mistake', (
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
            initialMode: WritingPracticeMode.constructor,
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

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Не знаю'),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Не знаю'));
    await tester.pumpAndSettle();

    expect(updatedWord, isNotNull);
    expect(updatedWord!.writingCorrect, 0);
    expect(updatedWord!.writingWrong, 1);
    expect(find.text('Ось правильний варіант'), findsOneWidget);
    expect(find.text('שלום'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Далі'), findsOneWidget);
  });
}
