import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

abstract class VerbAudioPlayer {
  Stream<bool> get isPlayingStream;
  Future<bool> assetExists(String assetPath);
  Future<void> playAsset(String assetPath);
  Future<void> stop();
  Future<void> dispose();
}

typedef CreateVerbAudioPlayer = VerbAudioPlayer Function();

VerbAudioPlayer createAssetVerbAudioPlayer() => AssetVerbAudioPlayer();

class AssetVerbAudioPlayer implements VerbAudioPlayer {
  AssetVerbAudioPlayer({
    AssetBundle? assetBundle,
    AudioPlayer? player,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _player = player ?? AudioPlayer();

  final AssetBundle _assetBundle;
  final AudioPlayer _player;

  @override
  Stream<bool> get isPlayingStream => _player.playerStateStream
      .map(
        (state) =>
            state.playing && state.processingState != ProcessingState.completed,
      )
      .distinct();

  @override
  Future<bool> assetExists(String assetPath) async {
    try {
      await _assetBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> playAsset(String assetPath) async {
    await _player.setAsset(assetPath);
    unawaited(_player.play());
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
