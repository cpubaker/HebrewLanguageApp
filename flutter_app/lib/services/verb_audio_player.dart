import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

abstract class VerbAudioPlayer {
  Stream<bool> get isPlayingStream;
  Future<bool> assetExists(String assetPath);
  Future<bool> prepareAsset(String assetPath);
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
  Future<Set<String>>? _assetPathsFuture;
  String? _preparedAssetPath;

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

  Future<Set<String>> _loadAssetPaths() {
    return _assetPathsFuture ??=
        AssetManifest.loadFromAssetBundle(_assetBundle).then(
          (manifest) => manifest.listAssets().toSet(),
        );
  }
}
