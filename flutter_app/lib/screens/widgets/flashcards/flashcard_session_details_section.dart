import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../practice_panel.dart';
import '../practice_stat_pill.dart';

class FlashcardSessionDetailsSection extends StatelessWidget {
  const FlashcardSessionDetailsSection({
    super.key,
    required this.isExpanded,
    required this.deckLabel,
    required this.currentCardNumber,
    required this.wordCount,
    required this.remainingCount,
    required this.sessionProgress,
    required this.correctCount,
    required this.wrongCount,
    required this.onToggle,
  });

  final bool isExpanded;
  final String deckLabel;
  final int currentCardNumber;
  final int wordCount;
  final int remainingCount;
  final double sessionProgress;
  final int correctCount;
  final int wrongCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return PracticePanel(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Поточна сесія',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentCardNumber із $wordCount, $deckLabel',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: tokens.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    deckLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: tokens.secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: sessionProgress == 0 ? 0.02 : sessionProgress,
                      backgroundColor: tokens.progressTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tokens.successAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remainingCount > 0
                        ? 'Після неї лишиться ще $remainingCount карток'
                        : 'Це остання картка',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PracticeStatPill(
                          label: 'Вірно',
                          value: correctCount,
                          icon: Icons.check_rounded,
                          accent: tokens.successAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PracticeStatPill(
                          label: 'Помилки',
                          value: wrongCount,
                          icon: Icons.close_rounded,
                          accent: tokens.dangerAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
