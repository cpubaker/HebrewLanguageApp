import 'dart:async';

import 'package:flutter/foundation.dart';

import 'learning_audio_player.dart';

class LearningAudioController extends ChangeNotifier {
  LearningAudioController({
    required CreateLearningAudioPlayer audioPlayerFactory,
  }) : _audioPlayer = audioPlayerFactory() {
    _playbackSubscription = _audioPlayer.isPlayingStream.listen((isPlaying) {
      if (_isDisposed || _isPlaying == isPlaying) {
        return;
      }

      _isPlaying = isPlaying;
      notifyListeners();
    });
  }

  final LearningAudioPlayer _audioPlayer;
  StreamSubscription<bool>? _playbackSubscription;
  int _requestToken = 0;
  bool _isDisposed = false;
  String? _activeAssetPath;
  bool _isCheckingAvailability = false;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  String? get activeAssetPath => _activeAssetPath;

  bool get isCheckingAvailability => _isCheckingAvailability;

  bool get hasAudio => _hasAudio;

  bool get isPlaying => _isPlaying;

  bool get isBusy => _isBusy;

  bool get canToggle => _hasAudio && !_isBusy;

  Future<void> checkAvailability(
    String? assetPath, {
    bool prepare = false,
  }) async {
    final normalizedAssetPath = _normalizeAssetPath(assetPath);
    final requestToken = _startRequest(
      normalizedAssetPath,
      checkingAvailability: normalizedAssetPath != null,
      clearAvailability: true,
    );

    if (normalizedAssetPath == null) {
      _finishRequest(
        requestToken,
        checkingAvailability: false,
        hasAudio: false,
      );
      return;
    }

    final hasAudio = await _hasAvailableAudio(
      normalizedAssetPath,
      prepare: prepare,
    );

    _finishRequest(
      requestToken,
      checkingAvailability: false,
      hasAudio: hasAudio,
    );
  }

  Future<void> autoplay(String? assetPath, {bool prepare = false}) async {
    final normalizedAssetPath = _normalizeAssetPath(assetPath);
    final requestToken = _startRequest(
      normalizedAssetPath,
      checkingAvailability: false,
      clearAvailability: true,
    );

    await _stopPlayer();
    if (!_isCurrentRequest(requestToken) || normalizedAssetPath == null) {
      return;
    }

    final hasAudio = await _hasAvailableAudio(
      normalizedAssetPath,
      prepare: prepare,
    );
    if (!_isCurrentRequest(requestToken) || !hasAudio) {
      _finishRequest(requestToken, hasAudio: false);
      return;
    }

    _finishRequest(requestToken, hasAudio: true);

    try {
      await _audioPlayer.playAsset(normalizedAssetPath);
    } catch (_) {}
  }

  Future<void> stop({bool clearAvailability = false}) async {
    final requestToken = _startRequest(
      clearAvailability ? null : _activeAssetPath,
      checkingAvailability: false,
      clearAvailability: clearAvailability,
      busy: false,
    );

    await _stopPlayer();
    _finishRequest(
      requestToken,
      checkingAvailability: false,
      isPlaying: false,
      isBusy: false,
      hasAudio: clearAvailability ? false : null,
    );
  }

  Future<void> toggle(
    String? assetPath, {
    Future<void> Function()? beforePlay,
    bool clearPlayingAfterStop = false,
    bool recheckBeforePlay = false,
  }) async {
    final normalizedAssetPath = _normalizeAssetPath(assetPath);
    if (_isBusy || normalizedAssetPath == null || !_hasAudio) {
      return;
    }

    final requestToken = _startRequest(
      normalizedAssetPath,
      checkingAvailability: false,
      clearAvailability: false,
      busy: true,
    );

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        if (!_isCurrentRequest(requestToken)) {
          return;
        }
        if (clearPlayingAfterStop) {
          _setPlaying(false);
        }
        return;
      }

      await _audioPlayer.stop();
      if (!_isCurrentRequest(requestToken)) {
        return;
      }

      if (recheckBeforePlay) {
        final hasAudio = await _hasAvailableAudio(normalizedAssetPath);
        if (!_isCurrentRequest(requestToken) || !hasAudio) {
          _finishRequest(requestToken, hasAudio: false);
          return;
        }
      }

      if (beforePlay != null) {
        await beforePlay();
        if (!_isCurrentRequest(requestToken)) {
          return;
        }
      }

      await _audioPlayer.playAsset(normalizedAssetPath);
    } finally {
      _finishRequest(requestToken, isBusy: false);
    }
  }

  void markUnavailable() {
    if (_isDisposed) {
      return;
    }

    _hasAudio = false;
    _isCheckingAvailability = false;
    notifyListeners();
  }

  void clearPlaying() {
    _setPlaying(false);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestToken += 1;
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  int _startRequest(
    String? assetPath, {
    required bool checkingAvailability,
    required bool clearAvailability,
    bool? busy,
  }) {
    final requestToken = ++_requestToken;
    _activeAssetPath = assetPath;
    _isCheckingAvailability = checkingAvailability;
    if (clearAvailability) {
      _hasAudio = false;
    }
    if (busy != null) {
      _isBusy = busy;
    }
    _notifyIfActive();
    return requestToken;
  }

  void _finishRequest(
    int requestToken, {
    bool? checkingAvailability,
    bool? hasAudio,
    bool? isPlaying,
    bool? isBusy,
  }) {
    if (!_isCurrentRequest(requestToken)) {
      return;
    }

    if (checkingAvailability != null) {
      _isCheckingAvailability = checkingAvailability;
    }
    if (hasAudio != null) {
      _hasAudio = hasAudio;
    }
    if (isPlaying != null) {
      _isPlaying = isPlaying;
    }
    if (isBusy != null) {
      _isBusy = isBusy;
    }
    _notifyIfActive();
  }

  Future<bool> _hasAvailableAudio(
    String assetPath, {
    bool prepare = false,
  }) async {
    try {
      if (prepare) {
        return await _audioPlayer.prepareAsset(assetPath);
      }

      return await _audioPlayer.assetExists(assetPath);
    } catch (_) {
      return false;
    }
  }

  Future<void> _stopPlayer() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  bool _isCurrentRequest(int requestToken) {
    return !_isDisposed && _requestToken == requestToken;
  }

  void _setPlaying(bool isPlaying) {
    if (_isDisposed || _isPlaying == isPlaying) {
      return;
    }

    _isPlaying = isPlaying;
    notifyListeners();
  }

  void _notifyIfActive() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  String? _normalizeAssetPath(String? assetPath) {
    final normalized = assetPath?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
