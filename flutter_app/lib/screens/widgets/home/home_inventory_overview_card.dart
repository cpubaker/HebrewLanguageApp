part of '../../home_screen.dart';

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final card = Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
        border: Border.all(color: tokens.accentSoftBorder(accent)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: onTap == null
          ? card
          : InkWell(
              borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
              onTap: onTap,
              child: card,
            ),
    );
  }
}

class _InventoryOverviewCard extends StatelessWidget {
  const _InventoryOverviewCard({
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    final summaryCards = [
      _SummaryCard(
        label: 'Слова',
        value: bundle.words.length,
        accent: tokens.successAccent,
        onTap: onOpenWords,
      ),
      _SummaryCard(
        label: 'Картки',
        value: bundle.words.where((word) => word.contexts.isNotEmpty).length,
        accent: tokens.warningAccent,
        onTap: onOpenFlashcards,
      ),
      _SummaryCard(
        label: 'Письмо',
        value: bundle.words
            .where((word) => word.writingCorrect > 0 || word.writingWrong > 0)
            .length,
        accent: tokens.newContentAccent,
        onTap: onOpenWriting,
      ),
      _SummaryCard(
        label: 'Довідник',
        value: bundle.guideLessons.length,
        accent: tokens.vocabularyAccent,
        onTap: onOpenGuide,
      ),
      _SummaryCard(
        label: 'Дієслова',
        value: bundle.verbLessons.length,
        accent: tokens.verbAccent,
        onTap: onOpenVerbs,
      ),
      _SummaryCard(
        label: 'Читання',
        value: bundle.readingLessons.length,
        accent: tokens.readingAccent,
        onTap: onOpenReading,
      ),
    ];

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Усі модулі',
            subtitle: 'Усі розділи навчальної бази зібрані в одному місці.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final card in summaryCards)
                    SizedBox(width: itemWidth, child: card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
