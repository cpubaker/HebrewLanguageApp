import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../services/feature_access_service.dart';
import '../services/flashcard_session.dart';
import 'profile_screen.dart';
import 'workspace_screen.dart';

enum AppShellProfileSection { overview, progress, settings }

class AppShellLearnWorkspace extends StatelessWidget {
  const AppShellLearnWorkspace({
    super.key,
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenVerbs,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return WorkspaceHubScreen(
      title: 'Вчитись',
      subtitle: 'Оберіть, з чого продовжити навчання.',
      shortcuts: [
        WorkspaceShortcut(
          title: 'Слова',
          subtitle:
              'Усі слова в одному місці: пошук, фільтри й прогрес. Доступно: ${bundle.words.length} слів.',
          icon: Icons.translate_rounded,
          accent: const Color(0xFF2B5D4F),
          onTap: onOpenWords,
        ),
        WorkspaceShortcut(
          title: 'Дієслова',
          subtitle:
              'Добірка уроків про дієслова з поясненнями, озвученням і прикладами. Доступно: ${bundle.verbLessons.length} уроків.',
          icon: Icons.play_lesson_rounded,
          accent: const Color(0xFF8C6A2A),
          onTap: onOpenVerbs,
        ),
        WorkspaceShortcut(
          title: 'Довідник',
          subtitle:
              'Теми з поясненнями, пошуком і прогресом по матеріалах. Доступно: ${bundle.guideLessons.length} уроків.',
          icon: Icons.menu_book_rounded,
          accent: const Color(0xFFB45309),
          onTap: onOpenGuide,
        ),
        WorkspaceShortcut(
          title: 'Читання',
          subtitle:
              'Тексти за рівнями складності з відмітками прочитаного. Доступно: ${bundle.readingLessons.length} уроків.',
          icon: Icons.auto_stories_rounded,
          accent: const Color(0xFF0F766E),
          onTap: onOpenReading,
        ),
      ],
    );
  }
}

class AppShellPracticeWorkspace extends StatelessWidget {
  const AppShellPracticeWorkspace({
    super.key,
    required this.preferredFlashcardDeckMode,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenWritingConstructor,
    required this.onOpenRepetition,
    required this.onOpenSprint,
    required this.onOpenAiPracticeText,
  });

  final FlashcardDeckMode preferredFlashcardDeckMode;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenWritingConstructor;
  final VoidCallback onOpenRepetition;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenAiPracticeText;

