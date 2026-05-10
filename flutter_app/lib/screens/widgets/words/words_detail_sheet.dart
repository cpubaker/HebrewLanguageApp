part of '../../words_screen.dart';

void _showWordDetailsSheet({
  required BuildContext context,
  required LearningWord initialWord,
  required Future<LearningWord> wordFuture,
  required CreateLearningAudioPlayer audioPlayerFactory,
  required AudioPlaybackAwareness audioPlaybackAwareness,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).appTokens.elevatedSurface,
    builder: (context) {
      final theme = Theme.of(context);
      final tokens = theme.appTokens;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: FutureBuilder<LearningWord>(
            future: wordFuture,
            initialData: initialWord,
            builder: (context, snapshot) {
              final detailWord = snapshot.data ?? initialWord;
              final isLoadingContexts =
                  snapshot.connectionState != ConnectionState.done;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detailWord.hebrew,
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                detailWord.translation,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                detailWord.transcription,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (detailWord.hasPlannedAudio) ...[
                          const SizedBox(width: 16),
                          _WordDetailsAudioButton(
                            word: detailWord,
                            audioPlayerFactory: audioPlayerFactory,
                            audioPlaybackAwareness: audioPlaybackAwareness,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatPill(
                            label: 'Правильно',
                            value: detailWord.correct,
                            accent: tokens.successAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatPill(
                            label: 'Помилки',
                            value: detailWord.wrong,
                            accent: tokens.dangerAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ID: ${detailWord.wordId}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _WordContextsSection(
                      contexts: detailWord.contexts,
                      isLoading: isLoadingContexts,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

class _WordContextsSection extends StatelessWidget {
  const _WordContextsSection({required this.contexts, required this.isLoading});

  final List<LearningContext> contexts;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final visibleContexts = contexts
        .where(
          (entry) =>
              entry.hebrew.trim().isNotEmpty ||
              entry.translation.trim().isNotEmpty,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Контексти',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (visibleContexts.isEmpty)
          Text(
            isLoading
                ? 'Шукаємо новий контекст...'
                : 'Для цього слова ще немає контексту.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          )
        else
          for (final entry in visibleContexts) ...[
            _WordContextTile(contextEntry: entry),
            if (entry != visibleContexts.last) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _WordContextTile extends StatelessWidget {
  const _WordContextTile({required this.contextEntry});

  final LearningContext contextEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final hasHebrew = contextEntry.hebrew.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.subtleSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (contextEntry.isAiGenerated) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: ContextSourceBadge(context: contextEntry),
            ),
            const SizedBox(height: 8),
          ],
          if (contextEntry.hebrew.trim().isNotEmpty)
            Text(
              contextEntry.hebrew,
              textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
              textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          if (contextEntry.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              contextEntry.translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.accentBorder(accent)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$label: $value',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
