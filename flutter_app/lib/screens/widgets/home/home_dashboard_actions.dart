part of '../../home_screen.dart';

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

_DashboardAction _buildContinueAction({
  required AppThemeTokens tokens,
  required LearningBundle bundle,
  required StudyProgressSnapshot progress,
  required FlashcardFocusSnapshot flashcards,
  required VoidCallback onOpenWords,
  required ValueChanged<FlashcardDeckMode> onOpenFlashcards,
  required VoidCallback onOpenReading,
}) {
  if (flashcards.needsReview > 0) {
    return _DashboardAction(
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
      title: 'Почати нові слова',
      subtitle: '${progress.unseen} слів ще не відкривали в тренуванні.',
      buttonLabel: 'До карток',
      icon: Icons.style_rounded,
      accent: tokens.successAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
    );
  }

  if (bundle.readingLessons.isNotEmpty) {
    return _DashboardAction(
      title: 'Почитати далі',
      subtitle: 'У бібліотеці вже є тексти, з яких можна продовжити.',
      buttonLabel: 'До читання',
      icon: Icons.auto_stories_rounded,
      accent: tokens.newContentAccent,
      onTap: onOpenReading,
    );
  }

  return _DashboardAction(
    title: 'Повернутися до словника',
    subtitle: 'Перегляньте слова, щоб обрати наступний напрям навчання.',
    buttonLabel: 'До слів',
    icon: Icons.translate_rounded,
    accent: tokens.primaryAccent,
    onTap: onOpenWords,
  );
}

List<_DashboardAction> _buildRecommendedActions({
  required AppThemeTokens tokens,
  required LearningBundle bundle,
  required StudyProgressSnapshot progress,
  required FlashcardFocusSnapshot flashcards,
  required ValueChanged<FlashcardDeckMode> onOpenFlashcards,
  required VoidCallback onOpenWriting,
  required VoidCallback onOpenGuide,
}) {
  return <_DashboardAction>[
    _DashboardAction(
      title: 'Картки з прикладами',
      subtitle: flashcards.withContexts > 0
          ? '${flashcards.withContexts} слів уже мають контекст для практики.'
          : 'Контекстні картки з’являтимуться, коли для слів буде більше прикладів.',
      buttonLabel: 'Відкрити',
      icon: Icons.chat_bubble_outline_rounded,
      accent: tokens.contextAccent,
      onTap: () => onOpenFlashcards(FlashcardDeckMode.withContexts),
    ),
    _DashboardAction(
      title: 'Письмо',
      subtitle: progress.seen > 0
          ? 'Повторіть знайомі слова й потренуйте написання.'
          : 'Спочатку відкрийте кілька слів у картках, а потім тренуйте їхнє написання тут.',
      buttonLabel: 'Тренувати',
      icon: Icons.edit_rounded,
      accent: tokens.newContentAccent,
      onTap: onOpenWriting,
    ),
    _DashboardAction(
      title: 'Матеріали',
      subtitle: bundle.guideLessons.isNotEmpty
          ? 'У довіднику й читанні вже є теми для наступного кроку.'
          : 'Матеріали з’являться тут, коли їх буде завантажено.',
      buttonLabel: 'Відкрити',
      icon: Icons.menu_book_rounded,
      accent: tokens.vocabularyAccent,
      onTap: onOpenGuide,
    ),
  ];
}
