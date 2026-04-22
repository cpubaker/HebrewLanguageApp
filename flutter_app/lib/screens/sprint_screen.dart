import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_player.dart';
import '../services/sprint_session.dart';
import '../theme/app_theme.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_session_summary.dart';
import 'widgets/practice_stat_pill.dart';

class SprintScreen extends StatefulWidget {
  const SprintScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
    required this.audioPlayerFactory,
    this.duration = const Duration(seconds: 60),
    this.rng,
    this.now,
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final Duration duration;
  final Random? rng;
  final DateTime Function()? now;

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  Timer? _timer;
  late SprintSession _session;
  late final LearningAudioPlayer _audioPlayer = widget.audioPlayerFactory();

  SprintPrompt? _currentPrompt;
  String? _feedbackMessage;
  bool? _lastAnswerCorrect;
  String? _completionMessage;
  int _remainingSeconds = 0;
  bool _isActive = false;
  int _audioRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _startSprint();
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  void _startSprint() {
    _timer?.cancel();
    _session = SprintSession(widget.words, rng: widget.rng, now: widget.now);

    if (!_session.canStart) {
      setState(() {
        _isActive = false;
        _remainingSeconds = widget.duration.inSeconds;
        _currentPrompt = null;
        _feedbackMessage = null;
        _lastAnswerCorrect = null;
        _completionMessage = null;
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
    });

    if (firstPrompt == null) {
      _finishSprint('Не вдалося зібрати перше питання для спринту.');
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

  void _finishSprint([
    String message =
        'Хвилина завершилася. Подивіться на результат і, якщо хочете, спробуйте ще раз.',
  ]) {
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
      _finishSprint('Не вдалося зібрати наступне питання для спринту.');
    }
  }

  Future<void> _syncPromptAudio(SprintPrompt? prompt) async {
    final requestToken = ++_audioRequestToken;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    if (!mounted || _audioRequestToken != requestToken) {
      return;
    }

    final audioAssetPath = prompt?.word.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      return;
    }

    final hasAudio = await _audioPlayer.assetExists(audioAssetPath);
    if (!mounted || _audioRequestToken != requestToken || !hasAudio) {
      return;
    }

    try {
      await _audioPlayer.playAsset(audioAssetPath);
    } catch (_) {}
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
                'Хвилинна вправа з двома варіантами перекладу. Потрібно хоча б два слова з різними перекладами.',
          ),
          const SizedBox(height: 18),
          _SprintUnavailableCard(wordCount: widget.words.length),
        ],
      );
    }

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Спринт',
          subtitle:
              'За 60 секунд потрібно вибрати якомога більше правильних перекладів. Для кожного слова є лише два варіанти: правильний і хибний.',
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
            onRestart: _startSprint,
          ),
        const SizedBox(height: 16),
        PracticeSessionSummary(
          title: 'Поточна сесія',
          lines: [
            'Доступно слів для спринту: ${widget.words.where((word) => word.translation.trim().isNotEmpty).length}',
            'Правильних відповідей: ${_session.correctCount}',
            'Неправильних відповідей: ${_session.wrongCount}',
          ],
        ),
      ],
    );
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

  final int remainingSeconds;
  final SprintPrompt prompt;
  final int correctCount;
  final int wrongCount;
  final int attempts;
  final String? feedbackMessage;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onAnswer;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
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
                background: theme.brightness == Brightness.dark
                    ? const Color(0xFF4B3A22)
                    : const Color(0xFFF3E8D2),
                foreground: const Color(0xFF8C6A2A),
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
                colors: theme.brightness == Brightness.dark
                    ? <Color>[tokens.subtleSurface, tokens.elevatedSurface]
                    : const <Color>[Color(0xFFF6EFE1), Color(0xFFEAF4EF)],
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
            if (index != prompt.options.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 18),
          _SprintFeedbackCard(
            message:
                feedbackMessage ??
                'Після відповіді тут одразу з’явиться короткий результат.',
            isSuccess: lastAnswerCorrect,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PracticeStatPill(
                  label: 'Правильно',
                  value: correctCount,
                  icon: Icons.check_rounded,
                  accent: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PracticeStatPill(
                  label: 'Помилки',
                  value: wrongCount,
                  icon: Icons.close_rounded,
                  accent: const Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
        ],
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
    required this.onRestart,
  });

  final String completionMessage;
  final int correctCount;
  final int wrongCount;
  final int attempts;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.all(22),
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Час вийшов',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF0F766E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$attempts відповідей за хвилину',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            completionMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              PracticeStatPill(
                label: 'Правильно',
                value: correctCount,
                icon: Icons.check_rounded,
                accent: const Color(0xFF0F766E),
              ),
              PracticeStatPill(
                label: 'Помилки',
                value: wrongCount,
                icon: Icons.close_rounded,
                accent: const Color(0xFFB91C1C),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Почати ще раз'),
          ),
        ],
      ),
    );
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
            'Для цієї вправи потрібно щонайменше два слова з різними перекладами. Зараз у наборі $wordCount слів.',
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

class _SprintFeedbackCard extends StatelessWidget {
  const _SprintFeedbackCard({required this.message, required this.isSuccess});

  final String message;
  final bool? isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final background = switch (isSuccess) {
      true => theme.brightness == Brightness.dark
          ? const Color(0xFF17352F)
          : const Color(0xFFEAF6F2),
      false => theme.brightness == Brightness.dark
          ? const Color(0xFF3A2323)
          : const Color(0xFFFCECE8),
      null => tokens.subtleSurface,
    };
    final accent = switch (isSuccess) {
      true => const Color(0xFF0F766E),
      false => const Color(0xFFB91C1C),
      null => tokens.secondaryText,
    };
    final icon = switch (isSuccess) {
      true => Icons.check_circle_rounded,
      false => Icons.cancel_rounded,
      null => Icons.info_outline_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
