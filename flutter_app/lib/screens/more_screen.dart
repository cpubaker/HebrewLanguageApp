import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../services/flashcard_session.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_metric_tile.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';
import 'workspace_screen.dart';

class MoreOverviewScreen extends StatelessWidget {
  const MoreOverviewScreen({super.key, required this.shortcuts});

  final List<WorkspaceShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.pagePadding.left,
        0,
        tokens.pagePadding.right,
        32,
      ),
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Швидкі переходи',
                subtitle:
                    'Тут зібрані короткі маршрути до ключових зон застосунку.',
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  for (var index = 0; index < shortcuts.length; index += 1)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == shortcuts.length - 1 ? 0 : 12,
                      ),
                      child: _MoreShortcutTile(shortcut: shortcuts[index]),
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
                title: 'Що є в цій зоні',
                subtitle:
                    'Розділ «Ще» збирає службові та оглядові екрани, які не повинні перевантажувати нижню навігацію.',
              ),
              const SizedBox(height: 14),
              AppActionWrap(
                children: [
                  AppStatChip(
                    label: 'Маршрутів',
                    value: shortcuts.length,
                    accent: const Color(0xFF2B5D4F),
                    icon: Icons.route_rounded,
                  ),
                  AppStatChip(
                    label: 'Оглядових секцій',
                    value: 3,
                    accent: const Color(0xFFB45309),
                    icon: Icons.insights_rounded,
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

class MoreProgressScreen extends StatelessWidget {
  const MoreProgressScreen({
    super.key,
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

    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.pagePadding.left,
        0,
        tokens.pagePadding.right,
        32,
      ),
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Прогрес',
                subtitle:
                    'Огляд того, як рухаються слова, практика та матеріали без переходу між модулями.',
              ),
              const SizedBox(height: 14),
              AppActionWrap(
                children: [
                  AppStatChip(
                    label: 'Слова відкрито',
                    value: study.seen,
                    accent: const Color(0xFF0F766E),
                    icon: Icons.translate_rounded,
                  ),
                  AppStatChip(
                    label: 'На повторення',
                    value: study.needsReview,
                    accent: const Color(0xFFB45309),
                    icon: Icons.refresh_rounded,
                  ),
                  AppStatChip(
                    label: 'Тем прочитано',
                    value: guide.read,
                    accent: const Color(0xFFB45309),
                    icon: Icons.menu_book_rounded,
                  ),
                  AppStatChip(
                    label: 'Текстів прочитано',
                    value: reading.read,
                    accent: const Color(0xFF1D4ED8),
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
                subtitle:
                    'Тут видно, як рухаються картки, письмо та загальний словниковий прогрес.',
              ),
              const SizedBox(height: 16),
              _ProgressStrip(
                label: 'Слова відкрито',
                completedLabel: '${study.seen} із ${study.total}',
                ratio: study.completionRatio,
                accent: const Color(0xFF0F766E),
              ),
              const SizedBox(height: 12),
              _ProgressStrip(
                label: 'Письмо відпрацьовано',
                completedLabel: '${writing.practiced} із ${writing.total}',
                ratio: writing.completionRatio,
                accent: const Color(0xFF8C3E9F),
              ),
              const SizedBox(height: 16),
              AppActionWrap(
                children: [
                  AppMetricTile(
                    label: 'Знайомі слова',
                    value: study.known,
                    accent: const Color(0xFF0F766E),
                  ),
                  AppMetricTile(
                    label: 'Повторити',
                    value: study.needsReview,
                    accent: const Color(0xFFB45309),
                  ),
                  AppMetricTile(
                    label: 'Письмо ок',
                    value: writing.known,
                    accent: const Color(0xFF8C3E9F),
                  ),
                  AppMetricTile(
                    label: 'Контексти',
                    value: flashcards.withContexts,
                    accent: const Color(0xFF1D4ED8),
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
                accent: const Color(0xFFB45309),
              ),
              const SizedBox(height: 12),
              _ProgressStrip(
                label: 'Читання завершено',
                completedLabel: '${reading.read} із ${reading.total}',
                ratio: reading.completionRatio,
                accent: const Color(0xFF1D4ED8),
              ),
              const SizedBox(height: 16),
              AppActionWrap(
                children: [
                  AppMetricTile(
                    label: 'Теми в процесі',
                    value: guide.studying,
                    accent: const Color(0xFFB45309),
                  ),
                  AppMetricTile(
                    label: 'Теми прочитано',
                    value: guide.read,
                    accent: const Color(0xFF2B5D4F),
                  ),
                  AppMetricTile(
                    label: 'Тексти в процесі',
                    value: reading.studying,
                    accent: const Color(0xFF1D4ED8),
                  ),
                  AppMetricTile(
                    label: 'Тексти прочитано',
                    value: reading.read,
                    accent: const Color(0xFF2B5D4F),
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
                subtitle:
                    'Швидкі дії, які мають найбільший сенс з огляду на поточний прогрес.',
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

class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({
    super.key,
    required this.autoHideBottomNavOnScroll,
    required this.onAutoHideBottomNavOnScrollChanged,
    required this.preferWritingPractice,
    required this.onPreferWritingPracticeChanged,
    required this.preferredFlashcardDeckMode,
    required this.onPreferredFlashcardDeckModeChanged,
  });

  final bool autoHideBottomNavOnScroll;
  final ValueChanged<bool> onAutoHideBottomNavOnScrollChanged;
  final bool preferWritingPractice;
  final ValueChanged<bool> onPreferWritingPracticeChanged;
  final FlashcardDeckMode preferredFlashcardDeckMode;
  final ValueChanged<FlashcardDeckMode> onPreferredFlashcardDeckModeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.pagePadding.left,
        0,
        tokens.pagePadding.right,
        32,
      ),
      children: [
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Налаштування',
                subtitle:
                    'Локальні налаштування для поточної сесії. Тут можна керувати поведінкою shell і точками входу в практику.',
              ),
              const SizedBox(height: 18),
              _SettingsSwitchTile(
                title: 'Автоховати нижню навігацію',
                subtitle:
                    'Коли опція активна, нижня панель ховається під час довгого вертикального скролу.',
                value: autoHideBottomNavOnScroll,
                onChanged: onAutoHideBottomNavOnScrollChanged,
              ),
              const SizedBox(height: 12),
              const _SettingsSwitchTile(
                title: 'ШІ-генерація контексту для вправ',
                subtitle:
                    'Стане доступною, коли підключимо генерацію навчальних контекстів.',
                value: false,
              ),
              const SizedBox(height: 12),
              const _SettingsSwitchTile(
                title: 'ШІ-генерація текстів',
                subtitle:
                    'Поки що недоступно. Перемикач з’явився як майбутня опція.',
                value: false,
              ),
              const SizedBox(height: 18),
              Text(
                'Практика за замовчуванням',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Це впливає на shortcut «Практика» у розділі «Ще».',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
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
                'Режим карток за замовчуванням',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Використовується, коли shortcut «Практика» відкриває саме картки.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              AppActionWrap(
                children: [
                  _SettingsChoiceChip(
                    label: 'Усі',
                    isSelected:
                        preferredFlashcardDeckMode ==
                        FlashcardDeckMode.allWords,
                    onTap: () => onPreferredFlashcardDeckModeChanged(
                      FlashcardDeckMode.allWords,
                    ),
                  ),
                  _SettingsChoiceChip(
                    label: 'Контексти',
                    isSelected:
                        preferredFlashcardDeckMode ==
                        FlashcardDeckMode.withContexts,
                    onTap: () => onPreferredFlashcardDeckModeChanged(
                      FlashcardDeckMode.withContexts,
                    ),
                  ),
                  _SettingsChoiceChip(
                    label: 'Повторення',
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
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

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
          Switch.adaptive(value: value, onChanged: onChanged),
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

class _MoreShortcutTile extends StatelessWidget {
  const _MoreShortcutTile({required this.shortcut});

  final WorkspaceShortcut shortcut;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: shortcut.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: shortcut.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: shortcut.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(shortcut.icon, color: shortcut.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcut.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: shortcut.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
