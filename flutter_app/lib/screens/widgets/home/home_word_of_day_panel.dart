part of '../../home_screen.dart';

class _WordOfDayHeroPanel extends StatefulWidget {
  const _WordOfDayHeroPanel({
    required this.entry,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final WordOfDayEntry entry;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_WordOfDayHeroPanel> createState() => _WordOfDayHeroPanelState();
}

class _WordOfDayHeroPanelState extends State<_WordOfDayHeroPanel> {
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory: widget.audioPlayerFactory,
  )..addListener(_handleAudioStateChanged);

  String? get _audioAssetPath {
    final path = widget.entry.word.audioAssetPath?.trim();
    return path == null || path.isEmpty ? null : path;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_checkAudioAvailability());
  }

  @override
  void didUpdateWidget(covariant _WordOfDayHeroPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.word.wordId != widget.entry.word.wordId ||
        oldWidget.entry.word.audioAssetPath !=
            widget.entry.word.audioAssetPath) {
      unawaited(_audioController.stop(clearAvailability: true));
      unawaited(_checkAudioAvailability());
    }
  }

  Future<void> _checkAudioAvailability() async {
    await _audioController.checkAvailability(_audioAssetPath, prepare: true);
  }

  Future<void> _toggleAudio() async {
    final audioAssetPath = _audioAssetPath;
    if (audioAssetPath == null || !_audioController.canToggle) {
      return;
    }

    try {
      await _audioController.toggle(
        audioAssetPath,
        beforePlay: () => showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: widget.audioPlaybackAwareness,
        ),
        clearPlayingAfterStop: true,
      );
    } catch (error) {
      debugPrint('Failed to play word of day audio: $error');
      if (mounted) {
        _audioController.clearPlaying();
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).wordOfDayAudioFailure),
            ),
          );
      }
    }
  }

  void _handleAudioStateChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _audioController
      ..removeListener(_handleAudioStateChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final localizations = AppLocalizations.of(context);
    final contextSentence = widget.entry.context;
    final isCheckingAudio = _audioController.isCheckingAvailability;
    final hasAudio = _audioController.hasAudio;
    final isAudioBusy = _audioController.isBusy;
    final isAudioPlaying = _audioController.isPlaying;
    final audioEnabled = _audioController.canToggle && !isCheckingAudio;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tokens.heroChipBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  localizations.wordOfDay,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.heroText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: isCheckingAudio
                    ? localizations.wordOfDayAudioChecking
                    : hasAudio
                    ? (isAudioPlaying
                          ? localizations.wordOfDayAudioStop
                          : localizations.wordOfDayAudioPlay)
                    : localizations.wordOfDayAudioUnavailable,
                child: Material(
                  color: tokens.heroChipBackground,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const ValueKey('word-of-day-audio-button'),
                    customBorder: const CircleBorder(),
                    onTap: audioEnabled ? _toggleAudio : null,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: isCheckingAudio || isAudioBusy
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tokens.heroText,
                                  ),
                                ),
                              )
                            : Icon(
                                hasAudio
                                    ? (isAudioPlaying
                                          ? Icons.stop_rounded
                                          : Icons.volume_up_rounded)
                                    : Icons.volume_off_rounded,
                                color: hasAudio
                                    ? tokens.heroText
                                    : tokens.heroMutedText,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.entry.word.hebrew,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: tokens.heroText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.entry.word.translation,
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.entry.word.transcription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.heroMutedText,
              height: 1.35,
            ),
          ),
          if (contextSentence != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.heroChipBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contextSentence.hebrew.trim().isNotEmpty) ...[
                    Text(
                      contextSentence.hebrew,
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.heroText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (contextSentence.translation.trim().isNotEmpty) ...[
                    if (contextSentence.hebrew.trim().isNotEmpty)
                      const SizedBox(height: 6),
                    Text(
                      contextSentence.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.heroMutedText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyWordOfDayHeroPanel extends StatelessWidget {
  const _EmptyWordOfDayHeroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final localizations = AppLocalizations.of(context);

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
              localizations.wordOfDay,
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.heroText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.wordOfDayEmpty,
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
