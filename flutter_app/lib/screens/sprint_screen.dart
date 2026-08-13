import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_controller.dart';
import '../services/learning_audio_player.dart';
import '../services/sprint_session.dart';
import '../services/sprint_stats_store.dart';
import '../theme/app_theme.dart';
import 'widgets/practice_completion_card.dart';
import 'widgets/practice_feedback_card.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_session_summary.dart';
import 'widgets/practice_stats_row.dart';

class SprintScreen extends StatefulWidget {
  const SprintScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
    required this.audioPlayerFactory,
    this.statsStore = const SharedPreferencesSprintStatsStore(),
    this.duration = const Duration(seconds: 60),
    this.rng,
    this.now,
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final SprintStatsStore statsStore;
  final Duration duration;
  final Random? rng;
  final DateTime Function()? now;

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  Timer? _timer;
  late SprintSession _session;
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory: widget.audioPlayerFactory,
  );

  SprintPrompt? _currentPrompt;
  String? _feedbackMessage;
  bool? _lastAnswerCorrect;
  String? _completionMessage;
  SprintStats _stats = const SprintStats.empty();
  bool _statsLoaded = false;
  _SprintRunFeedback? _lastRunFeedback;
  int _remainingSeconds = 0;
  bool _isActive = false;
  int _runToken = 0;

  @override
  void initState() {
    super.initState();
    _session = SprintSession(widget.words, rng: widget.rng, now: widget.now);
    unawaited(_restoreSprintStats());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startSprint();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioController.dispose();
    super.dispose();
  }

  void _startSprint() {
    _timer?.cancel();
    _runToken += 1;
    _session = SprintSession(widget.words, rng: widget.rng, now: widget.now);

    if (!_session.canStart) {
      setState(() {
        _isActive = false;
        _remainingSeconds = widget.duration.inSeconds;
        _currentPrompt = null;
        _feedbackMessage = null;
        _lastAnswerCorrect = null;
        _completionMessage = null;
        _lastRunFeedback = null;
      });
      unawaited(_syncPromptAudio(null));
      return;
    }

    final firstPrompt = _session.nextPrompt();
    setState(() {
      _isActive = firstPrompt != null;
      _remainingSeconds = widget.duration.inSeconds;
      _currentPrompt = firstPrompt;
      _feedbackMessage =
          AppLocalizations.of(context).sprintTimeStarted;
      _lastAnswerCorrect = null;
      _completionMessage = null;
      _lastRunFeedback = null;
    });

    if (firstPrompt == null) {
      _finishSprint(AppLocalizations.of(context).sprintFirstPromptFailure);
      return;
    }

    unawaited(_syncPromptAudio(firstPrompt));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isActive) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        _finishSprint();
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _finishSprint([String message = '']) {
    final shouldRecordResult = _isActive;
    final runToken = _runToken;
    final correctCount = _session.correctCount;
    _timer?.cancel();
    unawaited(_syncPromptAudio(null));
    if (!mounted) {
      return;
    }

    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
      _completionMessage = message;
    });

    if (shouldRecordResult) {
      unawaited(_recordSprintResult(correctCount, runToken));
    }
  }

  Future<void> _restoreSprintStats() async {
    final stats = await widget.statsStore.load();
    if (!mounted || _statsLoaded) {
      return;
    }

    setState(() {
      _stats = stats;
      _statsLoaded = true;
    });
  }

  Future<void> _recordSprintResult(int correctCount, int runToken) async {
    final previousStats = _statsLoaded
        ? _stats
        : await widget.statsStore.load();
    final updatedStats = previousStats.recordScore(correctCount);
    final feedback = _SprintRunFeedback.from(
      previousStats: previousStats,
      averageCorrect: updatedStats.averageCorrect,
      correctCount: correctCount,
    );

    if (mounted) {
      setState(() {
        _stats = updatedStats;
        _statsLoaded = true;
        if (runToken == _runToken && !_isActive) {
          _lastRunFeedback = feedback;
        }
      });
    }

    try {
      await widget.statsStore.save(updatedStats);
    } catch (error) {
      debugPrint('Failed to save sprint stats: $error');
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).sprintStatsSaveFailure)),
          );
      }
    }
  }

  void _answer(String selectedTranslation) {
    if (!_isActive) {
      return;
    }

    final result = _session.submitAnswer(selectedTranslation);
    if (result == null) {
      return;
    }

    widget.onWordProgressChanged(result.word);

    final nextPrompt = _session.nextPrompt();
    setState(() {
      _feedbackMessage = result.isCorrect
          ? AppLocalizations.of(context).sprintAnswerCorrect(result.correctTranslation)
          : AppLocalizations.of(context).sprintAnswerWrong(result.correctTranslation);
      _lastAnswerCorrect = result.isCorrect;
      _currentPrompt = nextPrompt;
    });
    unawaited(_syncPromptAudio(nextPrompt));

    if (nextPrompt == null) {
      _finishSprint(
        AppLocalizations.of(context).sprintEarlyCompletion,
      );
    }
  }

  Future<void> _syncPromptAudio(SprintPrompt? prompt) async {
    await _audioController.autoplay(prompt?.word.audioAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    if (!_session.canStart) {
      return ListView(
        padding: tokens.pagePadding.copyWith(bottom: 32),
        children: [
          PracticeHeader(
            title: localizations.sprintTitle,
            subtitle: localizations.sprintIntroUnavailable,
          ),
          const SizedBox(height: 18),
          _SprintUnavailableCard(wordCount: _session.availableWordCount),
        ],
      );
    }

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        PracticeHeader(
          title: localizations.sprintTitle,
          subtitle: localizations.sprintIntro,
        ),
        const SizedBox(height: 18),
        if (_isActive && _currentPrompt != null)
          _ActiveSprintCard(
            remainingSeconds: _remainingSeconds,
            prompt: _currentPrompt!,
            correctCount: _session.correctCount,
            wrongCount: _session.wrongCount,
            attempts: _session.attempts,
            feedbackMessage: _feedbackMessage,
            lastAnswerCorrect: _lastAnswerCorrect,
            onAnswer: _answer,
            onRestart: _startSprint,
          )
        else
          _SprintCompletedCard(
            completionMessage:
                _completionMessage ??
                localizations.sprintCompleted,
            correctCount: _session.correctCount,
            wrongCount: _session.wrongCount,
            attempts: _session.attempts,
            stats: _stats,
            statsLoaded: _statsLoaded,
            runFeedback: _lastRunFeedback,
            onRestart: _startSprint,
          ),
        if (!_isActive) ...[
          const SizedBox(height: 16),
          PracticeSessionSummary(
            title: localizations.sprintSession,
            lines: [
              localizations.sprintAvailableWords(_session.availableWordCount),
              localizations.sprintCorrectAnswers(_session.correctCount),
              localizations.sprintWrongAnswers(_session.wrongCount),
              ..._sprintHistoryLines(_stats, _statsLoaded, localizations),
            ],
          ),
        ],
      ],
    );
  }

  List<String> _sprintHistoryLines(SprintStats stats, bool statsLoaded, AppLocalizations localizations) {
    if (!statsLoaded) {
      return <String>[localizations.sprintLoadingStats];
    }

    if (!stats.hasResults) {
      return <String>[localizations.sprintNoStats];
    }

    return <String>[
      localizations.sprintBest(stats.bestCorrect),
      localizations.sprintAverage(_formatSprintScore(stats.averageCorrect)),
    ];
  }
}

