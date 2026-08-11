import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
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
        content: Text(
          switch (hint.kind) {
            AudioPlaybackHintKind.mediaVolumeMuted =>
              AppLocalizations.of(context).audioVolumeMuted,
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}
