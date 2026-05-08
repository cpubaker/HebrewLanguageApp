import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/repetition_screen.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('autoplays audio and advances one repetition card at a time', (
    tester,
  ) async {
    final audioFactory = FakeLearningAudioPlayerFactory();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: RepetitionScreen(
            words: const [
              LearningWord(
                wordId: 'word_book',
                hebrew: 'סֵפֶר',
                english: 'book',
                transcription: 'sefer',
                audioAssetPath: 'assets/learning/input/audio/words/book.mp3',
                correct: 1,
                wrong: 0,
                lastCorrect: '2026-04-19T08:00:00Z',
                lastReviewedAt: '2026-04-19T08:00:00Z',
                lastReviewCorrect: true,
                contexts: [
                  LearningContext(
                    contextId: 'ctx_book',
                    hebrew: 'הספר על השולחן.',
                    translation: 'The book is on the table.',
                  ),
                ],
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'בית',
                english: 'house',
                transcription: 'bayit',
                audioAssetPath: 'assets/learning/input/audio/words/house.mp3',
                correct: 1,
                wrong: 1,
                lastReviewedAt: '2026-04-19T09:00:00Z',
                lastReviewCorrect: false,
                contexts: [
                  LearningContext(
                    contextId: 'ctx_house',
                    hebrew: 'הבית גדול.',
                    translation: 'The house is big.',
                  ),
                ],
              ),
            ],
            audioPlayerFactory: audioFactory.create,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('house'), findsOneWidget);
    expect(find.text('book'), findsNothing);
    expect(find.text('1/2'), findsOneWidget);
    expect(
      audioFactory.primaryPlayer.playedAssets,
      contains('assets/learning/input/audio/words/house.mp3'),
    );

    await tester.tap(find.text('Далі'));
    await tester.pumpAndSettle();

    expect(find.text('house'), findsNothing);
    expect(find.text('book'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(
      audioFactory.primaryPlayer.playedAssets,
      contains('assets/learning/input/audio/words/book.mp3'),
    );

    await tester.tap(find.text('Завершити'));
    await tester.pumpAndSettle();

    expect(find.text('2 слів переглянуто'), findsOneWidget);
    expect(find.text('Почати ще раз'), findsOneWidget);
  });
}
