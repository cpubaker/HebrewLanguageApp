import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class FlashcardProgressStrip extends StatelessWidget {
  const FlashcardProgressStrip({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.currentCardNumber,
    required this.wordCount,
    required this.sessionProgress,
  });

  final int correctCount;
  final int wrongCount;
  final int currentCardNumber;
  final int wordCount;
  final double sessionProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Row(
      children: [
        _StatBadge(
          icon: Icons.check_rounded,
          value: correctCount,
          color: tokens.successAccent,
        ),
        const SizedBox(width: 8),
        _StatBadge(
          icon: Icons.close_rounded,
          value: wrongCount,
          color: tokens.dangerAccent,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: sessionProgress.clamp(0.0, 1.0),
              backgroundColor: tokens.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.primaryAccent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currentCardNumber/$wordCount',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.accentMutedSurface(color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
