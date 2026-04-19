import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_context.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/repetition_screen.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('shows one repetition card at a time and advances on tap', (
    tester,
  ) async {
    final audioPlayer = _FakeLearningAudioPlayer();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: RepetitionScreen(
            words: const [
              LearningWord(
                wordId: 'word_book',
                hebrew: 'ЧЎЧ¤ЧЁ',
                english: 'book',
                transcription: 'sefer',
                correct: 1,
                wrong: 0,
                lastCorrect: '2026-04-19T08:00:00Z',
                lastReviewedAt: '2026-04-19T08:00:00Z',
                lastReviewCorrect: true,
                contexts: [
                  LearningContext(
                    contextId: 'ctx_book',
                    hebrew: 'Ч”ЧЎЧ¤ЧЁ ЧђЧњ Ч”Ч©Ч•ЧњЧ—Чџ.',
                    translation: 'The book is on the table.',
                  ),
                ],
              ),
              LearningWord(
                wordId: 'word_house',
                hebrew: 'Ч‘Ч™ЧЄ',
                english: 'house',
                transcription: 'bayit',
                correct: 1,
                wrong: 1,
                lastReviewedAt: '2026-04-19T09:00:00Z',
                lastReviewCorrect: false,
                contexts: [
                  LearningContext(
                    contextId: 'ctx_house',
                    hebrew: 'Ч”Ч‘Ч™ЧЄ Ч’Ч“Ч•Чњ.',
                    translation: 'The house is big.',
                  ),
                ],
              ),
            ],
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );

    expect(find.text('house'), findsOneWidget);
    expect(find.text('book'), findsNothing);
    expect(find.text('1/2'), findsOneWidget);

    await tester.tap(find.text('Далі'));
    await tester.pumpAndSettle();

    expect(find.text('house'), findsNothing);
    expect(find.text('book'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);

    await tester.tap(find.text('Завершити'));
    await tester.pumpAndSettle();

    expect(find.text('2 слів переглянуто'), findsOneWidget);
    expect(find.text('Почати ще раз'), findsOneWidget);
  });
}

class _FakeLearningAudioPlayer implements LearningAudioPlayer {
  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => true;

  @override
  Future<bool> prepareAsset(String assetPath) async => true;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}
}
