import 'package:flutter/material.dart';

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
    return PracticePanel(
      padding: padding,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF163832),
            ),
          ),
          for (final line in lines) ...[
            const SizedBox(height: 6),
            Text(
              line,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6C665D),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
