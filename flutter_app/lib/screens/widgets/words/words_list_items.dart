part of '../../words_screen.dart';

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
    required this.onCycleStatus,
    required this.onOpenDetails,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;
  final VoidCallback onCycleStatus;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final learningState = classifyWordLearningState(word);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpenDetails,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.translation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.transcription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniProgress(
                          label: 'П',
                          value: word.correct,
                          accent: tokens.successAccent,
                        ),
                        _MiniProgress(
                          label: 'Н',
                          value: word.wrong,
                          accent: tokens.dangerAccent,
                        ),
                        if (word.hasPlannedAudio)
                          _InlineWordAudioButton(
                            word: word,
                            audioPlayerFactory: audioPlayerFactory,
                            audioPlaybackAwareness: audioPlaybackAwareness,
                          ),
                        _WordStatusActionButton(
                          state: learningState,
                          onTap: onCycleStatus,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    word.hebrew,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    tooltip: 'Відкрити слово',
                    onPressed: onOpenDetails,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: tokens.vocabularyAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordStatusActionButton extends StatelessWidget {
  const _WordStatusActionButton({required this.state, required this.onTap});

  final WordLearningState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final presentation = _WordStatusPresentation.fromState(state, tokens);
    final foreground = presentation.accent;
    return Material(
      color: tokens.accentSurface(presentation.accent),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Tooltip(
          message: 'Змінити статус слова',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: tokens.accentStrongBorder(presentation.accent),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(presentation.icon, size: 14, color: foreground),
                const SizedBox(width: 6),
                Text(
                  presentation.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordStatusPresentation {
  const _WordStatusPresentation({
    required this.label,
    required this.icon,
    required this.accent,
  });

  factory _WordStatusPresentation.fromState(
    WordLearningState state,
    AppThemeTokens tokens,
  ) {
    return switch (state) {
      WordLearningState.unseen => _WordStatusPresentation(
        label: 'Не знаю',
        icon: Icons.help_outline_rounded,
        accent: tokens.vocabularyAccent,
      ),
      WordLearningState.needsReview => _WordStatusPresentation(
        label: 'Вчу',
        icon: Icons.school_rounded,
        accent: tokens.vocabularyAccent,
      ),
      WordLearningState.known => _WordStatusPresentation(
        label: 'Знаю',
        icon: Icons.check_rounded,
        accent: tokens.successAccent,
      ),
    };
  }

  final String label;
  final IconData icon;
  final Color accent;
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.accentMutedSurface(accent),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
