import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../services/app_locale_store.dart';
import '../services/feature_access_service.dart';
import '../services/flashcard_session.dart';
import '../services/theme_mode_store.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'workspace_screen.dart';

class AppShellLearnWorkspace extends StatelessWidget {
  const AppShellLearnWorkspace({
    super.key,
    required this.onOpenWords,
    required this.onOpenVerbs,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final VoidCallback onOpenWords;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return WorkspaceHubScreen(
      subtitle: localizations.learnWorkspaceSubtitle,
      shortcuts: [
        WorkspaceShortcut(
          title: localizations.workspaceWordsTitle,
          subtitle: localizations.workspaceWordsSubtitle,
          icon: Icons.translate_rounded,
          accent: tokens.primaryAccent,
          onTap: onOpenWords,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceVerbsTitle,
          subtitle: localizations.workspaceVerbsSubtitle,
          icon: Icons.play_lesson_rounded,
          accent: tokens.verbAccent,
          onTap: onOpenVerbs,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceGuideTitle,
          subtitle: localizations.workspaceGuideSubtitle,
          icon: Icons.menu_book_rounded,
          accent: tokens.guideAccent,
          onTap: onOpenGuide,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceReadingTitle,
          subtitle: localizations.workspaceReadingSubtitle,
          icon: Icons.auto_stories_rounded,
          accent: tokens.readingAccent,
          onTap: onOpenReading,
        ),
      ],
    );
  }
}

class AppShellPracticeWorkspace extends StatelessWidget {
  const AppShellPracticeWorkspace({
    super.key,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenWritingConstructor,
    required this.onOpenRepetition,
    required this.onOpenSprint,
    required this.onOpenAiPracticeText,
  });

  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenWritingConstructor;
  final VoidCallback onOpenRepetition;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenAiPracticeText;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return WorkspaceHubScreen(
      title: localizations.navPractice,
      subtitle: localizations.practiceWorkspaceSubtitle,
      shortcuts: [
        WorkspaceShortcut(
          title: localizations.workspaceReviewTitle,
          subtitle: localizations.workspaceReviewSubtitle,
          icon: Icons.refresh_rounded,
          accent: tokens.vocabularyAccent,
          onTap: onOpenRepetition,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceFlashcardsTitle,
          subtitle: localizations.workspaceFlashcardsSubtitle,
          icon: Icons.style_rounded,
          accent: tokens.successAccent,
          onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
        ),
        WorkspaceShortcut(
          title: localizations.workspaceWritingTitle,
          subtitle: localizations.workspaceWritingSubtitle,
          icon: Icons.edit_rounded,
          accent: tokens.primaryAccent,
          onTap: onOpenWriting,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceConstructorTitle,
          subtitle: localizations.workspaceConstructorSubtitle,
          icon: Icons.extension_rounded,
          accent: tokens.guideAccent,
          onTap: onOpenWritingConstructor,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceSprintTitle,
          subtitle: localizations.workspaceSprintSubtitle,
          icon: Icons.timer_rounded,
          accent: tokens.dangerAccent,
          onTap: onOpenSprint,
        ),
        WorkspaceShortcut(
          title: localizations.workspaceAiTextTitle,
          subtitle: localizations.workspaceAiTextSubtitle,
          icon: Icons.auto_awesome_rounded,
          accent: tokens.aiAccent,
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
    required this.themePreference,
    required this.nightModeAccess,
    required this.onThemePreferenceChanged,
    required this.localePreference,
    required this.onLocalePreferenceChanged,
    required this.onOpenWords,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
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
  final AppThemePreference themePreference;
  final FeatureAccessDecision nightModeAccess;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final AppLocalePreference localePreference;
  final ValueChanged<AppLocalePreference> onLocalePreferenceChanged;
  final VoidCallback onOpenWords;
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
      themePreference: themePreference,
      nightModeAccess: nightModeAccess,
      onThemePreferenceChanged: onThemePreferenceChanged,
      localePreference: localePreference,
      onLocalePreferenceChanged: onLocalePreferenceChanged,
      onOpenWords: onOpenWords,
      onOpenWriting: onOpenWriting,
      onOpenGuide: onOpenGuide,
      onOpenReading: onOpenReading,
    );
  }
}
