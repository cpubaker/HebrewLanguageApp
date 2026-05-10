import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

abstract class LearningAudioPlayer {
  Stream<bool> get isPlayingStream;
  Future<bool> assetExists(String assetPath);
  Future<bool> prepareAsset(String assetPath);
  Future<void> playAsset(String assetPath);
  Future<void> stop();
  Future<void> dispose();
}

typedef CreateLearningAudioPlayer = LearningAudioPlayer Function();

LearningAudioPlayer createAssetLearningAudioPlayer() =>
    AssetLearningAudioPlayer();

class AssetLearningAudioPlayer implements LearningAudioPlayer {
  AssetLearningAudioPlayer({AssetBundle? assetBundle, AudioPlayer? player})
    : _assetBundle = assetBundle ?? rootBundle,
      _player = player ?? AudioPlayer();

  static const Duration _coldStartPrerollDuration = Duration(milliseconds: 220);
  static const Duration _coldStartWaitTimeout = Duration(milliseconds: 600);

  final AssetBundle _assetBundle;
  final AudioPlayer _player;
  Future<Set<String>>? _assetPathsFuture;
  String? _preparedAssetPath;
  bool _hasPrimedOutput = false;

  @override
  Stream<bool> get isPlayingStream => _player.playerStateStream
      .map(
        (state) =>
            state.playing && state.processingState != ProcessingState.completed,
      )
      .distinct();

  @override
  Future<bool> assetExists(String assetPath) async {
    final assetPaths = await _loadAssetPaths();
    return assetPaths.contains(assetPath);
  }

  @override
  Future<bool> prepareAsset(String assetPath) async {
    if (!await assetExists(assetPath)) {
      return false;
    }

    if (_preparedAssetPath == assetPath) {
      return true;
    }

    await _player.setAsset(assetPath);
    _preparedAssetPath = assetPath;
    return true;
  }

  @override
  Future<void> playAsset(String assetPath) async {
    final prepared = await prepareAsset(assetPath);
    if (!prepared) {
      throw StateError('Audio asset not found: $assetPath');
    }

    await _primeOutputForColdStart();
    await _player.seek(Duration.zero);
    unawaited(_player.play());
  }

  @override
  Future<void> stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _primeOutputForColdStart() async {
    if (_hasPrimedOutput) {
      return;
    }

    _hasPrimedOutput = true;
    final previousVolume = _player.volume;
    try {
      await _player.setVolume(0);
      await _player.seek(Duration.zero);
      unawaited(_player.play().catchError((_) {}));
      await _waitForPlaybackToStart();
      await Future<void>.delayed(_coldStartPrerollDuration);
      await _player.pause();
      await _player.seek(Duration.zero);
    } finally {
      await _player.setVolume(previousVolume);
    }
  }

  Future<void> _waitForPlaybackToStart() async {
    if (_player.playing) {
      return;
    }

    await _player.playingStream
        .firstWhere((isPlaying) => isPlaying)
        .timeout(_coldStartWaitTimeout, onTimeout: () => false);
  }

  Future<Set<String>> _loadAssetPaths() {
    return _assetPathsFuture ??= AssetManifest.loadFromAssetBundle(
      _assetBundle,
    ).then((manifest) => manifest.listAssets().toSet());
  }
}
