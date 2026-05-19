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
  final Map<String, _AvailabilityEntry> _availabilityCache =
      <String, _AvailabilityEntry>{};

  String? get activeAssetPath => _activeAssetPath;

  bool get isCheckingAvailability => _isCheckingAvailability;

  bool get hasAudio => _hasAudio;

  bool get isPlaying => _isPlaying;

  bool get isBusy => _isBusy;

  bool get canToggle => _hasAudio && !_isBusy;

  bool isPlayingFor(String? assetPath) {
    final normalized = _normalizeAssetPath(assetPath);
    return normalized != null &&
        _isPlaying &&
        _activeAssetPath == normalized;
  }

  bool isBusyFor(String? assetPath) {
    final normalized = _normalizeAssetPath(assetPath);
    return normalized != null && _isBusy && _activeAssetPath == normalized;
  }

  bool? cachedAvailabilityFor(String? assetPath) {
    final normalized = _normalizeAssetPath(assetPath);
    if (normalized == null) {
      return false;
    }
    return _availabilityCache[normalized]?.hasAudio;
  }

  bool isProbingAvailabilityFor(String? assetPath) {
    final normalized = _normalizeAssetPath(assetPath);
    if (normalized == null) {
      return false;
    }
    return _availabilityCache[normalized]?.pendingProbe != null;
  }

  Future<bool> probeAvailability(
    String? assetPath, {
    bool prepare = false,
  }) async {
    final normalized = _normalizeAssetPath(assetPath);
    if (normalized == null) {
      return false;
    }

    final existing = _availabilityCache[normalized];
    if (existing != null) {
      if (existing.pendingProbe != null) {
        return existing.pendingProbe!;
      }
      if (existing.hasAudio == false) {
        return false;
      }
      if (existing.hasAudio == true && (!prepare || existing.isPrepared)) {
        return true;
      }
    }

    final entry = existing ?? _AvailabilityEntry();
    _availabilityCache[normalized] = entry;

    final probe = _runAvailabilityProbe(normalized, prepare: prepare);
    entry.pendingProbe = probe;

    bool resolved;
    try {
      resolved = await probe;
    } catch (_) {
      resolved = false;
    }

    if (_isDisposed) {
      return resolved;
    }

    entry.hasAudio = resolved;
    entry.pendingProbe = null;
    if (resolved && prepare) {
      entry.isPrepared = true;
    }
    if (_activeAssetPath == normalized) {
      _hasAudio = resolved;
    }
    notifyListeners();
    return resolved;
  }

  void markUnavailableForPath(String? assetPath) {
    if (_isDisposed) {
      return;
    }
    final normalized = _normalizeAssetPath(assetPath);
    if (normalized == null) {
      return;
    }
    final entry = _availabilityCache[normalized] ?? _AvailabilityEntry();
    entry.hasAudio = false;
    entry.pendingProbe = null;
    entry.isPrepared = false;
    _availabilityCache[normalized] = entry;
    if (_activeAssetPath == normalized) {
      _hasAudio = false;
      _isCheckingAvailability = false;
    }
    notifyListeners();
  }

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
    if (_isBusy || normalizedAssetPath == null) {
      return;
    }

    final hasAudio = _hasAudioForPath(normalizedAssetPath);
    if (!hasAudio) {
      return;
    }

    final isResumingActive =
        _activeAssetPath == normalizedAssetPath && _isPlaying;

    final requestToken = _startRequest(
      normalizedAssetPath,
      checkingAvailability: false,
      clearAvailability: false,
      busy: true,
      hasAudio: true,
    );

    try {
      if (isResumingActive) {
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
        final stillAvailable = await _hasAvailableAudio(normalizedAssetPath);
        if (!_isCurrentRequest(requestToken) || !stillAvailable) {
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
    final activePath = _activeAssetPath;
    if (activePath != null) {
      final entry = _availabilityCache[activePath] ?? _AvailabilityEntry();
      entry.hasAudio = false;
      entry.pendingProbe = null;
      _availabilityCache[activePath] = entry;
    }
    notifyListeners();
  }

  void clearPlaying() {
    _setPlaying(false);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestToken += 1;
    _availabilityCache.clear();
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  int _startRequest(
    String? assetPath,
    {required bool checkingAvailability,
    required bool clearAvailability,
    bool? busy,
    bool? hasAudio,
    }) {
    final requestToken = ++_requestToken;
    _activeAssetPath = assetPath;
    _isCheckingAvailability = checkingAvailability;
    if (clearAvailability) {
      _hasAudio = false;
      if (assetPath != null) {
        final entry = _availabilityCache[assetPath] ?? _AvailabilityEntry();
        entry.hasAudio = null;
        _availabilityCache[assetPath] = entry;
      }
    } else if (hasAudio != null) {
      _hasAudio = hasAudio;
    } else if (assetPath != null) {
      _hasAudio = _availabilityCache[assetPath]?.hasAudio ?? _hasAudio;
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
      final activePath = _activeAssetPath;
      if (activePath != null) {
        final entry = _availabilityCache[activePath] ?? _AvailabilityEntry();
        entry.hasAudio = hasAudio;
        entry.pendingProbe = null;
        _availabilityCache[activePath] = entry;
      }
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

  Future<bool> _runAvailabilityProbe(
    String assetPath, {
    required bool prepare,
  }) {
    return _hasAvailableAudio(assetPath, prepare: prepare);
  }

  bool _hasAudioForPath(String assetPath) {
    final cached = _availabilityCache[assetPath]?.hasAudio;
    if (cached != null) {
      return cached;
    }
    return _activeAssetPath == assetPath && _hasAudio;
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

class _AvailabilityEntry {
  bool? hasAudio;
  bool isPrepared = false;
  Future<bool>? pendingProbe;
}
