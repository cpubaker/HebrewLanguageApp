import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/learning_context.dart';
import '../../theme/app_theme.dart';

class ContextSourceBadge extends StatelessWidget {
  const ContextSourceBadge({super.key, required this.context});

  final LearningContext context;

  @override
  Widget build(BuildContext context) {
    if (!this.context.isAiGenerated) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final color = this.context.isNew ? tokens.warningAccent : tokens.aiAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.accentSurface(color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            this.context.isNew
                ? AppLocalizations.of(context).aiContextNew
                : AppLocalizations.of(context).aiContext,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
