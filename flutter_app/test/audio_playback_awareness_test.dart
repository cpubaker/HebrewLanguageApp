import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/audio_playback_awareness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.nedash.hebrewlanguageapp/audio_output');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('returns a muted-volume hint once within the cooldown window', () async {
    var now = DateTime(2026, 4, 17, 12);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'isMediaVolumeMuted');
          return true;
        });

    final awareness = AndroidAudioPlaybackAwareness(
      channel: channel,
      now: () => now,
      mutedVolumeHintCooldown: const Duration(minutes: 5),
    );

    final firstHint = await awareness.checkBeforePlayback();
    final secondHint = await awareness.checkBeforePlayback();

    now = now.add(const Duration(minutes: 6));
    final thirdHint = await awareness.checkBeforePlayback();

    expect(firstHint?.message, AudioPlaybackHint.mediaVolumeMuted.message);
    expect(secondHint, isNull);
    expect(thirdHint?.message, AudioPlaybackHint.mediaVolumeMuted.message);
  });

  test('returns null when media volume is available', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => false);

    final awareness = AndroidAudioPlaybackAwareness(channel: channel);

    expect(await awareness.checkBeforePlayback(), isNull);
  });
}
