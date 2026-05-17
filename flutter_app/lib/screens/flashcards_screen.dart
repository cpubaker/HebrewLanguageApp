import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_controller.dart';
import '../services/learning_audio_player.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/flashcards/flashcard_answer_reveal.dart';
import 'widgets/flashcards/flashcard_context_panel.dart';
import 'widgets/flashcards/flashcard_prompt_panel.dart';
import 'widgets/flashcards/flashcard_session_details_section.dart';
import 'widgets/flashcards/flashcard_states.dart';
import 'widgets/practice_audio_button.dart';
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
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory:
        widget.audioPlayerFactory ?? createAssetLearningAudioPlayer,
  )..addListener(_handleAudioStateChanged);

  FlashcardCard? _currentCard;
  FlashcardAnswerResult? _currentAnswer;
  bool _showSessionDetails = false;

  @override
  void initState() {
    super.initState();
    _session = FlashcardSession(widget.words, deckMode: widget.initialDeckMode);
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
    _audioController
      ..removeListener(_handleAudioStateChanged)
      ..dispose();
    super.dispose();
  }

  void _moveToNextCard() {
    final nextCard = _session.nextCard();
    setState(() {
      _currentCard = nextCard;
      _currentAnswer = null;
      _showSessionDetails = false;
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
    });
    unawaited(_syncWordAudio(nextCard?.word));
  }

  Future<void> _syncWordAudio(LearningWord? word) async {
    await _audioController.autoplay(word?.audioAssetPath);
  }

  Future<void> _replayCurrentWordAudio() async {
    final word = (_currentAnswer?.word ?? _currentCard?.word);
    final audioAssetPath = word?.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      return;
    }
    if (!_audioController.hasAudio) {
      return;
    }

    try {
      await _audioController.toggle(
        audioAssetPath,
        beforePlay: () => showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: widget.audioPlaybackAwareness,
        ),
        recheckBeforePlay: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося відтворити озвучку слова.')),
      );
    }
  }

  void _handleAudioStateChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final theme = Theme.of(context);
    final currentCard = _currentCard;
    if (currentCard == null) {
      if (_session.wordCount > 0 && _session.answeredCount > 0) {
        return FlashcardCompletedState(
          mode: _session.deckMode,
          wordCount: _session.wordCount,
          correctAnswers: _session.correctAnswers,
          repeatAnswers: _session.repeatAnswers,
          reviewWordCount: _session.reviewWordCount,
          onRestartDeck: _restartDeck,
          onChanged: _changeDeckMode,
        );
      }

      return FlashcardEmptyState(
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
                FlashcardPromptPanel(
                  hebrew: word.hebrew,
                  transcription: word.transcription,
                  audioButton: _audioController.hasAudio
                      ? PracticeAudioButton(
                          key: const ValueKey('flashcards_audio_button'),
                          isBusy: _audioController.isBusy,
                          isPlaying: _audioController.isPlaying,
                          onPressed: _audioController.isBusy
                              ? null
                              : _replayCurrentWordAudio,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                FlashcardContextPanel(
                  context: currentContext,
                  isAnswerRevealed: hasAnswered,
                ),
                const SizedBox(height: 18),
                if (hasAnswered)
                  FlashcardAnswerRevealCard(
                    isKnownAnswer: isKnownAnswer,
                    translation: word.translation,
                  )
                else
                  FlashcardSwipeHintStrip(
                    onRepeatTap: () => _answerCard(false),
                    onKnowTap: () => _answerCard(true),
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
                const SizedBox(height: 14),
                FlashcardSessionDetailsSection(
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
