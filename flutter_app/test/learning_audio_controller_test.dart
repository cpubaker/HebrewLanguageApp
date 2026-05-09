import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/learning_audio_controller.dart';

import 'support/fakes.dart';

void main() {
  test('checks and prepares audio availability', () async {
    final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: true);
    final controller = LearningAudioController(
      audioPlayerFactory: () => audioPlayer,
    );
    addTearDown(controller.dispose);

    await controller.checkAvailability('assets/audio/word.mp3', prepare: true);

    expect(controller.hasAudio, isTrue);
    expect(controller.isCheckingAvailability, isFalse);
    expect(audioPlayer.preparedAssets, ['assets/audio/word.mp3']);
    expect(audioPlayer.playedAssets, isEmpty);
  });

  test('autoplays an available asset and ignores a missing asset', () async {
    final audioPlayer = FakeLearningAudioPlayer(
      availableAssets: const {'assets/audio/word.mp3'},
    );
    final controller = LearningAudioController(
      audioPlayerFactory: () => audioPlayer,
    );
    addTearDown(controller.dispose);

    await controller.autoplay('assets/audio/word.mp3');
    await controller.autoplay('assets/audio/missing.mp3');

    expect(controller.hasAudio, isFalse);
    expect(audioPlayer.playedAssets, ['assets/audio/word.mp3']);
  });

  test('toggle runs the pre-play hook and plays the active asset', () async {
    final audioPlayer = FakeLearningAudioPlayer(assetExistsResult: true);
    final controller = LearningAudioController(
      audioPlayerFactory: () => audioPlayer,
    );
    addTearDown(controller.dispose);

    var beforePlayCalled = false;
    await controller.checkAvailability('assets/audio/word.mp3');
    await controller.toggle(
      'assets/audio/word.mp3',
      beforePlay: () async {
        beforePlayCalled = true;
      },
    );

    expect(beforePlayCalled, isTrue);
    expect(controller.isBusy, isFalse);
    expect(audioPlayer.playedAssets, ['assets/audio/word.mp3']);
  });
}
