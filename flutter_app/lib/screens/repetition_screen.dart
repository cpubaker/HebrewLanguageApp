import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/learning_audio_player.dart';
import '../services/repetition_queue.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/practice_panel.dart';
import 'widgets/practice_stat_pill.dart';

class RepetitionScreen extends StatefulWidget {
  const RepetitionScreen({
    super.key,
    required this.words,
    required this.audioPlayerFactory,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
  });

  final List<LearningWord> words;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<RepetitionScreen> createState() => _RepetitionScreenState();
}

class _RepetitionScreenState extends State<RepetitionScreen> {
  late RepetitionQueue _queue;
  late final LearningAudioPlayer _audioPlayer = widget.audioPlayerFactory();
  int _currentIndex = 0;
  int _audioRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _rebuildQueue();
    unawaited(_syncCurrentEntryAudio(_currentEntry));
  }

  @override
  void didUpdateWidget(covariant RepetitionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.words, widget.words)) {
      _rebuildQueue();
      unawaited(_syncCurrentEntryAudio(_currentEntry));
    }
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  void _rebuildQueue() {
    _queue = RepetitionQueue.fromWords(widget.words);
    _currentIndex = 0;
  }

  List<RepetitionEntry> get _entries => _queue.entries;

  RepetitionEntry? get _currentEntry {
    if (_currentIndex < 0 || _currentIndex >= _entries.length) {
      return null;
    }

    return _entries[_currentIndex];
  }

  void _showNextCard() {
    if (_entries.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
    unawaited(_syncCurrentEntryAudio(_currentEntry));
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
    });
    unawaited(_syncCurrentEntryAudio(_currentEntry));
  }

  Future<void> _syncCurrentEntryAudio(RepetitionEntry? entry) async {
    final requestToken = ++_audioRequestToken;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    if (!mounted || _audioRequestToken != requestToken) {
      return;
    }

    final audioAssetPath = entry?.word.audioAssetPath;
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
    final theme = Theme.of(context);
    final currentEntry = _currentEntry;

    if (_queue.isEmpty) {
      return Padding(
        padding: tokens.pagePadding.copyWith(bottom: 32),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompactHeader(
              title: 'Повторення',
              subtitle:
                  'Коли з’являться нові слова або останні помилки, вони будуть тут.',
            ),
            SizedBox(height: 16),
            Expanded(child: _EmptyState()),
          ],
        ),
      );
    }

    if (currentEntry == null) {
      return Padding(
        padding: tokens.pagePadding.copyWith(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CompactHeader(
              title: 'Повторення',
              subtitle: 'Сесію завершено. Можна одразу пройти її ще раз.',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _CompletedState(
                queue: _queue,
                onRestart: _restart,
              ),
            ),
          ],
        ),
      );
    }

    final progressValue =
        _entries.isEmpty ? 0.0 : (_currentIndex + 1) / _entries.length;
    final isLastCard = _currentIndex == _entries.length - 1;

    return Padding(
      padding: tokens.pagePadding.copyWith(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompactHeader(
            title: 'Повторення',
            subtitle: 'Одне слово на екран, без таймера і без варіантів.',
            trailing: Text(
              '${_currentIndex + 1}/${_entries.length}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progressValue,
              backgroundColor: tokens.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _RepetitionCard(
              entry: currentEntry,
              audioPlayerFactory: widget.audioPlayerFactory,
              audioPlaybackAwareness: widget.audioPlaybackAwareness,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _showNextCard,
            icon: Icon(
              isLastCard
                  ? Icons.check_circle_outline_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(isLastCard ? 'Завершити' : 'Далі'),
          ),
        ],
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return PracticePanel(
      backgroundColor: tokens.elevatedSurface,
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 36,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(height: 14),
          Text(
            'Список повторення поки порожній.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Спочатку відкрийте нові слова або зробіть кілька спроб у практиці.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.queue,
    required this.onRestart,
  });

  final RepetitionQueue queue;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Готово',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF0F766E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${queue.total} слів переглянуто',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              PracticeStatPill(
                label: 'Після помилки',
                value: queue.lastMistakeCount,
                icon: Icons.error_outline_rounded,
                accent: const Color(0xFFB45309),
              ),
              PracticeStatPill(
                label: 'Щойно у вивченні',
                value: queue.recentStartCount,
                icon: Icons.new_releases_outlined,
                accent: const Color(0xFF1D4ED8),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Почати ще раз'),
          ),
        ],
      ),
    );
  }
}

