part of '../../words_screen.dart';

abstract class _WordAudioButton<T extends StatefulWidget> extends State<T> {
  AudioPlaybackAwareness get audioPlaybackAwareness;

  LearningAudioController get audioController;

  LearningWord get word;

  bool get clearPlayingAfterStop => false;

  bool get prepareAudioBeforeEnable => false;

  String get _audioAssetPath => word.audioAssetPath ?? '';

  bool get _hasAudio =>
      audioController.cachedAvailabilityFor(_audioAssetPath) == true;

  bool get _isProbingAudio =>
      audioController.isProbingAvailabilityFor(_audioAssetPath) ||
      audioController.cachedAvailabilityFor(_audioAssetPath) == null;

  bool get _isAudioBusy => audioController.isBusyFor(_audioAssetPath);

  bool get _isAudioPlaying => audioController.isPlayingFor(_audioAssetPath);

  bool get _isAudioEnabled => _hasAudio && !_isAudioBusy;

  String get _audioTooltip {
    if (_isProbingAudio) {
      return 'Перевіряємо аудіо слова';
    }

    if (!_hasAudio) {
      return 'Аудіо для слова ще недоступне';
    }

    return _isAudioPlaying
        ? 'Зупинити вимову слова'
        : 'Увімкнути вимову слова';
  }

  @override
  void initState() {
    super.initState();
    audioController.addListener(_handleAudioStateChanged);
    unawaited(_probeAudioAvailability());
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_probeAudioAvailability());
  }

  Future<void> _probeAudioAvailability() async {
    final assetPath = _audioAssetPath;
    if (assetPath.isEmpty) {
      return;
    }
    final shouldPrepare =
        prepareAudioBeforeEnable && !audioController.isPlaying;
    await audioController.probeAvailability(
      assetPath,
      prepare: shouldPrepare,
    );
  }

  Future<void> _togglePlayback() async {
    try {
      await audioController.toggle(
        _audioAssetPath,
        beforePlay: () => showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: audioPlaybackAwareness,
        ),
        clearPlayingAfterStop: clearPlayingAfterStop,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      updatePlaybackErrorState(error);
      showPlaybackErrorFeedback(error);
    }
  }

  void updatePlaybackErrorState(Object error) {}

  void showPlaybackErrorFeedback(Object error) {}

  @override
  void dispose() {
    audioController.removeListener(_handleAudioStateChanged);
    super.dispose();
  }

  void _handleAudioStateChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }
}

class _InlineWordAudioButton extends StatefulWidget {
  const _InlineWordAudioButton({
    required this.word,
    required this.audioController,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final LearningAudioController audioController;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_InlineWordAudioButton> createState() => _InlineWordAudioButtonState();
}

class _InlineWordAudioButtonState
    extends _WordAudioButton<_InlineWordAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  LearningAudioController get audioController => widget.audioController;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    audioController.markUnavailableForPath(_audioAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final isLoading = _isAudioBusy || _isProbingAudio;

    return IconButton.filledTonal(
      key: ValueKey<String>('word-list-audio-button-${word.wordId}'),
      tooltip: _audioTooltip,
      onPressed: _isAudioEnabled ? _togglePlayback : null,
      iconSize: 18,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: tokens.accentSurface(tokens.vocabularyAccent),
        disabledBackgroundColor: tokens.accentMutedSurface(
          tokens.vocabularyAccent,
        ),
        foregroundColor: tokens.vocabularyAccent,
        disabledForegroundColor: tokens.secondaryText,
      ),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tokens.vocabularyAccent,
              ),
            )
          : Icon(
              _isAudioPlaying
                  ? Icons.stop_circle_outlined
                  : Icons.volume_up_rounded,
            ),
    );
  }
}

class _WordDetailsAudioButton extends StatefulWidget {
  const _WordDetailsAudioButton({
    required this.word,
    required this.audioController,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final LearningAudioController audioController;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_WordDetailsAudioButton> createState() =>
      _WordDetailsAudioButtonState();
}

class _WordDetailsAudioButtonState
    extends _WordAudioButton<_WordDetailsAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  LearningAudioController get audioController => widget.audioController;

  @override
  bool get clearPlayingAfterStop => true;

  @override
  bool get prepareAudioBeforeEnable => true;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    audioController.clearPlaying();
  }

  @override
  void showPlaybackErrorFeedback(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не вдалося відтворити вимову слова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.accentSurface(tokens.vocabularyAccent),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        key: ValueKey<String>('word-detail-audio-button-${word.wordId}'),
        tooltip: _audioTooltip,
        onPressed: _isAudioEnabled ? _togglePlayback : null,
        icon: _isAudioBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.vocabularyAccent,
                ),
              )
            : Icon(
                _isAudioPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                color: _hasAudio
                    ? tokens.vocabularyAccent
                    : tokens.secondaryText,
              ),
      ),
    );
  }
}
