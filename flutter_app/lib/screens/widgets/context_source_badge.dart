import 'package:flutter/material.dart';

import '../../models/learning_context.dart';

class ContextSourceBadge extends StatelessWidget {
  const ContextSourceBadge({super.key, required this.context});

  final LearningContext context;

  @override
  Widget build(BuildContext context) {
    if (!this.context.isAiGenerated) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = this.context.isNew
        ? const Color(0xFFB45309)
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            this.context.isNew ? 'Нове!' : 'AI',
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
