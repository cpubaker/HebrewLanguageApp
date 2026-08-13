part of '../../home_screen.dart';

class _GreetingHeaderRow extends StatelessWidget {
  const _GreetingHeaderRow({
    required this.greeting,
    required this.streak,
  });

  final String greeting;
  final StudyStreakSnapshot streak;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final hasStreak = streak.currentDays > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              greeting,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasStreak) ...[
            const SizedBox(width: 12),
            _StreakChip(currentDays: streak.currentDays, tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.currentDays, required this.tokens});

  final int currentDays;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final accent = tokens.warningAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentSurface(accent),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.accentSoftBorder(accent)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: accent, size: 18),
          const SizedBox(width: 6),
          Text(
            '$currentDays',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayActionCard extends StatelessWidget {
  const _TodayActionCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final isWelcome = action.kind == _DashboardActionKind.welcome;
    final localizations = AppLocalizations.of(context);
    final eyebrow = isWelcome
        ? localizations.homeActionFirstStep
        : localizations.homeActionToday;

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
                  eyebrow,
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