  @override
  Widget build(BuildContext context) {
    return WorkspaceHubScreen(
      title: 'Практика',
      subtitle:
          'Оберіть формат тренування і відкрийте його окремим повноекранним сеансом.',
      shortcuts: [
        WorkspaceShortcut(
          title: 'Картки',
          subtitle:
              'Швидке повторення перекладу, контексту і наборів на повторення.',
          icon: Icons.style_rounded,
          accent: const Color(0xFF0F766E),
          onTap: () => onOpenFlashcards(preferredFlashcardDeckMode),
        ),
        WorkspaceShortcut(
          title: 'Написання',
          subtitle: 'Написання слів івритом без підказок.',
          icon: Icons.edit_rounded,
          accent: const Color(0xFF2B5D4F),
          onTap: onOpenWriting,
        ),
        WorkspaceShortcut(
          title: 'Конструктор',
          subtitle: 'Складання слова з блоків у правильному порядку.',
          icon: Icons.extension_rounded,
          accent: const Color(0xFFB45309),
          onTap: onOpenWritingConstructor,
        ),
        WorkspaceShortcut(
          title: 'Повторення',
          subtitle: 'Нові слова й останні помилки для спокійного повторення.',
          icon: Icons.refresh_rounded,
          accent: const Color(0xFF8C6A2A),
          onTap: onOpenRepetition,
        ),
        WorkspaceShortcut(
          title: 'Спринт',
          subtitle:
              'Хвилинний режим на швидкість: для кожного слова є два варіанти перекладу.',
          icon: Icons.timer_rounded,
          accent: const Color(0xFFB91C1C),
          onTap: onOpenSprint,
        ),
        WorkspaceShortcut(
          title: 'Текст зі словами',
          subtitle:
              'Короткий ШІ-текст з вашими словами, перекладом і швидким переходом до практики.',
          icon: Icons.auto_awesome_rounded,
          accent: const Color(0xFF7C3AED),
          onTap: onOpenAiPracticeText,
        ),
      ],
    );
  }
}

class AppShellProfileWorkspace extends StatelessWidget {
  const AppShellProfileWorkspace({
    super.key,
    required this.bundle,
    required this.selectedSection,
    required this.onSectionSelected,
    required this.guideLessonStatuses,
    required this.readingLessonStatuses,
    required this.autoHideBottomNavOnScroll,
    required this.onAutoHideBottomNavOnScrollChanged,
    required this.aiWordContextsEnabled,
    required this.aiWordContextsAccess,
    required this.onAiWordContextsEnabledChanged,
    required this.aiPracticeTextsEnabled,
    required this.aiPracticeTextsAccess,
    required this.onAiPracticeTextsEnabledChanged,
    required this.isDarkMode,
    required this.nightModeAccess,
    required this.onToggleThemeMode,
    required this.preferWritingPractice,
    required this.onPreferWritingPracticeChanged,
    required this.preferredFlashcardDeckMode,
    required this.onPreferredFlashcardDeckModeChanged,
    required this.onSelectHome,
    required this.onSelectLearn,
    required this.onOpenPreferredPractice,
    required this.onOpenRepetition,
    required this.onOpenSprint,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final AppShellProfileSection selectedSection;
  final ValueChanged<AppShellProfileSection> onSectionSelected;
  final Map<String, GuideLessonStatus> guideLessonStatuses;
  final Map<String, GuideLessonStatus> readingLessonStatuses;
  final bool autoHideBottomNavOnScroll;
  final ValueChanged<bool> onAutoHideBottomNavOnScrollChanged;
  final bool aiWordContextsEnabled;
  final FeatureAccessDecision aiWordContextsAccess;
  final ValueChanged<bool> onAiWordContextsEnabledChanged;
  final bool aiPracticeTextsEnabled;
  final FeatureAccessDecision aiPracticeTextsAccess;
  final ValueChanged<bool> onAiPracticeTextsEnabledChanged;
  final bool isDarkMode;
  final FeatureAccessDecision nightModeAccess;
  final VoidCallback onToggleThemeMode;
  final bool preferWritingPractice;
  final ValueChanged<bool> onPreferWritingPracticeChanged;
  final FlashcardDeckMode preferredFlashcardDeckMode;
  final ValueChanged<FlashcardDeckMode> onPreferredFlashcardDeckModeChanged;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectLearn;
  final VoidCallback onOpenPreferredPractice;
  final VoidCallback onOpenRepetition;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      bundle: bundle,
      guideLessonStatuses: guideLessonStatuses,
      readingLessonStatuses: readingLessonStatuses,
      autoHideBottomNavOnScroll: autoHideBottomNavOnScroll,
      onAutoHideBottomNavOnScrollChanged: onAutoHideBottomNavOnScrollChanged,
      aiWordContextsEnabled: aiWordContextsEnabled,
      aiWordContextsAccess: aiWordContextsAccess,
      onAiWordContextsEnabledChanged: onAiWordContextsEnabledChanged,
      aiPracticeTextsEnabled: aiPracticeTextsEnabled,
      aiPracticeTextsAccess: aiPracticeTextsAccess,
      onAiPracticeTextsEnabledChanged: onAiPracticeTextsEnabledChanged,
      isDarkMode: isDarkMode,
      nightModeAccess: nightModeAccess,
      onToggleThemeMode: onToggleThemeMode,
      preferWritingPractice: preferWritingPractice,
      onPreferWritingPracticeChanged: onPreferWritingPracticeChanged,
      preferredFlashcardDeckMode: preferredFlashcardDeckMode,
      onPreferredFlashcardDeckModeChanged: onPreferredFlashcardDeckModeChanged,
      onOpenWords: onOpenWords,
      onOpenFlashcards: onOpenFlashcards,
      onOpenWriting: onOpenWriting,
      onOpenSprint: onOpenSprint,
      onOpenGuide: onOpenGuide,
      onOpenReading: onOpenReading,
    );
  }
}
