import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioPlaybackHint {
  const AudioPlaybackHint({required this.message});

  static const AudioPlaybackHint mediaVolumeMuted = AudioPlaybackHint(
    message:
        'Звук вимкнений. Підніміть гучність медіа кнопками збоку.',
  );

  final String message;
}

abstract class AudioPlaybackAwareness {
  Future<AudioPlaybackHint?> checkBeforePlayback();
}

typedef CreateAudioPlaybackAwareness = AudioPlaybackAwareness Function();

AudioPlaybackAwareness createAudioPlaybackAwareness() {
  if (kIsWeb) {
    return const NoopAudioPlaybackAwareness();
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return AndroidAudioPlaybackAwareness();
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return const NoopAudioPlaybackAwareness();
  }
}

class NoopAudioPlaybackAwareness implements AudioPlaybackAwareness {
  const NoopAudioPlaybackAwareness();

  @override
  Future<AudioPlaybackHint?> checkBeforePlayback() async => null;
}

class AndroidAudioPlaybackAwareness implements AudioPlaybackAwareness {
  AndroidAudioPlaybackAwareness({
    MethodChannel? channel,
    DateTime Function()? now,
    Duration? mutedVolumeHintCooldown,
  }) : _channel = channel ?? _defaultChannel,
       _now = now ?? DateTime.now,
       _mutedVolumeHintCooldown =
           mutedVolumeHintCooldown ?? const Duration(minutes: 5);

  static const MethodChannel _defaultChannel = MethodChannel(
    'com.nedash.hebrewlanguageapp/audio_output',
  );

  final MethodChannel _channel;
  final DateTime Function() _now;
  final Duration _mutedVolumeHintCooldown;

  DateTime? _lastMutedVolumeHintAt;

  @override
  Future<AudioPlaybackHint?> checkBeforePlayback() async {
    try {
      final isMediaVolumeMuted =
          await _channel.invokeMethod<bool>('isMediaVolumeMuted') ?? false;
      if (!isMediaVolumeMuted) {
        return null;
      }

      final now = _now();
      final lastHintAt = _lastMutedVolumeHintAt;
      if (lastHintAt != null &&
          !now.isBefore(lastHintAt) &&
          now.difference(lastHintAt) < _mutedVolumeHintCooldown) {
        return null;
      }

      _lastMutedVolumeHintAt = now;
      return AudioPlaybackHint.mediaVolumeMuted;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
