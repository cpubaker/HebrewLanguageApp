import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/flashcards_screen.dart';
import 'package:hebrew_language_flutter/screens/widgets/flashcards/flashcard_answer_reveal.dart';
import 'package:hebrew_language_flutter/screens/widgets/flashcards/flashcard_prompt_panel.dart';
import 'package:hebrew_language_flutter/screens/widgets/flashcards/flashcard_states.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';

import 'support/app_test_harness.dart';
import 'support/fakes.dart';

void main() {
  testWidgets('shows hebrew prompt and tap hints for the first card', (
    WidgetTester tester,
  ) async {
    await _pumpFlashcardsScreen(
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

    expect(find.byType(FlashcardPromptPanel), findsOneWidget);
    expect(find.text('שלום'), findsOneWidget);
    expect(find.text('shalom'), findsOneWidget);
    expect(find.byType(FlashcardSwipeHintStrip), findsOneWidget);
    expect(find.text('Знаю'), findsOneWidget);
    expect(find.text('Ще раз'), findsOneWidget);
    expect(find.byType(FlashcardAnswerRevealCard), findsNothing);
  });

  testWidgets(
    'tapping the know hint reveals the translation and records a correct answer',
    (WidgetTester tester) async {
      final updatedWords = <LearningWord>[];

      await _pumpFlashcardsScreen(
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

      await tester.tap(find.text('Знаю'));
      await tester.pumpAndSettle();

      expect(updatedWords, hasLength(1));
      expect(updatedWords.single.wordId, 'word_peace');
      expect(updatedWords.single.correct, 1);
      expect(updatedWords.single.wrong, 0);
      expect(updatedWords.single.lastReviewCorrect, isTrue);

      expect(find.byType(FlashcardAnswerRevealCard), findsOneWidget);
      expect(find.text('мир'), findsOneWidget);
      expect(find.byType(FlashcardSwipeHintStrip), findsNothing);
    },
  );

  testWidgets(
    'tapping the repeat hint reveals the answer and records a wrong answer',
    (WidgetTester tester) async {
      final updatedWords = <LearningWord>[];

      await _pumpFlashcardsScreen(
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

      await tester.tap(find.text('Ще раз'));
      await tester.pumpAndSettle();

      expect(updatedWords, hasLength(1));
      expect(updatedWords.single.wordId, 'word_peace');
      expect(updatedWords.single.correct, 0);
      expect(updatedWords.single.wrong, 1);
      expect(updatedWords.single.lastReviewCorrect, isFalse);

      expect(find.byType(FlashcardAnswerRevealCard), findsOneWidget);
      expect(find.text('мир'), findsOneWidget);
    },
  );

  testWidgets('empty word list shows the placeholder state', (
    WidgetTester tester,
  ) async {
    await _pumpFlashcardsScreen(tester, words: const <LearningWord>[]);

    expect(find.byType(FlashcardEmptyState), findsOneWidget);
    expect(find.text('Картки'), findsOneWidget);
    expect(find.text('Слова ще не завантажені.'), findsOneWidget);
    expect(find.byType(FlashcardPromptPanel), findsNothing);
    expect(find.byType(FlashcardSwipeHintStrip), findsNothing);
  });

  testWidgets('completes the deck after answering and continuing the last card', (
    WidgetTester tester,
  ) async {
    await _pumpFlashcardsScreen(
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

    await tester.tap(find.text('Знаю'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlashcardAnswerRevealCard));
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardCompletedState), findsOneWidget);
    expect(find.text('1 карток пройдено'), findsOneWidget);
    expect(find.text('Почати ще раз'), findsOneWidget);
    expect(find.byType(FlashcardPromptPanel), findsNothing);
  });

  testWidgets('uses English labels when English is selected', (tester) async {
    await _pumpFlashcardsScreen(
      tester,
      locale: const Locale('en'),
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

    expect(find.text('Know it'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
  });
}

Future<void> _pumpFlashcardsScreen(
  WidgetTester tester, {
  required List<LearningWord> words,
  void Function(LearningWord word)? onWordProgressChanged,
  CreateLearningAudioPlayer? audioPlayerFactory,
  Locale locale = const Locale('uk'),
}) async {
  await useTallMobileViewport(tester);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FlashcardsScreen(
          words: words,
          onWordProgressChanged: onWordProgressChanged ?? (_) {},
          audioPlayerFactory: audioPlayerFactory ?? FakeLearningAudioPlayer.new,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
