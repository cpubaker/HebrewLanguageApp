part of '../../home_screen.dart';

class _DashboardAction {
  const _DashboardAction({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final _DashboardActionKind kind;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

enum _DashboardActionKind { welcome, review, newWords, reading, fallback }

_DashboardAction _buildContinueAction({
  required AppLocalizations localizations,
  required AppThemeTokens tokens,
  required bool isFirstRun,
  required LearningBundle bundle,
  required StudyProgressSnapshot progress,
  required FlashcardFocusSnapshot flashcards,
  required VoidCallback onOpenWords,
  required ValueChanged<FlashcardDeckMode> onOpenFlashcards,
  required VoidCallback onOpenReading,
}) {
  if (isFirstRun) {
    return _DashboardAction(
      kind: _DashboardActionKind.welcome,
      title: localizations.homeActionWelcomeTitle,
      subtitle: localizations.homeActionWelcomeSubtitle,
      buttonLabel: localizations.homeActionTry,
      icon: Icons.rocket_launch_rounded,
      accent: tokens.primaryAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
    );
  }

  if (flashcards.needsReview > 0) {
    return _DashboardAction(
      kind: _DashboardActionKind.review,
      title: localizations.homeActionReviewTitle,
      subtitle: localizations.homeActionReviewSubtitle(flashcards.needsReview),
      buttonLabel: localizations.homeActionGoToReview,
      icon: Icons.refresh_rounded,
      accent: tokens.warningAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.needsReview),
    );
  }

  if (progress.unseen > 0) {
    return _DashboardAction(
      kind: _DashboardActionKind.newWords,
      title: localizations.homeActionNewWordsTitle,
      subtitle: localizations.homeActionNewWordsSubtitle(progress.unseen),
      buttonLabel: localizations.homeActionGoToNewWords,
      icon: Icons.style_rounded,
      accent: tokens.successAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
    );
  }

  if (bundle.readingLessons.isNotEmpty) {
    return _DashboardAction(
      kind: _DashboardActionKind.reading,
      title: localizations.homeActionReadingTitle,
      subtitle: localizations.homeActionReadingSubtitle,
      buttonLabel: localizations.homeActionGoToReading,
      icon: Icons.auto_stories_rounded,
      accent: tokens.newContentAccent,
      onTap: onOpenReading,
    );
  }

  return _DashboardAction(
    kind: _DashboardActionKind.fallback,
    title: localizations.homeActionFallbackTitle,
    subtitle: localizations.homeActionFallbackSubtitle,
    buttonLabel: localizations.homeActionGoToWords,
    icon: Icons.translate_rounded,
    accent: tokens.primaryAccent,
    onTap: onOpenWords,
  );
}
