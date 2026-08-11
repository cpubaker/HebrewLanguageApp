import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/flashcard_session.dart';
import '../../../theme/app_theme.dart';

class FlashcardDeckModeSection extends StatelessWidget {
  const FlashcardDeckModeSection({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  final FlashcardDeckMode selectedMode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.flashcardsDeckMode,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FlashcardDeckChoiceChip(
              label: localizations.flashcardsDeckAll,
              isSelected: selectedMode == FlashcardDeckMode.allWords,
              onTap: () => onChanged(FlashcardDeckMode.allWords),
            ),
            _FlashcardDeckChoiceChip(
              label: localizations.flashcardsDeckContexts,
              isSelected: selectedMode == FlashcardDeckMode.withContexts,
              onTap: () => onChanged(FlashcardDeckMode.withContexts),
            ),
            _FlashcardDeckChoiceChip(
              label: localizations.flashcardsDeckReview,
              isSelected: selectedMode == FlashcardDeckMode.needsReview,
              onTap: () => onChanged(FlashcardDeckMode.needsReview),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlashcardDeckChoiceChip extends StatelessWidget {
  const _FlashcardDeckChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : tokens.outlineSoft,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
