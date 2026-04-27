import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/models/learning_word.dart';
import 'package:hebrew_language_flutter/screens/flashcards_screen.dart';
import 'package:hebrew_language_flutter/screens/writing_screen.dart';
import 'package:hebrew_language_flutter/services/learning_audio_player.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('flashcards autoplay and replay word audio', (tester) async {
    final audioPlayer = _FakeLearningAudioPlayer();

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
    final audioPlayer = _FakeLearningAudioPlayer();

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
}

class _FakeLearningAudioPlayer implements LearningAudioPlayer {
  final List<String> playedAssets = <String>[];

  @override
  Stream<bool> get isPlayingStream => const Stream<bool>.empty();

  @override
  Future<bool> assetExists(String assetPath) async => true;

  @override
  Future<bool> prepareAsset(String assetPath) async => true;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  Future<void> stop() async {}
}
