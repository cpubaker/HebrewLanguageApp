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
      title: 'Привіт! Готовий почати?',
      subtitle:
          'Відкрий перші картки, щоб познайомитись зі словами івриту й заробити перший день у серії.',
      buttonLabel: 'Спробувати',
      icon: Icons.rocket_launch_rounded,
      accent: tokens.primaryAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
    );
  }

  if (flashcards.needsReview > 0) {
    return _DashboardAction(
      kind: _DashboardActionKind.review,
      title: 'Продовжити повторення',
      subtitle:
          '${flashcards.needsReview} слів чекають у картках на повторення.',
      buttonLabel: 'До повторення',
      icon: Icons.refresh_rounded,
      accent: tokens.warningAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.needsReview),
    );
  }

  if (progress.unseen > 0) {
    return _DashboardAction(
      kind: _DashboardActionKind.newWords,
      title: 'Готовий до нового?',
      subtitle: '${progress.unseen} слів ще чекають свого першого знайомства.',
      buttonLabel: 'До нових слів',
      icon: Icons.style_rounded,
      accent: tokens.successAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
    );
  }

  if (bundle.readingLessons.isNotEmpty) {
    return _DashboardAction(
      kind: _DashboardActionKind.reading,
      title: 'Усе повторено — почитаємо?',
      subtitle: 'У бібліотеці чекають тексти, з якими можна підняти рівень.',
      buttonLabel: 'До читання',
      icon: Icons.auto_stories_rounded,
      accent: tokens.newContentAccent,
      onTap: onOpenReading,
    );
  }

  return _DashboardAction(
    kind: _DashboardActionKind.fallback,
    title: 'Заглянь у словник',
    subtitle: 'Перегляньте слова, щоб обрати наступний напрям навчання.',
    buttonLabel: 'До слів',
    icon: Icons.translate_rounded,
    accent: tokens.primaryAccent,
    onTap: onOpenWords,
  );
}
