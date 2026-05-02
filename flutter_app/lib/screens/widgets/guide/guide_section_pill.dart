import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedForegroundColor =
        foregroundColor ??
        (isDark ? const Color(0xFFD6B16B) : const Color(0xFF8C6A2A));
    final resolvedBackgroundColor =
        backgroundColor ??
        (isDark ? const Color(0xFF4C3924) : const Color(0xFFFDE7D4));

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