class _ActiveSprintCard extends StatelessWidget {
  const _ActiveSprintCard({
    required this.remainingSeconds,
    required this.prompt,
    required this.correctCount,
    required this.wrongCount,
    required this.attempts,
    required this.feedbackMessage,
    required this.lastAnswerCorrect,
    required this.onAnswer,
    required this.onRestart,
  });

  static const double _swipeVelocityThreshold = 325;

  final int remainingSeconds;
  final SprintPrompt prompt;
  final int correctCount;
  final int wrongCount;
  final int attempts;
  final String? feedbackMessage;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onAnswer;
  final VoidCallback onRestart;

  void _handleSwipe(DragEndDetails details) {
    if (prompt.options.length < 2) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) {
      return;
    }

    onAnswer(velocity < 0 ? prompt.options.first : prompt.options[1]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      key: const ValueKey('sprint-active-card'),
      onHorizontalDragEnd: _handleSwipe,
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SprintMetaChip(
                  icon: Icons.timer_rounded,
                  label: _formatDuration(remainingSeconds),
                  background: theme.colorScheme.primary,
                  foreground: theme.colorScheme.onPrimary,
                ),
                _SprintMetaChip(
                  icon: Icons.bolt_rounded,
                  label: localizations.sprintAttempts(attempts),
                  background: tokens.warningSurface,
                  foreground: tokens.warningAccent,
                ),
                IconButton(
                  tooltip: localizations.sprintRestart,
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tokens.practiceChoiceGradientStart,
                    tokens.practiceChoiceGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.sprintChoose,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: tokens.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    prompt.word.hebrew,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (prompt.word.transcription.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      prompt.word.transcription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < prompt.options.length; index += 1) ...[
              FilledButton(
                key: ValueKey('sprint-option-$index'),
                onPressed: () => onAnswer(prompt.options[index]),
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.subtleSurface,
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(prompt.options[index], textAlign: TextAlign.center),
              ),
              if (index != prompt.options.length - 1)
                const SizedBox(height: 12),
            ],
            const SizedBox(height: 18),
            PracticeFeedbackCard(
              message:
                  feedbackMessage ??
                  localizations.sprintAwaitingAnswer,
              tone: switch (lastAnswerCorrect) {
                true => PracticeFeedbackTone.success,
                false => PracticeFeedbackTone.error,
                null => PracticeFeedbackTone.neutral,
              },
              compact: true,
            ),
            const SizedBox(height: 18),
            PracticeStatsRow(
              stats: [
                PracticeStatItem(
                  label: localizations.sprintCorrect,
                  value: correctCount,
                  icon: Icons.check_rounded,
                  accent: tokens.successAccent,
                ),
                PracticeStatItem(
                  label: localizations.sprintMistakes,
                  value: wrongCount,
                  icon: Icons.close_rounded,
                  accent: tokens.dangerAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _SprintCompletedCard extends StatelessWidget {
  const _SprintCompletedCard({
    required this.completionMessage,
    required this.correctCount,
    required this.wrongCount,
    required this.attempts,
    required this.stats,
    required this.statsLoaded,
    required this.runFeedback,
    required this.onRestart,
  });

  final String completionMessage;
  final int correctCount;
  final int wrongCount;
  final int attempts;
  final SprintStats stats;
  final bool statsLoaded;
  final _SprintRunFeedback? runFeedback;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    final body = _completionBody(
      completionMessage: completionMessage,
      stats: stats,
      statsLoaded: statsLoaded,
      runFeedback: runFeedback,
      localizations: localizations,
    );

    return PracticeCompletionCard(
      badgeLabel: runFeedback?.badgeLabel(localizations) ?? localizations.sprintTimeUp,
      title: localizations.sprintCorrectCount(correctCount),
      body: body,
      stats: [
        PracticeCompletionStat(
          label: localizations.sprintCorrect,
          value: correctCount,
          icon: Icons.check_rounded,
          accent: tokens.successAccent,
        ),
        PracticeCompletionStat(
          label: localizations.sprintMistakes,
          value: wrongCount,
          icon: Icons.close_rounded,
          accent: tokens.dangerAccent,
        ),
        PracticeCompletionStat(
          label: localizations.sprintTotal,
          value: attempts,
          icon: Icons.bolt_rounded,
          accent: tokens.infoAccent,
        ),
        if (statsLoaded && stats.hasResults)
          PracticeCompletionStat(
            label: localizations.sprintRecord,
            value: stats.bestCorrect,
            icon: Icons.emoji_events_rounded,
            accent: tokens.warningAccent,
          ),
      ],
      primaryAction: PracticeCompletionAction(
        label: localizations.sprintStartAgain,
        icon: Icons.replay_rounded,
        onPressed: onRestart,
      ),
    );
  }

  String? _completionBody({
    required String completionMessage,
    required SprintStats stats,
    required bool statsLoaded,
    required _SprintRunFeedback? runFeedback,
    required AppLocalizations localizations,
  }) {
    final lines = <String>[
      if (completionMessage.trim().isNotEmpty) completionMessage.trim(),
      ...?runFeedback?.messageLines(localizations),
      if (statsLoaded && stats.hasResults)
        '${localizations.sprintAverage(_formatSprintScore(stats.averageCorrect))}.',
    ];

    if (lines.isEmpty) {
      return null;
    }

    return lines.join('\n');
  }
}

enum _SprintRecordStatus { none, first, tied, broken }

class _SprintRunFeedback {
  const _SprintRunFeedback({
    required this.recordStatus,
    required this.correctCount,
    required this.previousBest,
    required this.aboveAverageBy,
  });

  factory _SprintRunFeedback.from({
    required SprintStats previousStats,
    required double averageCorrect,
    required int correctCount,
  }) {
    final hasHistory = previousStats.hasResults;
    final recordStatus = !hasHistory && correctCount > 0
        ? _SprintRecordStatus.first
        : hasHistory && correctCount > previousStats.bestCorrect
        ? _SprintRecordStatus.broken
        : hasHistory &&
              correctCount > 0 &&
              correctCount == previousStats.bestCorrect
        ? _SprintRecordStatus.tied
        : _SprintRecordStatus.none;

    final aboveAverageBy = correctCount - averageCorrect;

    return _SprintRunFeedback(
      recordStatus: recordStatus,
      correctCount: correctCount,
      previousBest: previousStats.bestCorrect,
      aboveAverageBy: aboveAverageBy,
    );
  }

  final _SprintRecordStatus recordStatus;
  final int correctCount;
  final int previousBest;
  final double aboveAverageBy;

  String? badgeLabel(AppLocalizations localizations) {
    return switch (recordStatus) {
      _SprintRecordStatus.first => localizations.sprintFirstRecord,
      _SprintRecordStatus.broken => localizations.sprintNewRecord,
      _SprintRecordStatus.tied => localizations.sprintRecordMatched,
      _SprintRecordStatus.none => null,
    };
  }

  List<String> messageLines(AppLocalizations localizations) {
    final recordLine = _recordLine(localizations);
    return <String>[
      ?recordLine,
      if (aboveAverageBy >= 0.5)
        localizations.sprintAboveAverage(_formatSprintScore(aboveAverageBy)),
    ];
  }

  String? _recordLine(AppLocalizations localizations) {
    return switch (recordStatus) {
      _SprintRecordStatus.first =>
        localizations.sprintFirstRecordBody(correctCount),
      _SprintRecordStatus.broken =>
        localizations.sprintNewRecordBody(correctCount, previousBest),
      _SprintRecordStatus.tied =>
        localizations.sprintRecordMatchedBody(correctCount),
      _SprintRecordStatus.none => null,
    };
  }
}

class _SprintUnavailableCard extends StatelessWidget {
  const _SprintUnavailableCard({required this.wordCount});

  final int wordCount;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).sprintUnavailableTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).sprintUnavailableBody(wordCount),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatSprintScore(double value) {
  return value.round().toString();
}

class _SprintMetaChip extends StatelessWidget {
  const _SprintMetaChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
