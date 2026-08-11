import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/flashcard_session.dart';
import '../../../theme/app_theme.dart';
import '../practice_completion_card.dart';
import '../practice_header.dart';
import 'flashcard_deck_mode_section.dart';

class FlashcardEmptyState extends StatelessWidget {
  const FlashcardEmptyState({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        PracticeHeader(
          title: localizations.flashcardsTitle,
          subtitle: localizations.flashcardsEmptySubtitle,
        ),
        FlashcardDeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                _emptyTitle(mode, localizations),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _emptyBody(mode, localizations),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _emptyTitle(
    FlashcardDeckMode mode,
    AppLocalizations localizations,
  ) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return localizations.flashcardsEmptyAllTitle;
      case FlashcardDeckMode.withContexts:
        return localizations.flashcardsEmptyContextsTitle;
      case FlashcardDeckMode.needsReview:
        return localizations.flashcardsEmptyReviewTitle;
    }
  }

  String _emptyBody(
    FlashcardDeckMode mode,
    AppLocalizations localizations,
  ) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return localizations.flashcardsEmptyAllBody;
      case FlashcardDeckMode.withContexts:
        return localizations.flashcardsEmptyContextsBody;
      case FlashcardDeckMode.needsReview:
        return localizations.flashcardsEmptyReviewBody;
    }
  }
}

class FlashcardCompletedState extends StatelessWidget {
  const FlashcardCompletedState({
    super.key,
    required this.mode,
    required this.wordCount,
    required this.correctAnswers,
    required this.repeatAnswers,
    required this.reviewWordCount,
    required this.onRestartDeck,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final int wordCount;
  final int correctAnswers;
  final int repeatAnswers;
  final int reviewWordCount;
  final void Function([FlashcardDeckMode? mode]) onRestartDeck;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        PracticeHeader(
          title: localizations.flashcardsTitle,
          subtitle: localizations.flashcardsCompletedSubtitle,
        ),
        FlashcardDeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        PracticeCompletionCard(
          badgeLabel: localizations.flashcardsDone,
          title: localizations.flashcardsCompletedTitle(wordCount),
          body: _completionBody(mode, reviewWordCount, localizations),
          stats: [
            PracticeCompletionStat(
              label: localizations.wordStatusKnown,
              value: correctAnswers,
              icon: Icons.check_rounded,
              accent: tokens.successAccent,
            ),
            PracticeCompletionStat(
              label: localizations.flashcardsRepeat,
              value: repeatAnswers,
              icon: Icons.refresh_rounded,
              accent: tokens.warningAccent,
            ),
          ],
          primaryAction: PracticeCompletionAction(
            label: localizations.flashcardsRestart,
            icon: Icons.refresh_rounded,
            onPressed: () => onRestartDeck(),
          ),
          secondaryAction:
              mode != FlashcardDeckMode.needsReview && reviewWordCount > 0
              ? PracticeCompletionAction(
                  label: localizations.flashcardsGoToReview,
                  icon: Icons.rule_rounded,
                  onPressed: () => onRestartDeck(FlashcardDeckMode.needsReview),
                  style: PracticeCompletionActionStyle.outlined,
                )
              : null,
        ),
      ],
    );
  }

  String _completionBody(
    FlashcardDeckMode mode,
    int reviewWordCount,
    AppLocalizations localizations,
  ) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        if (reviewWordCount > 0) {
          return localizations.flashcardsCompletionAllWithReview(
            reviewWordCount,
          );
        }
        return localizations.flashcardsCompletionAll;
      case FlashcardDeckMode.withContexts:
        if (reviewWordCount > 0) {
          return localizations.flashcardsCompletionContextsWithReview(
            reviewWordCount,
          );
        }
        return localizations.flashcardsCompletionContexts;
      case FlashcardDeckMode.needsReview:
        return localizations.flashcardsCompletionReview;
    }
  }
}
