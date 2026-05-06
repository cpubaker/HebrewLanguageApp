import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'practice_stat_pill.dart';

enum PracticeCompletionActionStyle { filled, outlined }

class PracticeCompletionStat {
  const PracticeCompletionStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;
}

class PracticeCompletionAction {
  const PracticeCompletionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = PracticeCompletionActionStyle.filled,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final PracticeCompletionActionStyle style;
}

class PracticeCompletionCard extends StatelessWidget {
  const PracticeCompletionCard({
    super.key,
    required this.badgeLabel,
    required this.title,
    required this.stats,
    required this.primaryAction,
    this.body,
    this.secondaryAction,
    this.padding = const EdgeInsets.all(22),
  });

  final String badgeLabel;
  final String title;
  final String? body;
  final List<PracticeCompletionStat> stats;
  final PracticeCompletionAction primaryAction;
  final PracticeCompletionAction? secondaryAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final bodyText = body?.trim();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.accentMutedSurface(tokens.successAccent),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.successAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (bodyText != null && bodyText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bodyText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final stat in stats)
                  PracticeStatPill(
                    label: stat.label,
                    value: stat.value,
                    icon: stat.icon,
                    accent: stat.accent,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          _CompletionActionButton(action: primaryAction),
          if (secondaryAction != null) ...[
            const SizedBox(height: 12),
            _CompletionActionButton(action: secondaryAction!),
          ],
        ],
      ),
    );
  }
}

class _CompletionActionButton extends StatelessWidget {
  const _CompletionActionButton({required this.action});

  final PracticeCompletionAction action;

  @override
  Widget build(BuildContext context) {
    switch (action.style) {
      case PracticeCompletionActionStyle.filled:
        return FilledButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon),
          label: Text(action.label),
        );
      case PracticeCompletionActionStyle.outlined:
        return OutlinedButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon),
          label: Text(action.label),
        );
    }
  }
}
