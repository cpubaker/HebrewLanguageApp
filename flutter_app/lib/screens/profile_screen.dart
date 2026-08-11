import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/feature_access_localizations.dart';
import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../services/app_locale_store.dart';
import '../services/feature_access_service.dart';
import '../services/progress_snapshot.dart';
import '../services/theme_mode_store.dart';
import '../theme/app_theme.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_metric_tile.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
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
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.pagePadding.left,
        tokens.pagePadding.top,
        tokens.pagePadding.right,
        32,
      ),
      children: [
        _ProfileProgressSection(
          bundle: bundle,
          guideLessonStatuses: guideLessonStatuses,
          readingLessonStatuses: readingLessonStatuses,
          onOpenWords: onOpenWords,
          onOpenWriting: onOpenWriting,
          onOpenGuide: onOpenGuide,
          onOpenReading: onOpenReading,
        ),
        const SizedBox(height: 16),
        _ProfileInventorySection(bundle: bundle),
        const SizedBox(height: 16),
        _ProfileSettingsSection(
          autoHideBottomNavOnScroll: autoHideBottomNavOnScroll,
          onAutoHideBottomNavOnScrollChanged:
              onAutoHideBottomNavOnScrollChanged,
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
        ),
      ],
    );
  }
}

class _ProfileInventorySection extends StatelessWidget {
  const _ProfileInventorySection({required this.bundle});

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(title: localizations.profileSystem),
          const SizedBox(height: 16),
          AppActionWrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppStatChip(
                label: localizations.profileWords,
                value: bundle.words.length,
                accent: tokens.successAccent,
              ),
              AppStatChip(
                label: localizations.profileGuide,
                value: bundle.guideLessons.length,
                accent: tokens.warningAccent,
              ),
              AppStatChip(
                label: localizations.profileReading,
                value: bundle.readingLessons.length,
                accent: tokens.readingAccent,
              ),
              AppStatChip(
                label: localizations.profileVerbs,
                value: bundle.verbLessons.length,
                accent: tokens.vocabularyAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileProgressSection extends StatelessWidget {
  const _ProfileProgressSection({
    required this.bundle,
    required this.guideLessonStatuses,
    required this.readingLessonStatuses,
    required this.onOpenWords,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final Map<String, GuideLessonStatus> guideLessonStatuses;
  final Map<String, GuideLessonStatus> readingLessonStatuses;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    final study = StudyProgressSnapshot.fromWords(bundle.words);
    final writing = WritingProgressSnapshot.fromWords(bundle.words);
    final guide = LessonProgressSnapshot.fromLessons(
      lessons: bundle.guideLessons,
      lessonStatuses: guideLessonStatuses,
    );
    final reading = LessonProgressSnapshot.fromLessons(
      lessons: bundle.readingLessons,
      lessonStatuses: readingLessonStatuses,
    );

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(title: localizations.profileProgress),
          const SizedBox(height: 16),
          _ProgressStrip(
            label: localizations.profileWordsOpened,
            completedLabel: '${study.seen}/${study.total}',
            ratio: study.completionRatio,
            accent: tokens.successAccent,
            onTap: onOpenWords,
          ),
          const SizedBox(height: 12),
          _ProgressStrip(
            label: localizations.profileWritingPracticed,
            completedLabel: '${writing.practiced}/${writing.total}',
            ratio: writing.completionRatio,
            accent: tokens.aiAccent,
            onTap: onOpenWriting,
          ),
          const SizedBox(height: 12),
          _ProgressStrip(
            label: localizations.profileGuideCompleted,
            completedLabel: '${guide.read}/${guide.total}',
            ratio: guide.completionRatio,
            accent: tokens.warningAccent,
            onTap: onOpenGuide,
          ),
          const SizedBox(height: 12),
          _ProgressStrip(
            label: localizations.profileReadingCompleted,
            completedLabel: '${reading.read}/${reading.total}',
            ratio: reading.completionRatio,
            accent: tokens.readingAccent,
            onTap: onOpenReading,
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              AppMetricTile(
                label: localizations.profileKnownWords,
                value: study.known,
                accent: tokens.successAccent,
              ),
              AppMetricTile(
                label: localizations.profileReview,
                value: study.needsReview,
                accent: tokens.warningAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsSection extends StatelessWidget {
  const _ProfileSettingsSection({
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
  });

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(title: localizations.profileSettings),
              const SizedBox(height: 18),
              _ThemeCycleTile(
                key: const ValueKey('theme-mode-tile'),
                preference: themePreference,
                nightModeAccess: nightModeAccess,
                onChanged: onThemePreferenceChanged,
              ),
              const SizedBox(height: 12),
              _LocaleCycleTile(
                key: const ValueKey('locale-tile'),
                preference: localePreference,
                onChanged: onLocalePreferenceChanged,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: localizations.profileAutoHideNav,
                subtitle: localizations.profileAutoHideNavBody,
                value: autoHideBottomNavOnScroll,
                onChanged: onAutoHideBottomNavOnScrollChanged,
                switchKey: const ValueKey('auto-hide-bottom-nav-switch'),
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: localizations.profileAiContexts,
                subtitle: localizations.profileAiContextsBody,
                lockedSubtitle: aiWordContextsAccess.localizedDescription(
                  localizations,
                ),
                value: aiWordContextsEnabled,
                onChanged: onAiWordContextsEnabledChanged,
                isLocked: !aiWordContextsAccess.isEnabled,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: localizations.profileAiTexts,
                subtitle: localizations.profileAiTextsBody,
                lockedSubtitle: aiPracticeTextsAccess.localizedDescription(
                  localizations,
                ),
                value: aiPracticeTextsEnabled,
                onChanged: onAiPracticeTextsEnabledChanged,
                isLocked: !aiPracticeTextsAccess.isEnabled,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    required this.label,
    required this.completedLabel,
    required this.ratio,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String completedLabel;
  final double ratio;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                completedLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: tokens.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: ratio == 0 ? 0.0 : ratio.clamp(0.0, 1.0),
              backgroundColor: tokens.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: tokens.subtleSurface,
      borderRadius: BorderRadius.circular(20),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: content,
            ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.isLocked = false,
    this.lockedSubtitle,
    this.switchKey,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLocked;
  final String? lockedSubtitle;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final isInteractive = !isLocked && onChanged != null;
    final effectiveSubtitle =
        isLocked && lockedSubtitle != null && lockedSubtitle!.trim().isNotEmpty
        ? lockedSubtitle!
        : subtitle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.subtleSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isInteractive ? null : tokens.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  effectiveSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isInteractive
                        ? tokens.mutedText
                        : tokens.inactiveForeground(tokens.mutedText),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isLocked) ...[
            Icon(Icons.lock_rounded, color: tokens.mutedText, size: 20),
            const SizedBox(width: 8),
          ],
          Switch.adaptive(
            key: switchKey,
            value: value,
            onChanged: isInteractive ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ThemeCycleTile extends StatelessWidget {
  const _ThemeCycleTile({
    super.key,
    required this.preference,
    required this.nightModeAccess,
    required this.onChanged,
  });

  final AppThemePreference preference;
  final FeatureAccessDecision nightModeAccess;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final isLocked = !nightModeAccess.isEnabled;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).profileTheme,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLocked ? tokens.mutedText : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLocked
                      ? nightModeAccess.localizedDescription(
                          AppLocalizations.of(context),
                        )
                      : AppLocalizations.of(context).profileThemeBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isLocked
                        ? tokens.inactiveForeground(tokens.mutedText)
                        : tokens.mutedText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isLocked) ...[
            Icon(Icons.lock_rounded, color: tokens.mutedText, size: 20),
            const SizedBox(width: 8),
          ],
          _ThemeValuePill(
            label: switch (preference) {
              AppThemePreference.light => AppLocalizations.of(context).themeLight,
              AppThemePreference.dark => AppLocalizations.of(context).themeDark,
              AppThemePreference.system => AppLocalizations.of(context).themeSystem,
            },
            isLocked: isLocked,
          ),
        ],
      ),
    );

    return Material(
      color: tokens.subtleSurface,
      borderRadius: BorderRadius.circular(20),
      child: isLocked
          ? content
          : InkWell(
              onTap: () => onChanged(preference.next),
              borderRadius: BorderRadius.circular(20),
              child: content,
            ),
    );
  }
}

class _ThemeValuePill extends StatelessWidget {
  const _ThemeValuePill({required this.label, required this.isLocked});

  final String label;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLocked ? tokens.elevatedSurface : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isLocked ? tokens.mutedText : theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LocaleCycleTile extends StatelessWidget {
  const _LocaleCycleTile({
    super.key,
    required this.preference,
    required this.onChanged,
  });

  final AppLocalePreference preference;
  final ValueChanged<AppLocalePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final localizations = AppLocalizations.of(context);
    final label = switch (preference) {
      AppLocalePreference.uk => localizations.localeNameUk,
      AppLocalePreference.en => localizations.localeNameEn,
    };

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.profileLanguageTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.profileLanguageBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _ThemeValuePill(label: label, isLocked: false),
        ],
      ),
    );

    return Material(
      color: tokens.subtleSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onChanged(preference.next),
        borderRadius: BorderRadius.circular(20),
        child: content,
      ),
    );
  }
}
