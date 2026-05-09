part of '../../words_screen.dart';

abstract class _WordAudioButtonState<T extends StatefulWidget>
    extends State<T> {
  late final LearningAudioPlayer _audioPlayer = audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  AudioPlaybackAwareness get audioPlaybackAwareness;

  CreateLearningAudioPlayer get audioPlayerFactory;

  LearningWord get word;

  bool get clearPlayingAfterStop => false;

  bool get prepareAudioBeforeEnable => false;

  bool get _isAudioEnabled => _hasAudio && !_isBusy;

  String get _audioAssetPath => word.audioAssetPath ?? '';

  String get _audioTooltip {
    if (_isCheckingAvailability) {
      return 'Перевіряємо аудіо слова';
    }

    if (!_hasAudio) {
      return 'Аудіо для слова ще недоступне';
    }

    return _isPlaying ? 'Зупинити вимову слова' : 'Увімкнути вимову слова';
  }

  @override
  void initState() {
    super.initState();
    _playbackSubscription = _audioPlayer.isPlayingStream.listen((isPlaying) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlaying = isPlaying;
      });
    });
    unawaited(_checkAudioAvailability());
  }

  Future<void> _checkAudioAvailability() async {
    final audioAssetPath = word.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasAudio = false;
        _isCheckingAvailability = false;
      });
      return;
    }

    var hasAudio = await _audioPlayer.assetExists(audioAssetPath);
    if (hasAudio && prepareAudioBeforeEnable) {
      try {
        hasAudio = await _audioPlayer.prepareAsset(audioAssetPath);
      } catch (_) {
        hasAudio = false;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasAudio = hasAudio;
      _isCheckingAvailability = false;
    });
  }

  Future<void> _togglePlayback() async {
    final wasPlaying = _isPlaying;

    setState(() {
      _isBusy = true;
    });

    try {
      if (wasPlaying) {
        await _audioPlayer.stop();
      } else {
        await showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: audioPlaybackAwareness,
        );
        await _audioPlayer.playAsset(_audioAssetPath);
      }

      if (!mounted) {
        return;
      }

      if (wasPlaying && clearPlayingAfterStop) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        updatePlaybackErrorState(error);
      });
      showPlaybackErrorFeedback(error);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void updatePlaybackErrorState(Object error) {}

  void showPlaybackErrorFeedback(Object error) {}

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
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
    _hasAudio = false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Material(
      color: tokens.accentSurface(tokens.vocabularyAccent),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: _isAudioEnabled ? _togglePlayback : null,
        borderRadius: BorderRadius.circular(999),
        child: Tooltip(
          message: _audioTooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isBusy)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.vocabularyAccent,
                    ),
                  )
                else
                  Icon(
                    _isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                    size: 14,
                    color: _hasAudio
                        ? tokens.vocabularyAccent
                        : tokens.secondaryText,
                  ),
                const SizedBox(width: 6),
                Text(
                  'Аудіо',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _hasAudio
                        ? tokens.vocabularyAccent
                        : tokens.secondaryText,
                    fontWeight: FontWeight.w700,
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
    _isPlaying = false;
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
        tooltip: _audioTooltip,
        onPressed: _isAudioEnabled ? _togglePlayback : null,
        icon: _isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.vocabularyAccent,
                ),
              )
            : Icon(
                _isPlaying
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
