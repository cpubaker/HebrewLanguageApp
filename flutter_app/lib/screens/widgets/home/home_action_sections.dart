part of '../../home_screen.dart';

class _QuickActionStrip extends StatelessWidget {
  const _QuickActionStrip({
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Швидкі дії',
            subtitle: 'Швидкий доступ до основних вправ і матеріалів.',
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              FilledButton.icon(
                onPressed: () => onOpenFlashcards(FlashcardDeckMode.allWords),
                icon: const Icon(Icons.style_rounded),
                label: const Text('До карток'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWriting,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('До письма'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSprint,
                icon: const Icon(Icons.timer_rounded),
                label: const Text('До спринту'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWords,
                icon: const Icon(Icons.translate_rounded),
                label: const Text('До слів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenVerbs,
                icon: const Icon(Icons.play_lesson_rounded),
                label: const Text('До дієслів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenGuide,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('До довідника'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReading,
                icon: const Icon(Icons.auto_stories_rounded),
                label: const Text('До читання'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardPrimaryActionCard extends StatelessWidget {
  const _DashboardPrimaryActionCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.accentSurface(action.accent),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Продовжити',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).appTokens.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).appTokens.mutedText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: action.onTap,
                  icon: Icon(action.icon),
                  label: Text(action.buttonLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRecommendationsCard extends StatelessWidget {
  const _DashboardRecommendationsCard({required this.actions});

  final List<_DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Що далі',
            subtitle: 'Рекомендовані вправи й матеріали для продовження.',
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < actions.length; index += 1) ...[
            _DashboardRecommendationTile(action: actions[index]),
            if (index != actions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DashboardRecommendationTile extends StatelessWidget {
  const _DashboardRecommendationTile({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.subtleSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tokens.accentSurface(action.accent),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: action.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).appTokens.mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: action.onTap,
            child: Text(action.buttonLabel),
          ),
        ],
      ),
    );
  }
}
