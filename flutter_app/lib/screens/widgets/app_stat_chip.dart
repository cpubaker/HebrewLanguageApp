import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppStatChip extends StatelessWidget {
  const AppStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final int value;
  final Color accent;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final foregroundColor = textColor ?? accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: accent)
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          const SizedBox(width: 10),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
