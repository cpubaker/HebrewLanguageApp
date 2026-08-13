import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
class PracticeAudioButton extends StatelessWidget {
  const PracticeAudioButton({
    super.key,
    required this.isBusy,
    required this.isPlaying,
    required this.onPressed,
    this.tooltip,
  });

  final bool isBusy;
  final bool isPlaying;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip ?? AppLocalizations.of(context).audioPlay,
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isPlaying ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
            ),
    );
  }
}
