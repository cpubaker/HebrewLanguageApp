import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class GuideSectionPill extends StatelessWidget {
  const GuideSectionPill({
    super.key,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final resolvedForegroundColor =
        foregroundColor ?? tokens.guideSecondaryAccent;
    final resolvedBackgroundColor =
        backgroundColor ?? tokens.guideChipBackground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: resolvedForegroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
