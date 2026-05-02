import 'package:flutter/material.dart';

import 'practice_stat_pill.dart';

class PracticeStatsRow extends StatelessWidget {
  const PracticeStatsRow({super.key, required this.stats, this.spacing = 12});

  final List<PracticeStatItem> stats;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < stats.length; index += 1) ...[
          Expanded(
            child: PracticeStatPill(
              label: stats[index].label,
              value: stats[index].value,
              accent: stats[index].accent,
              icon: stats[index].icon,
            ),
          ),
          if (index != stats.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class PracticeStatItem {
  const PracticeStatItem({
    required this.label,
    required this.value,
    required this.accent,
    this.icon,
  });

  final String label;
  final int value;
  final Color accent;
  final IconData? icon;
}
