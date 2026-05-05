import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../services/feature_access_service.dart';
import '../services/flashcard_session.dart';
import '../services/progress_snapshot.dart';
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
    required this.isDarkMode,
    required this.nightModeAccess,
    required this.onToggleThemeMode,
    required this.preferWritingPractice,
    required this.onPreferWritingPracticeChanged,
    required this.preferredFlashcardDeckMode,
    required this.onPreferredFlashcardDeckModeChanged,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
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
  final bool isDarkMode;
  final FeatureAccessDecision nightModeAccess;
  final VoidCallback onToggleThemeMode;
  final bool preferWritingPractice;
  final ValueChanged<bool> onPreferWritingPracticeChanged;
  final FlashcardDeckMode preferredFlashcardDeckMode;
  final ValueChanged<FlashcardDeckMode> onPreferredFlashcardDeckModeChanged;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
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
        _ProfileSystemSummaryCard(bundle: bundle),
        const SizedBox(height: 16),
        _ProfileProgressSection(
          bundle: bundle,
          guideLessonStatuses: guideLessonStatuses,
          readingLessonStatuses: readingLessonStatuses,
          onOpenWords: onOpenWords,
          onOpenFlashcards: onOpenFlashcards,
          onOpenWriting: onOpenWriting,
          onOpenSprint: onOpenSprint,
          onOpenGuide: onOpenGuide,
          onOpenReading: onOpenReading,
        ),
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
          isDarkMode: isDarkMode,
          nightModeAccess: nightModeAccess,
          onToggleThemeMode: onToggleThemeMode,
          preferWritingPractice: preferWritingPractice,
          onPreferWritingPracticeChanged: onPreferWritingPracticeChanged,
          preferredFlashcardDeckMode: preferredFlashcardDeckMode,
          onPreferredFlashcardDeckModeChanged:
              onPreferredFlashcardDeckModeChanged,
        ),
      ],
    );
  }
}

