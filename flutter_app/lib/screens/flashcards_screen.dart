import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_player.dart';
import '../services/practice_time_format.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/context_source_badge.dart';
import 'widgets/practice_completion_card.dart';
import 'widgets/practice_audio_button.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_panel.dart';
import 'widgets/practice_stat_pill.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
    this.initialDeckMode = FlashcardDeckMode.allWords,
    this.deckRequestToken = 0,
    this.audioPlayerFactory,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;
  final FlashcardDeckMode initialDeckMode;
  final int deckRequestToken;
  final CreateLearningAudioPlayer? audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  static const double _swipeVelocityThreshold = 325;

  late final FlashcardSession _session;
  late final LearningAudioPlayer _audioPlayer =
      (widget.audioPlayerFactory ?? createAssetLearningAudioPlayer)();

  FlashcardCard? _currentCard;
  FlashcardAnswerResult? _currentAnswer;
  StreamSubscription<bool>? _playbackSubscription;
  bool _showSessionDetails = false;
  bool _isAudioBusy = false;
  bool _isAudioPlaying = false;
  bool _hasCurrentAudio = false;
  int _audioRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _session = FlashcardSession(widget.words, deckMode: widget.initialDeckMode);
    _playbackSubscription = _audioPlayer.isPlayingStream.listen((isPlaying) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAudioPlaying = isPlaying;
      });
    });
    _moveToNextCard();
  }

  @override
  void didUpdateWidget(covariant FlashcardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deckRequestToken != widget.deckRequestToken) {
      _session.resetDeck(mode: widget.initialDeckMode);
      _moveToNextCard();
    }
  }

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  void _moveToNextCard() {
    final nextCard = _session.nextCard();
    setState(() {
      _currentCard = nextCard;
      _currentAnswer = null;
      _showSessionDetails = false;
      _hasCurrentAudio = false;
    });
    unawaited(_syncWordAudio(nextCard?.word));
  }

  void _answerCard(bool known) {
    setState(() {
      _currentAnswer = _session.answerCard(known);
    });

    final answer = _currentAnswer;
    if (answer != null) {
      widget.onWordProgressChanged(answer.word);
    }
  }

  void _changeDeckMode(FlashcardDeckMode mode) {
    _session.setDeckMode(mode);
    final nextCard = _session.nextCard();
    setState(() {
      _currentCard = nextCard;
      _currentAnswer = null;
      _showSessionDetails = false;
      _hasCurrentAudio = false;
    });
    unawaited(_syncWordAudio(nextCard?.word));
  }

  void _handleCardSwipe(DragEndDetails details) {
    if (_currentCard == null || _currentAnswer != null) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) {
      return;
    }

    _answerCard(velocity > 0);
  }

  void _restartDeck([FlashcardDeckMode? mode]) {
    _session.resetDeck(mode: mode ?? _session.deckMode);
    final nextCard = _session.nextCard();
    setState(() {
      _currentCard = nextCard;
      _currentAnswer = null;
      _showSessionDetails = false;
      _hasCurrentAudio = false;
    });
    unawaited(_syncWordAudio(nextCard?.word));
  }

  Future<void> _syncWordAudio(LearningWord? word) async {
    final requestToken = ++_audioRequestToken;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    if (!mounted || _audioRequestToken != requestToken) {
      return;
    }

    final audioAssetPath = word?.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      return;
    }

    final hasAudio = await _audioPlayer.assetExists(audioAssetPath);
    if (!mounted || _audioRequestToken != requestToken || !hasAudio) {
      return;
    }

    try {
      setState(() {
        _hasCurrentAudio = true;
      });
      await _audioPlayer.playAsset(audioAssetPath);
    } catch (_) {}
  }

  Future<void> _replayCurrentWordAudio() async {
    final word = (_currentAnswer?.word ?? _currentCard?.word);
    final audioAssetPath = word?.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      return;
    }
    if (!_hasCurrentAudio) {
      return;
    }

    final requestToken = ++_audioRequestToken;

    setState(() {
      _isAudioBusy = true;
    });

    try {
      if (_isAudioPlaying) {
        await _audioPlayer.stop();
        return;
      }

      await _audioPlayer.stop();
      if (!mounted || _audioRequestToken != requestToken) {
        return;
      }

      final hasAudio = await _audioPlayer.assetExists(audioAssetPath);
      if (!mounted || _audioRequestToken != requestToken || !hasAudio) {
        return;
      }

      await showAudioPlaybackHintIfNeeded(
        context: context,
        awareness: widget.audioPlaybackAwareness,
      );
      if (!mounted || _audioRequestToken != requestToken) {
        return;
      }

      await _audioPlayer.playAsset(audioAssetPath);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося відтворити озвучку слова.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAudioBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final theme = Theme.of(context);
    final currentCard = _currentCard;
    if (currentCard == null) {
      if (_session.wordCount > 0 && _session.answeredCount > 0) {
        return _CompletedFlashcardsState(
          mode: _session.deckMode,
          wordCount: _session.wordCount,
          correctAnswers: _session.correctAnswers,
          repeatAnswers: _session.repeatAnswers,
          reviewWordCount: _session.reviewWordCount,
          onRestartDeck: _restartDeck,
          onChanged: _changeDeckMode,
        );
      }

      return _EmptyFlashcardsState(
        mode: _session.deckMode,
        onChanged: _changeDeckMode,
      );
    }

    final word = _currentAnswer?.word ?? currentCard.word;
    final currentContext = _currentAnswer?.context ?? currentCard.context;
    final stats = _session.currentWordStats();
    final hasAnswered = _currentAnswer != null;
    final isKnownAnswer = _currentAnswer?.known == true;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        GestureDetector(
          onHorizontalDragEnd: hasAnswered ? null : _handleCardSwipe,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tokens.elevatedSurface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowColor,
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PromptPanel(
                  hebrew: word.hebrew,
                  transcription: word.transcription,
                  audioButton: _hasCurrentAudio
                      ? PracticeAudioButton(
                          key: const ValueKey('flashcards_audio_button'),
                          isBusy: _isAudioBusy,
                          isPlaying: _isAudioPlaying,
                          onPressed: _isAudioBusy
                              ? null
                              : _replayCurrentWordAudio,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                _FlashcardContextPanel(
                  context: currentContext,
                  isAnswerRevealed: hasAnswered,
                ),
                const SizedBox(height: 18),
                if (hasAnswered)
                  _AnswerRevealCard(
                    isKnownAnswer: isKnownAnswer,
                    translation: word.translation,
                    lastCorrect: stats.lastCorrect == null
                        ? null
                        : formatPracticeTimestamp(stats.lastCorrect!),
                  )
                else
                  _SwipeHintStrip(
                    onRepeatTap: () => _answerCard(false),
                    onKnowTap: () => _answerCard(true),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: PracticeStatPill(
                        label: 'Вірно',
                        value: stats.correct,
                        icon: Icons.check_rounded,
                        accent: tokens.successAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PracticeStatPill(
                        label: 'Помилки',
                        value: stats.wrong,
                        icon: Icons.close_rounded,
                        accent: tokens.dangerAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (hasAnswered)
                  FilledButton.icon(
                    onPressed: _moveToNextCard,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _session.seenCount == _session.wordCount
                          ? 'До підсумку'
                          : 'Далі',
                    ),
                  )
                else
                  Text(
                    'Змахніть картку або натисніть потрібний варіант.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                const SizedBox(height: 14),
                _SessionDetailsSection(
                  isExpanded: _showSessionDetails,
                  deckLabel: _deckLabel(_session.deckMode),
                  currentCardNumber: _session.currentCardNumber,
                  wordCount: _session.wordCount,
                  remainingCount: _session.remainingCount,
                  sessionProgress: _session.sessionProgress,
                  correctCount: stats.correct,
                  wrongCount: stats.wrong,
                  onToggle: () {
                    setState(() {
                      _showSessionDetails = !_showSessionDetails;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _deckLabel(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Усі слова';
      case FlashcardDeckMode.withContexts:
        return 'З прикладами';
      case FlashcardDeckMode.needsReview:
        return 'На повторення';
    }
  }
}

class _SessionDetailsSection extends StatelessWidget {
  const _SessionDetailsSection({
    required this.isExpanded,
    required this.deckLabel,
    required this.currentCardNumber,
    required this.wordCount,
    required this.remainingCount,
    required this.sessionProgress,
    required this.correctCount,
    required this.wrongCount,
    required this.onToggle,
  });

  final bool isExpanded;
  final String deckLabel;
  final int currentCardNumber;
  final int wordCount;
  final int remainingCount;
  final double sessionProgress;
  final int correctCount;
  final int wrongCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return PracticePanel(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Поточна сесія',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentCardNumber із $wordCount, $deckLabel',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: tokens.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    deckLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: tokens.secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: sessionProgress == 0 ? 0.02 : sessionProgress,
                      backgroundColor: tokens.progressTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tokens.successAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remainingCount > 0
                        ? 'Після неї лишиться ще $remainingCount карток'
                        : 'Це остання картка',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PracticeStatPill(
                          label: 'Вірно',
                          value: correctCount,
                          icon: Icons.check_rounded,
                          accent: tokens.successAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PracticeStatPill(
                          label: 'Помилки',
                          value: wrongCount,
                          icon: Icons.close_rounded,
                          accent: tokens.dangerAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.hebrew,
    required this.transcription,
    this.audioButton,
  });

  final String hebrew;
  final String transcription;
  final Widget? audioButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.practicePromptGradientStart,
            tokens.practicePromptGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Спробуйте згадати переклад',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.mutedText,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hebrew,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transcription,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: tokens.secondaryText,
            ),
          ),
          if (audioButton != null) ...[
            const SizedBox(height: 12),
            audioButton!,
          ],
        ],
      ),
    );
  }
}

class _AnswerRevealCard extends StatelessWidget {
  const _AnswerRevealCard({
    required this.isKnownAnswer,
    required this.translation,
    this.lastCorrect,
  });

  final bool isKnownAnswer;
  final String translation;
  final String? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final background = isKnownAnswer
        ? tokens.successSurface
        : tokens.warningSurface;
    final accent = isKnownAnswer ? tokens.successAccent : tokens.warningAccent;
    final icon = isKnownAnswer
        ? Icons.check_circle_rounded
        : Icons.refresh_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 8),
              Text(
                isKnownAnswer ? 'Зараховано' : 'На повторення',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKnownAnswer
                ? 'Добре. Це слово зараховано як знайоме.'
                : 'Нічого, повернемося до нього ще раз трохи пізніше.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
          if (lastCorrect != null) ...[
            const SizedBox(height: 10),
            Text(
              'Востаннє правильно: $lastCorrect',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwipeHintStrip extends StatelessWidget {
  const _SwipeHintStrip({required this.onRepeatTap, required this.onKnowTap});

  final VoidCallback onRepeatTap;
  final VoidCallback onKnowTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Row(
      children: [
        Expanded(
          child: _SwipeHintCard(
            alignment: CrossAxisAlignment.start,
            icon: Icons.arrow_back_rounded,
            label: 'Ще раз',
            accent: tokens.warningAccent,
            onTap: onRepeatTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SwipeHintCard(
            alignment: CrossAxisAlignment.end,
            icon: Icons.arrow_forward_rounded,
            label: 'Знаю',
            accent: tokens.successAccent,
            onTap: onKnowTap,
          ),
        ),
      ],
    );
  }
}

class _SwipeHintCard extends StatelessWidget {
  const _SwipeHintCard({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final CrossAxisAlignment alignment;
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final isTrailing = alignment == CrossAxisAlignment.end;
    final iconBadge = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: tokens.accentMutedSurface(accent),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.accentStrongBorder(accent)),
      ),
      child: Icon(icon, color: accent, size: 21),
    );
    final labelText = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isTrailing ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.titleSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? tokens.accentBorder(accent)
                : tokens.accentSubtleSurface(accent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: isTrailing
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!isTrailing) ...[iconBadge, const SizedBox(width: 10)],
              labelText,
              if (isTrailing) ...[const SizedBox(width: 10), iconBadge],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckModeSection extends StatelessWidget {
  const _DeckModeSection({required this.selectedMode, required this.onChanged});

  final FlashcardDeckMode selectedMode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Режим',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DeckChoiceChip(
              label: 'Усі',
              isSelected: selectedMode == FlashcardDeckMode.allWords,
              onTap: () => onChanged(FlashcardDeckMode.allWords),
            ),
            _DeckChoiceChip(
              label: 'Контекст',
              isSelected: selectedMode == FlashcardDeckMode.withContexts,
              onTap: () => onChanged(FlashcardDeckMode.withContexts),
            ),
            _DeckChoiceChip(
              label: 'Повторення',
              isSelected: selectedMode == FlashcardDeckMode.needsReview,
              onTap: () => onChanged(FlashcardDeckMode.needsReview),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeckChoiceChip extends StatelessWidget {
  const _DeckChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : tokens.outlineSoft,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardContextPanel extends StatelessWidget {
  const _FlashcardContextPanel({
    required this.context,
    required this.isAnswerRevealed,
  });

  final LearningContext? context;
  final bool isAnswerRevealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    if (this.context == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tokens.subtleSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Для цього слова ще немає прикладу в реченні.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: tokens.secondaryText,
            height: 1.45,
          ),
        ),
      );
    }

    final hebrewText = this.context!.hebrew;
    final hasHebrew = _containsHebrew(hebrewText);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.contextPanelSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Контекст',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.mutedText,
                ),
              ),
              if (this.context!.isAiGenerated) ...[
                const SizedBox(width: 10),
                ContextSourceBadge(context: this.context!),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hebrewText,
            textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
            textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          if (isAnswerRevealed &&
              this.context!.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              this.context!.translation,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _containsHebrew(String text) {
    return text.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );
  }
}

class _EmptyFlashcardsState extends StatelessWidget {
  const _EmptyFlashcardsState({required this.mode, required this.onChanged});

  final FlashcardDeckMode mode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Картки',
          subtitle:
              'Зараз тут порожньо. Оберіть інший режим або поверніться трохи пізніше.',
        ),
        _DeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                _emptyTitle(mode),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _emptyBody(mode),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _emptyTitle(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Слова ще не завантажені.';
      case FlashcardDeckMode.withContexts:
        return 'Карток із прикладами поки немає.';
      case FlashcardDeckMode.needsReview:
        return 'На повторенні поки порожньо.';
    }
  }

  String _emptyBody(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Щойно слова з’являться, тут можна буде почати тренування.';
      case FlashcardDeckMode.withContexts:
        return 'Коли для слів з’являться приклади, цей режим стане доступним.';
      case FlashcardDeckMode.needsReview:
        return 'Позначайте слова як «Ще раз», і вони з’являться тут окремо.';
    }
  }
}

class _CompletedFlashcardsState extends StatelessWidget {
  const _CompletedFlashcardsState({
    required this.mode,
    required this.wordCount,
    required this.correctAnswers,
    required this.repeatAnswers,
    required this.reviewWordCount,
    required this.onRestartDeck,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final int wordCount;
  final int correctAnswers;
  final int repeatAnswers;
  final int reviewWordCount;
  final void Function([FlashcardDeckMode? mode]) onRestartDeck;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Картки',
          subtitle:
              'Цю колоду вже пройдено. Можна почати ще раз або перейти далі.',
        ),
        _DeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        PracticeCompletionCard(
          badgeLabel: 'Готово',
          title: '$wordCount карток пройдено',
          body: _completionBody(mode, reviewWordCount),
          stats: [
            PracticeCompletionStat(
              label: 'Знаю',
              value: correctAnswers,
              icon: Icons.check_rounded,
              accent: tokens.successAccent,
            ),
            PracticeCompletionStat(
              label: 'Повторити',
              value: repeatAnswers,
              icon: Icons.refresh_rounded,
              accent: tokens.warningAccent,
            ),
          ],
          primaryAction: PracticeCompletionAction(
            label: 'Почати ще раз',
            icon: Icons.refresh_rounded,
            onPressed: () => onRestartDeck(),
          ),
          secondaryAction:
              mode != FlashcardDeckMode.needsReview && reviewWordCount > 0
              ? PracticeCompletionAction(
                  label: 'До повторення',
                  icon: Icons.rule_rounded,
                  onPressed: () => onRestartDeck(FlashcardDeckMode.needsReview),
                  style: PracticeCompletionActionStyle.outlined,
                )
              : null,
        ),
      ],
    );
  }

  String _completionBody(FlashcardDeckMode mode, int reviewWordCount) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        if (reviewWordCount > 0) {
          return 'На повторення чекають $reviewWordCount карток.';
        }
        return 'Усі слова з цієї колоди вже переглянуті.';
      case FlashcardDeckMode.withContexts:
        if (reviewWordCount > 0) {
          return 'Після цього проходу $reviewWordCount карток перейшли на повторення.';
        }
        return 'Усі картки з прикладами вже пройдені.';
      case FlashcardDeckMode.needsReview:
        return 'Ви вже все повторили.';
    }
  }
}
