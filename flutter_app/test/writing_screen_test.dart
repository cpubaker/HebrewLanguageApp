import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/widgets/practice_feedback_card.dart';
import 'package:hebrew_language_flutter/screens/writing_screen.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('typing mode shows the prompt text and the answer text field', (
    WidgetTester tester,
  ) async {
    await _pumpWritingScreen(
      tester,
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
    );

    expect(find.text('Слово для перекладу'), findsOneWidget);
    expect(find.text('мир'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Введіть слово івритом'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Перевірити'), findsOneWidget);

    final nextButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Далі'),
    );
    expect(nextButton.onPressed, isNull);
    expect(find.byType(PracticeFeedbackCard), findsNothing);
  });

  testWidgets(
    'submitting the correct hebrew answer marks the word as written correctly',
    (WidgetTester tester) async {
      final updatedWords = <LearningWord>[];

      await _pumpWritingScreen(
        tester,
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
        onWordProgressChanged: updatedWords.add,
      );

      await tester.enterText(find.byType(TextField), 'שלום');
      await tester.tap(find.widgetWithText(FilledButton, 'Перевірити'));
      await tester.pumpAndSettle();

      expect(updatedWords, hasLength(1));
      expect(updatedWords.single.wordId, 'word_peace');
      expect(updatedWords.single.writingCorrect, 1);
      expect(updatedWords.single.writingWrong, 0);
      expect(updatedWords.single.lastReviewCorrect, isTrue);

      expect(find.byType(PracticeFeedbackCard), findsOneWidget);
      expect(find.text('Правильно'), findsOneWidget);
      expect(
        find.text('Нічого страшного. Повернемось до цього слова пізніше.'),
        findsNothing,
      );

      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Перевірити'),
      );
      expect(submitButton.onPressed, isNull);

      final nextButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Далі'),
      );
      expect(nextButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'submitting a wrong hebrew answer reveals the correct word and records a mistake',
    (WidgetTester tester) async {
      final updatedWords = <LearningWord>[];

      await _pumpWritingScreen(
        tester,
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
        onWordProgressChanged: updatedWords.add,
      );

      await tester.enterText(find.byType(TextField), 'בית');
      await tester.tap(find.widgetWithText(FilledButton, 'Перевірити'));
      await tester.pumpAndSettle();

      expect(updatedWords, hasLength(1));
      expect(updatedWords.single.writingCorrect, 0);
      expect(updatedWords.single.writingWrong, 1);
      expect(updatedWords.single.lastReviewCorrect, isFalse);

      expect(find.byType(PracticeFeedbackCard), findsOneWidget);
      expect(find.text('Ось правильний варіант'), findsOneWidget);
      expect(
        find.text('Нічого страшного. Повернемось до цього слова пізніше.'),
        findsOneWidget,
      );
      expect(find.text('Правильно'), findsNothing);
    },
  );

  testWidgets(
    'submitting an empty answer shows the inline reminder without changing stats',
    (WidgetTester tester) async {
      final updatedWords = <LearningWord>[];

      await _pumpWritingScreen(
        tester,
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
        onWordProgressChanged: updatedWords.add,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Перевірити'));
      await tester.pumpAndSettle();

      expect(updatedWords, isEmpty);
      expect(
        find.text('Введіть слово івритом, щоб перевірити відповідь.'),
        findsOneWidget,
      );
      expect(find.byType(PracticeFeedbackCard), findsNothing);

      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Перевірити'),
      );
      expect(submitButton.onPressed, isNotNull);
    },
  );

  testWidgets('empty word list shows the writing empty state', (
    WidgetTester tester,
  ) async {
    await _pumpWritingScreen(tester, words: const <LearningWord>[]);

    expect(find.text('Написання'), findsOneWidget);
    expect(
      find.textContaining('Щойно у наборі з’являться доступні слова'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Перевірити'), findsNothing);
  });
}

Future<void> _pumpWritingScreen(
  WidgetTester tester, {
  required List<LearningWord> words,
  void Function(LearningWord word)? onWordProgressChanged,
  CreateLearningAudioPlayer? audioPlayerFactory,
}) async {
  await useTallMobileViewport(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WritingScreen(
          words: words,
          onWordProgressChanged: onWordProgressChanged ?? (_) {},
          audioPlayerFactory: audioPlayerFactory ?? FakeLearningAudioPlayer.new,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
