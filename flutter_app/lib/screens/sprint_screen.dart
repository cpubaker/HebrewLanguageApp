import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

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
    unawaited(_restoreSprintStats());
    _startSprint();
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
          'Час пішов. Обирайте правильний переклад якомога швидше.';
      _lastAnswerCorrect = null;
      _completionMessage = null;
      _lastRunFeedback = null;
    });

    if (firstPrompt == null) {
      _finishSprint('Не вдалося підготувати перше завдання для спринту.');
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
            const SnackBar(
              content: Text('Не вдалося зберегти статистику спринту.'),
            ),
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
          ? 'Правильно: ${result.correctTranslation}'
          : 'Неправильно. Правильна відповідь: ${result.correctTranslation}';
      _lastAnswerCorrect = result.isCorrect;
      _currentPrompt = nextPrompt;
    });
    unawaited(_syncPromptAudio(nextPrompt));

    if (nextPrompt == null) {
      _finishSprint(
        'Усі слова на вивченні пройдено. Спринт завершено достроково, гарний темп.',
      );
    }
  }

  Future<void> _syncPromptAudio(SprintPrompt? prompt) async {
    await _audioController.autoplay(prompt?.word.audioAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    if (!_session.canStart) {
      return ListView(
        padding: tokens.pagePadding.copyWith(bottom: 32),
        children: [
          const PracticeHeader(
            title: 'Спринт',
            subtitle:
                'Хвилинна вправа з двома варіантами перекладу. Потрібно хоча б два слова на вивченні з різними перекладами.',
          ),
          const SizedBox(height: 18),
          _SprintUnavailableCard(wordCount: _session.availableWordCount),
        ],
      );
    }

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Спринт',
          subtitle:
              'За 60 секунд потрібно вибрати якомога більше правильних перекладів. Кожне слово на вивченні трапляється один раз.',
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
                'Спринт завершено. Можна одразу почати нову хвилину.',
            correctCount: _session.correctCount,
            wrongCount: _session.wrongCount,
            attempts: _session.attempts,
            stats: _stats,
            statsLoaded: _statsLoaded,
            runFeedback: _lastRunFeedback,
            onRestart: _startSprint,
          ),
        const SizedBox(height: 16),
        PracticeSessionSummary(
          title: 'Поточна сесія',
          lines: [
            'Слів на вивченні для спринту: ${_session.availableWordCount}',
            'Правильних відповідей: ${_session.correctCount}',
            'Неправильних відповідей: ${_session.wrongCount}',
            ..._sprintHistoryLines(_stats, _statsLoaded),
          ],
        ),
      ],
    );
  }

  List<String> _sprintHistoryLines(SprintStats stats, bool statsLoaded) {
    if (!statsLoaded) {
      return const <String>['Статистика спринту завантажується...'];
    }

    if (!stats.hasResults) {
      return const <String>[
        'Рекорд і середній результат зʼявляться після першого завершеного спринту.',
      ];
    }

    return <String>[
      'Найкращий результат: ${stats.bestCorrect} вірних відповідей',
      'Середній результат: ${_formatSprintScore(stats.averageCorrect)} вірних відповідей',
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
                  label: '$attempts відповідей',
                  background: tokens.warningSurface,
                  foreground: tokens.warningAccent,
                ),
                IconButton(
                  tooltip: 'Почати спочатку',
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
                    'Оберіть правильний переклад',
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
                  'Після відповіді тут одразу з’явиться короткий результат.',
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
                  label: 'Правильно',
                  value: correctCount,
                  icon: Icons.check_rounded,
                  accent: tokens.successAccent,
                ),
                PracticeStatItem(
                  label: 'Помилки',
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
    final body = _completionBody(
      completionMessage: completionMessage,
      stats: stats,
      statsLoaded: statsLoaded,
      runFeedback: runFeedback,
    );

    return PracticeCompletionCard(
      badgeLabel: runFeedback?.badgeLabel ?? 'Час вийшов',
      title: '$correctCount вірних відповідей',
      body: body,
      stats: [
        PracticeCompletionStat(
          label: 'Правильно',
          value: correctCount,
          icon: Icons.check_rounded,
          accent: tokens.successAccent,
        ),
        PracticeCompletionStat(
          label: 'Помилки',
          value: wrongCount,
          icon: Icons.close_rounded,
          accent: tokens.dangerAccent,
        ),
        PracticeCompletionStat(
          label: 'Відповіді',
          value: attempts,
          icon: Icons.bolt_rounded,
          accent: tokens.infoAccent,
        ),
        if (statsLoaded && stats.hasResults)
          PracticeCompletionStat(
            label: 'Рекорд',
            value: stats.bestCorrect,
            icon: Icons.emoji_events_rounded,
            accent: tokens.warningAccent,
          ),
      ],
      primaryAction: PracticeCompletionAction(
        label: 'Почати ще раз',
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
  }) {
    final lines = <String>[
      if (completionMessage.trim().isNotEmpty) completionMessage.trim(),
      ...?runFeedback?.messageLines,
      if (statsLoaded && stats.hasResults)
        'Середній результат: ${_formatSprintScore(stats.averageCorrect)} вірних відповідей.',
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

  String? get badgeLabel {
    return switch (recordStatus) {
      _SprintRecordStatus.first => 'Перший рекорд',
      _SprintRecordStatus.broken => 'Новий рекорд',
      _SprintRecordStatus.tied => 'Рекорд досягнуто',
      _SprintRecordStatus.none => null,
    };
  }

  List<String> get messageLines {
    final recordLine = _recordLine;
    return <String>[
      ?recordLine,
      if (aboveAverageBy >= 0.05)
        'Це на ${_formatSprintScore(aboveAverageBy)} вище вашого середнього.',
    ];
  }

  String? get _recordLine {
    return switch (recordStatus) {
      _SprintRecordStatus.first =>
        'Перший рекорд: $correctCount вірних відповідей.',
      _SprintRecordStatus.broken =>
        'Ви побили рекорд: $correctCount вірних відповідей. Попередній був $previousBest.',
      _SprintRecordStatus.tied =>
        'Ви досягли свого рекорду: $correctCount вірних відповідей.',
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
            'Спринт поки недоступний',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Для цієї вправи потрібно щонайменше два слова на вивченні з різними перекладами. Зараз доступно $wordCount слів.',
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
  final roundedValue = value.roundToDouble();
  if ((value - roundedValue).abs() < 0.05) {
    return roundedValue.toInt().toString();
  }

  return value.toStringAsFixed(1).replaceAll('.', ',');
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