class _RepetitionCard extends StatelessWidget {
  const _RepetitionCard({
    required this.entry,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final RepetitionEntry entry;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final word = entry.word;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chipMaxWidth = word.hasPlannedAudio
            ? (constraints.maxWidth - 76).clamp(120.0, constraints.maxWidth)
            : constraints.maxWidth;

        return Container(
          padding: const EdgeInsets.all(18),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ReasonChip(
                          kind: entry.kind,
                          maxWidth: chipMaxWidth,
                        ),
                        if (_formatReviewedAt(word.lastReviewedAt)
                            case final label?)
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: label,
                            accent: const Color(0xFF8C6A2A),
                            maxWidth: chipMaxWidth,
                          ),
                      ],
                    ),
                  ),
                  if (word.hasPlannedAudio) ...[
                    const SizedBox(width: 8),
                    _RepetitionAudioButton(
                      word: word,
                      audioPlayerFactory: audioPlayerFactory,
                      audioPlaybackAwareness: audioPlaybackAwareness,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.dark
                        ? <Color>[tokens.elevatedSurface, tokens.subtleSurface]
                        : const <Color>[Color(0xFFF1F6F2), Color(0xFFF7F3E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  word.hebrew,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PracticePanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Переклад',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.translation,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _ContextPanel(
                  contextEntry: word.contexts.isEmpty ? null : word.contexts.first,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _formatReviewedAt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return null;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.kind,
    this.maxWidth,
  });

  final RepetitionKind kind;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final (label, accent, icon) = switch (kind) {
      RepetitionKind.lastMistake => (
        'Остання спроба з помилкою',
        const Color(0xFFB45309),
        Icons.error_outline_rounded,
      ),
      RepetitionKind.recentStart => (
        'Нове слово у вивченні',
        const Color(0xFF1D4ED8),
        Icons.new_releases_outlined,
      ),
    };

    return _MetaChip(
      icon: icon,
      label: label,
      accent: accent,
      maxWidth: maxWidth,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.accent,
    this.maxWidth,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextPanel extends StatelessWidget {
  const _ContextPanel({required this.contextEntry});

  final LearningContext? contextEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    if (contextEntry == null) {
      return PracticePanel(
        backgroundColor: tokens.subtleSurface,
        child: Center(
          child: Text(
            'Контекст для цього слова ще не додано.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    final hebrewText = contextEntry!.hebrew;
    final hasHebrew = hebrewText.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );

    return PracticePanel(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.primary.withValues(alpha: 0.22)
          : const Color(0xFF163832).withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Контекст',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    hebrewText,
                    textDirection:
                        hasHebrew ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  if (contextEntry!.translation.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      contextEntry!.translation,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.secondaryText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepetitionAudioButton extends StatefulWidget {
  const _RepetitionAudioButton({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_RepetitionAudioButton> createState() => _RepetitionAudioButtonState();
}

class _RepetitionAudioButtonState extends State<_RepetitionAudioButton> {
  late final LearningAudioPlayer _audioPlayer = widget.audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  String get _audioAssetPath => widget.word.audioAssetPath ?? '';

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
    final audioAssetPath = widget.word.audioAssetPath;
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
    if (hasAudio) {
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
          awareness: widget.audioPlaybackAwareness,
        );
        await _audioPlayer.playAsset(_audioAssetPath);
      }
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
          _isBusy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _isCheckingAvailability
        ? 'Перевіряємо озвучку'
        : _hasAudio
        ? (_isPlaying ? 'Зупинити озвучку' : 'Увімкнути озвучку')
        : 'Озвучка ще недоступна';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8C6A2A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: _hasAudio && !_isBusy ? _togglePlayback : null,
        icon: _isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8C6A2A),
                ),
              )
            : Icon(
                _isPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                color: _hasAudio
                    ? const Color(0xFF8C6A2A)
                    : const Color(0xFFB8AA93),
              ),
      ),
    );
  }
}
