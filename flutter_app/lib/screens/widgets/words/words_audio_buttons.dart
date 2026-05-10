part of '../../words_screen.dart';

abstract class _WordAudioButtonState<T extends StatefulWidget>
    extends State<T> {
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory: audioPlayerFactory,
  )..addListener(_handleAudioStateChanged);

  AudioPlaybackAwareness get audioPlaybackAwareness;

  CreateLearningAudioPlayer get audioPlayerFactory;

  LearningWord get word;

  bool get clearPlayingAfterStop => false;

  bool get prepareAudioBeforeEnable => false;

  bool get _isAudioEnabled => _audioController.canToggle;

  String get _audioAssetPath => word.audioAssetPath ?? '';

  String get _audioTooltip {
    if (_audioController.isCheckingAvailability) {
      return 'Перевіряємо аудіо слова';
    }

    if (!_audioController.hasAudio) {
      return 'Аудіо для слова ще недоступне';
    }

    return _audioController.isPlaying
        ? 'Зупинити вимову слова'
        : 'Увімкнути вимову слова';
  }

  @override
  void initState() {
    super.initState();
    unawaited(_checkAudioAvailability());
  }

  Future<void> _checkAudioAvailability() async {
    await _audioController.checkAvailability(
      word.audioAssetPath,
      prepare: prepareAudioBeforeEnable,
    );
  }

  Future<void> _togglePlayback() async {
    try {
      await _audioController.toggle(
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
    _audioController
      ..removeListener(_handleAudioStateChanged)
      ..dispose();
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
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_InlineWordAudioButton> createState() => _InlineWordAudioButtonState();
}

class _InlineWordAudioButtonState
    extends _WordAudioButtonState<_InlineWordAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  CreateLearningAudioPlayer get audioPlayerFactory => widget.audioPlayerFactory;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    _audioController.markUnavailable();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final isLoading =
        _audioController.isBusy || _audioController.isCheckingAvailability;

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
              _audioController.isPlaying
                  ? Icons.stop_circle_outlined
                  : Icons.volume_up_rounded,
            ),
    );
  }
}

class _WordDetailsAudioButton extends StatefulWidget {
  const _WordDetailsAudioButton({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_WordDetailsAudioButton> createState() =>
      _WordDetailsAudioButtonState();
}

class _WordDetailsAudioButtonState
    extends _WordAudioButtonState<_WordDetailsAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  CreateLearningAudioPlayer get audioPlayerFactory => widget.audioPlayerFactory;

  @override
  bool get clearPlayingAfterStop => true;

  @override
  bool get prepareAudioBeforeEnable => true;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    _audioController.clearPlaying();
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
        icon: _audioController.isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.vocabularyAccent,
                ),
              )
            : Icon(
                _audioController.isPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                color: _audioController.hasAudio
                    ? tokens.vocabularyAccent
                    : tokens.secondaryText,
              ),
      ),
    );
  }
}