class _ProfileSystemSummaryCard extends StatelessWidget {
  const _ProfileSystemSummaryCard({required this.bundle});

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            tokens.heroGradientStart,
            tokens.heroGradientMiddle,
            tokens.heroGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.heroShadowColor,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.heroChipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Мобільна версія',
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.heroText,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Вчимо іврит',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Слова, картки, довідник, дієслова й читання працюють з тією самою навчальною базою, що й десктопний застосунок.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.heroMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${bundle.words.length} слів доступні на цьому пристрої',
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppStatChip(
                label: 'Слова',
                value: bundle.words.length,
                accent: tokens.heroText,
                backgroundColor: tokens.heroChipBackground,
                textColor: tokens.heroText,
              ),
              AppStatChip(
                label: 'Читання',
                value: bundle.readingLessons.length,
                accent: tokens.heroText,
                backgroundColor: tokens.heroChipBackground,
                textColor: tokens.heroText,
              ),
              AppStatChip(
                label: 'Дієслова',
                value: bundle.verbLessons.length,
                accent: tokens.heroText,
                backgroundColor: tokens.heroChipBackground,
                textColor: tokens.heroText,
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
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
    required this.onOpenGuide,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final Map<String, GuideLessonStatus> guideLessonStatuses;
  final Map<String, GuideLessonStatus> readingLessonStatuses;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final study = StudyProgressSnapshot.fromWords(bundle.words);
    final flashcards = FlashcardFocusSnapshot.fromWords(bundle.words);
    final writing = WritingProgressSnapshot.fromWords(bundle.words);
    final guide = LessonProgressSnapshot.fromLessons(
      lessons: bundle.guideLessons,
      lessonStatuses: guideLessonStatuses,
    );
    final reading = LessonProgressSnapshot.fromLessons(
      lessons: bundle.readingLessons,
      lessonStatuses: readingLessonStatuses,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Прогрес',
                subtitle:
                    'Короткий огляд слів, практики й матеріалів в одному місці.',
              ),
              const SizedBox(height: 14),
              AppActionWrap(
                children: [
                  AppStatChip(
                    label: 'Слова відкрито',
                    value: study.seen,
                    accent: tokens.successAccent,
                    icon: Icons.translate_rounded,
                  ),
                  AppStatChip(
                    label: 'На повторення',
                    value: study.needsReview,
                    accent: tokens.warningAccent,
                    icon: Icons.refresh_rounded,
                  ),
                  AppStatChip(
                    label: 'Тем прочитано',
                    value: guide.read,
                    accent: tokens.warningAccent,
                    icon: Icons.menu_book_rounded,
                  ),
                  AppStatChip(
                    label: 'Текстів прочитано',
                    value: reading.read,
                    accent: tokens.readingAccent,
                    icon: Icons.auto_stories_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Слова і практика',
                subtitle: 'Загальний прогрес у словах, картках і письмі.',
              ),
              const SizedBox(height: 16),
              _ProgressStrip(
                label: 'Слова відкрито',
                completedLabel: '${study.seen} із ${study.total}',
                ratio: study.completionRatio,
                accent: tokens.successAccent,
              ),
              const SizedBox(height: 12),
              _ProgressStrip(
                label: 'Письмо відпрацьовано',
                completedLabel: '${writing.practiced} із ${writing.total}',
                ratio: writing.completionRatio,
                accent: tokens.aiAccent,
              ),
              const SizedBox(height: 16),
              AppActionWrap(
                children: [
                  AppMetricTile(
                    label: 'Знайомі слова',
                    value: study.known,
                    accent: tokens.successAccent,
                  ),
                  AppMetricTile(
                    label: 'Повторити',
                    value: study.needsReview,
                    accent: tokens.warningAccent,
                  ),
                  AppMetricTile(
                    label: 'Письмо ок',
                    value: writing.known,
                    accent: tokens.aiAccent,
                  ),
                  AppMetricTile(
                    label: 'Контексти',
                    value: flashcards.withContexts,
                    accent: tokens.infoAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Матеріали',
                subtitle:
                    'Прогрес довідника та читання в одному місці, щоб було видно де є незавершені теми.',
              ),
              const SizedBox(height: 16),
              _ProgressStrip(
                label: 'Довідник завершено',
                completedLabel: '${guide.read} із ${guide.total}',
                ratio: guide.completionRatio,
                accent: tokens.warningAccent,
              ),
              const SizedBox(height: 12),
              _ProgressStrip(
                label: 'Читання завершено',
                completedLabel: '${reading.read} із ${reading.total}',
                ratio: reading.completionRatio,
                accent: tokens.readingAccent,
              ),
              const SizedBox(height: 16),
              AppActionWrap(
                children: [
                  AppMetricTile(
                    label: 'Теми в процесі',
                    value: guide.studying,
                    accent: tokens.warningAccent,
                  ),
                  AppMetricTile(
                    label: 'Теми прочитано',
                    value: guide.read,
                    accent: tokens.successAccent,
                  ),
                  AppMetricTile(
                    label: 'Тексти в процесі',
                    value: reading.studying,
                    accent: tokens.readingAccent,
                  ),
                  AppMetricTile(
                    label: 'Тексти прочитано',
                    value: reading.read,
                    accent: tokens.successAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Що далі',
                subtitle: 'Рекомендації на основі вашого прогресу.',
              ),
              const SizedBox(height: 18),
              AppActionWrap(
                children: [
                  FilledButton.icon(
                    onPressed: study.needsReview > 0
                        ? () => onOpenFlashcards(FlashcardDeckMode.needsReview)
                        : onOpenWords,
                    icon: Icon(
                      study.needsReview > 0
                          ? Icons.refresh_rounded
                          : Icons.translate_rounded,
                    ),
                    label: Text(
                      study.needsReview > 0
                          ? 'Повторити слова'
                          : 'Відкрити слова',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenWriting,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('До письма'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenSprint,
                    icon: const Icon(Icons.timer_rounded),
                    label: const Text('Спринт'),
                  ),
                  OutlinedButton.icon(
                    onPressed: guide.studying > 0 ? onOpenGuide : onOpenReading,
                    icon: Icon(
                      guide.studying > 0
                          ? Icons.menu_book_rounded
                          : Icons.auto_stories_rounded,
                    ),
                    label: Text(
                      guide.studying > 0
                          ? 'Продовжити довідник'
                          : 'Продовжити читання',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
    required this.isDarkMode,
    required this.nightModeAccess,
    required this.onToggleThemeMode,
    required this.preferWritingPractice,
    required this.onPreferWritingPracticeChanged,
    required this.preferredFlashcardDeckMode,
    required this.onPreferredFlashcardDeckModeChanged,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Налаштування',
                subtitle:
                    'Ці параметри діють у поточній сесії. Тут можна змінити поведінку навігації та формат практики, який відкриватиметься за замовчуванням.',
              ),
              const SizedBox(height: 18),
              _SettingsSwitchTile(
                title: 'Нічний режим',
                subtitle: nightModeAccess.isEnabled
                    ? 'Перемикає застосунок на темну земляну палітру для вечірнього навчання.'
                    : nightModeAccess.description,
                value: isDarkMode,
                onChanged: (_) => onToggleThemeMode(),
                isLocked: !nightModeAccess.isEnabled,
                switchKey: const ValueKey('theme-toggle-switch'),
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: 'Автоматично ховати нижню панель',
                subtitle:
                    'Під час довгого перегляду сторінки вниз нижня панель тимчасово ховається, щоб звільнити більше місця на екрані.',
                value: autoHideBottomNavOnScroll,
                onChanged: onAutoHideBottomNavOnScrollChanged,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: 'ШІ-контексти для вправ',
                subtitle:
                    'Добирає короткі ситуації й приклади для вправ і словника з урахуванням вашого рівня, прогресу та слів, які ви зараз вивчаєте.',
                value: aiWordContextsEnabled,
                onChanged: onAiWordContextsEnabledChanged,
                isLocked: !aiWordContextsAccess.isEnabled,
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: 'ШІ-тексти для практики',
                subtitle:
                    'Створює короткі тексти під ваш рівень і темп навчання, поєднуючи нові слова з уже знайомою лексикою.',
                value: aiPracticeTextsEnabled,
                onChanged: onAiPracticeTextsEnabledChanged,
                isLocked: !aiPracticeTextsAccess.isEnabled,
              ),
              const SizedBox(height: 18),
              Text(
                'Формат практики за замовчуванням',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Оберіть, що відкриватиметься після натискання кнопки «Практика» в профілі.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              AppActionWrap(
                children: [
                  _SettingsChoiceChip(
                    label: 'Картки',
                    isSelected: !preferWritingPractice,
                    onTap: () => onPreferWritingPracticeChanged(false),
                  ),
                  _SettingsChoiceChip(
                    label: 'Письмо',
                    isSelected: preferWritingPractice,
                    onTap: () => onPreferWritingPracticeChanged(true),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Набір карток за замовчуванням',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Цей вибір застосовується, якщо за замовчуванням відкриваються картки.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              AppActionWrap(
                children: [
                  _SettingsChoiceChip(
                    label: 'Усі слова',
                    isSelected:
                        preferredFlashcardDeckMode ==
                        FlashcardDeckMode.allWords,
                    onTap: () => onPreferredFlashcardDeckModeChanged(
                      FlashcardDeckMode.allWords,
                    ),
                  ),
                  _SettingsChoiceChip(
                    label: 'У контексті',
                    isSelected:
                        preferredFlashcardDeckMode ==
                        FlashcardDeckMode.withContexts,
                    onTap: () => onPreferredFlashcardDeckModeChanged(
                      FlashcardDeckMode.withContexts,
                    ),
                  ),
                  _SettingsChoiceChip(
                    label: 'На повторення',
                    isSelected:
                        preferredFlashcardDeckMode ==
                        FlashcardDeckMode.needsReview,
                    onTap: () => onPreferredFlashcardDeckModeChanged(
                      FlashcardDeckMode.needsReview,
                    ),
                  ),
                ],
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
  });

  final String label;
  final String completedLabel;
  final double ratio;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.subtleSurface,
        borderRadius: BorderRadius.circular(20),
      ),
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
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.isLocked = false,
    this.switchKey,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLocked;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final isEnabled = onChanged != null;

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
                    color: isEnabled ? null : tokens.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isEnabled
                        ? tokens.mutedText
                        : tokens.mutedText.withValues(alpha: 0.8),
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
          Switch.adaptive(key: switchKey, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsChoiceChip extends StatelessWidget {
  const _SettingsChoiceChip({
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
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
