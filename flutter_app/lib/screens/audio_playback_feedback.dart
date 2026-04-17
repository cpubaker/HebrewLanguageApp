import 'package:flutter/material.dart';

import '../services/audio_playback_awareness.dart';

Future<void> showAudioPlaybackHintIfNeeded({
  required BuildContext context,
  required AudioPlaybackAwareness awareness,
}) async {
  final hint = await awareness.checkBeforePlayback();
  if (!context.mounted || hint == null) {
    return;
  }

  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(hint.message),
        duration: const Duration(seconds: 2),
      ),
    );
}
