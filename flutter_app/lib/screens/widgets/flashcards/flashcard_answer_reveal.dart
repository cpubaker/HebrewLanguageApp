import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class FlashcardAnswerRevealCard extends StatelessWidget {
  const FlashcardAnswerRevealCard({
    super.key,
    required this.isKnownAnswer,
    required this.translation,
  });

  final bool isKnownAnswer;
  final String translation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final background = isKnownAnswer
        ? tokens.successSurface
        : tokens.warningSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            translation,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (!isKnownAnswer) ...[
            const SizedBox(height: 8),
            Text(
              'Нічого, повернемося до нього ще раз трохи пізніше.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FlashcardSwipeHintStrip extends StatelessWidget {
  const FlashcardSwipeHintStrip({
    super.key,
    required this.onRepeatTap,
    required this.onKnowTap,
  });

  final VoidCallback onRepeatTap;
  final VoidCallback onKnowTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Row(
      children: [
        Expanded(
          child: _FlashcardSwipeHintCard(
            alignment: CrossAxisAlignment.start,
            icon: Icons.arrow_back_rounded,
            label: 'Ще раз',
            accent: tokens.warningAccent,
            onTap: onRepeatTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FlashcardSwipeHintCard(
            alignment: CrossAxisAlignment.end,
            icon: Icons.arrow_forward_rounded,
            label: 'Знаю',
            accent: tokens.successAccent,
            onTap: onKnowTap,
          ),
        ),
      ],
    );
  }
}

class _FlashcardSwipeHintCard extends StatelessWidget {
  const _FlashcardSwipeHintCard({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final CrossAxisAlignment alignment;
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final isTrailing = alignment == CrossAxisAlignment.end;
    final iconBadge = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: tokens.accentMutedSurface(accent),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.accentStrongBorder(accent)),
      ),
      child: Icon(icon, color: accent, size: 21),
    );
    final labelText = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isTrailing ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.titleSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? tokens.accentBorder(accent)
                : tokens.accentSubtleSurface(accent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: isTrailing
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!isTrailing) ...[iconBadge, const SizedBox(width: 10)],
              labelText,
              if (isTrailing) ...[const SizedBox(width: 10), iconBadge],
            ],
          ),
        ),
      ),
    );
  }
}
