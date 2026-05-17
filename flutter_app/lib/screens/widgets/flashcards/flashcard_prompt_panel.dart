import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class FlashcardPromptPanel extends StatelessWidget {
  const FlashcardPromptPanel({
    super.key,
    required this.hebrew,
    required this.transcription,
    this.audioButton,
  });

  final String hebrew;
  final String transcription;
  final Widget? audioButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.practicePromptGradientStart,
            tokens.practicePromptGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Спробуйте згадати переклад',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.mutedText,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hebrew,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transcription,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.secondaryText,
            ),
          ),
          if (audioButton != null) ...[
            const SizedBox(height: 12),
            audioButton!,
          ],
        ],
      ),
    );
  }
}
