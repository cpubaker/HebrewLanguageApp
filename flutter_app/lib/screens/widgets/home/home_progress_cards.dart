part of '../../home_screen.dart';

class _FlashcardFocusCard extends StatelessWidget {
  const _FlashcardFocusCard({
    required this.snapshot,
    required this.onOpenAll,
    required this.onOpenContext,
    required this.onOpenReview,
  });

  final FlashcardFocusSnapshot snapshot;
  final VoidCallback onOpenAll;
  final VoidCallback? onOpenContext;
  final VoidCallback? onOpenReview;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Картки на сьогодні',
            subtitle: snapshot.needsReview > 0
                ? 'У вас є слова на повторення. Можна продовжити або перейти до карток із прикладами.'
                : 'Оберіть режим: усі слова або картки з прикладами.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppMetricTile(
                label: 'Усі',
                value: snapshot.total,
                accent: tokens.primaryAccent,
              ),
              AppMetricTile(
                label: 'З прикладами',
                value: snapshot.withContexts,
                accent: tokens.contextAccent,
              ),
              AppMetricTile(
                label: 'На повторенні',
                value: snapshot.needsReview,
                accent: tokens.warningAccent,
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: snapshot.known,
                accent: tokens.successAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              if (onOpenReview != null)
                FilledButton.icon(
                  onPressed: onOpenReview,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Продовжити'),
                ),
              OutlinedButton.icon(
                onPressed: onOpenContext,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('З прикладами'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenAll,
                icon: const Icon(Icons.style_outlined),
                label: const Text('Усі'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyStreakCard extends StatelessWidget {
  const _StudyStreakCard({required this.streak});

  final StudyStreakSnapshot streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final currentDaysLabel = _dayCountLabel(streak.currentDays);
    final subtitle = _streakSubtitle(streak);

    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.accentMediumSurface(tokens.warningAccent),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: tokens.warningAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Серія занять',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  streak.currentDays > 0
                      ? '$currentDaysLabel поспіль'
                      : 'Почніть серію сьогодні',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedText,
                    height: 1.45,
                  ),
                ),
                if (streak.activityDays > 0) ...[
                  const SizedBox(height: 12),
                  AppStatChip(
                    label: 'Активні дні',
                    value: streak.activityDays,
                    accent: tokens.primaryAccent,
                    backgroundColor: tokens.subtleSurface,
                    textColor: theme.colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _streakSubtitle(StudyStreakSnapshot streak) {
    if (streak.wasActiveToday) {
      return 'Сьогоднішнє заняття вже враховано в серії.';
    }

    if (streak.wasActiveYesterday) {
      return 'Серія ще тримається. Зробіть одне тренування сьогодні, щоб продовжити її.';
    }

    if (streak.hasActivity) {
      return 'Остання активність була раніше, тож поточна серія почнеться з нового заняття.';
    }

    return 'Коли пройдете перше тренування, тут з’явиться ваша серія занять.';
  }

  String _dayCountLabel(int days) {
    final suffix = days % 100;
    final lastDigit = days % 10;
    final noun = suffix >= 11 && suffix <= 14
        ? 'днів'
        : lastDigit == 1
        ? 'день'
        : lastDigit >= 2 && lastDigit <= 4
        ? 'дні'
        : 'днів';

    return '$days $noun';
  }
}

class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({required this.progress});

  final StudyProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Прогрес навчання',
            subtitle:
                'Прогрес зберігається на цьому пристрої, тож можна спокійно продовжити пізніше.',
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.completionRatio,
              backgroundColor: Theme.of(context).appTokens.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.successAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Опрацьовано ${progress.seen} із ${progress.total} слів',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).appTokens.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppMetricTile(
                label: 'Опрацьовані',
                value: progress.seen,
                accent: tokens.primaryAccent,
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: progress.known,
                accent: tokens.successAccent,
              ),
              AppMetricTile(
                label: 'Повторити',
                value: progress.needsReview,
                accent: tokens.warningAccent,
              ),
              AppMetricTile(
                label: 'Нові',
                value: progress.unseen,
                accent: tokens.newContentAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
