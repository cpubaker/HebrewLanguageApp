import 'package:flutter/material.dart';

import '../../../models/learning_context.dart';
import '../../../theme/app_theme.dart';
import '../context_source_badge.dart';

class FlashcardContextPanel extends StatelessWidget {
  const FlashcardContextPanel({
    super.key,
    required this.context,
    required this.isAnswerRevealed,
  });

  final LearningContext? context;
  final bool isAnswerRevealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    if (this.context == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tokens.subtleSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Для цього слова ще немає прикладу в реченні.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: tokens.secondaryText,
            height: 1.45,
          ),
        ),
      );
    }

    final hebrewText = this.context!.hebrew;
    final hasHebrew = _containsHebrew(hebrewText);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.contextPanelSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Контекст',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.mutedText,
                ),
              ),
              if (this.context!.isAiGenerated) ...[
                const SizedBox(width: 10),
                ContextSourceBadge(context: this.context!),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hebrewText,
            textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
            textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          if (isAnswerRevealed &&
              this.context!.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              this.context!.translation,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _containsHebrew(String text) {
    return text.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );
  }
}
