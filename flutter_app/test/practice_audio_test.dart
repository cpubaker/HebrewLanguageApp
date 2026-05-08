import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/flashcards_screen.dart';
import 'package:hebrew_language_flutter/screens/writing_screen.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('flashcards autoplay and replay word audio', (tester) async {
    final audioPlayer = FakeLearningAudioPlayer();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: FlashcardsScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                audioAssetPath: 'assets/audio/shalom.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('flashcards_audio_button')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, [
      'assets/audio/shalom.mp3',
      'assets/audio/shalom.mp3',
    ]);
  });

  testWidgets('writing practice autoplay and replay word audio', (
    tester,
  ) async {
    final audioPlayer = FakeLearningAudioPlayer();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: WritingScreen(
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: 'שלום',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                audioAssetPath: 'assets/audio/shalom.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);

    await tester.tap(find.byKey(const ValueKey('writing_audio_button')));
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, [
      'assets/audio/shalom.mp3',
      'assets/audio/shalom.mp3',
    ]);
  });

  testWidgets('constructor audio starts after checking the answer', (
    tester,
  ) async {
    final audioPlayer = FakeLearningAudioPlayer();
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: WritingScreen(
            initialMode: WritingPracticeMode.constructor,
            words: const [
              LearningWord(
                wordId: 'word_peace',
                hebrew: '\u05e9\u05dc\u05d5\u05dd',
                english: 'peace',
                ukrainian: 'мир',
                transcription: 'shalom',
                audioAssetPath: 'assets/audio/shalom.mp3',
                correct: 0,
                wrong: 0,
              ),
            ],
            onWordProgressChanged: (_) {},
            audioPlayerFactory: () => audioPlayer,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, isEmpty);
    expect(find.byKey(const ValueKey('writing_audio_button')), findsNothing);

    await tester.tap(find.text('\u05e9\u05dc').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('\u05d5\u05dd').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check_rounded).last);
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, ['assets/audio/shalom.mp3']);
    expect(find.byKey(const ValueKey('writing_audio_button')), findsNothing);
    expect(
      find.byKey(const ValueKey('constructor_result_audio_button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('constructor_result_audio_button')),
    );
    await tester.pump();
    await tester.pump();

    expect(audioPlayer.playedAssets, [
      'assets/audio/shalom.mp3',
      'assets/audio/shalom.mp3',
    ]);
  });
}
