import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'practice_panel.dart';

class PracticeSessionSummary extends StatelessWidget {
  const PracticeSessionSummary({
    super.key,
    required this.title,
    required this.lines,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final List<String> lines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return PracticePanel(
      padding: padding,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          for (final line in lines) ...[
            const SizedBox(height: 6),
            Text(
              line,
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
