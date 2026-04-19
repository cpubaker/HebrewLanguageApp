import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/learning_audio_player.dart';
import '../services/repetition_queue.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_panel.dart';
import 'widgets/practice_stat_pill.dart';

class RepetitionScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final queue = RepetitionQueue.fromWords(words);
    final lastMistakes = queue.entriesFor(RepetitionKind.lastMistake);
    final recentStarts = queue.entriesFor(RepetitionKind.recentStart);

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Повторення',
          subtitle:
              'Спокійний режим без таймера і без варіантів відповіді. Тут зібрані слова, які щойно увійшли у вивчення, та слова з останньою помилкою.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PracticeStatPill(
              label: 'Усього',
              value: queue.total,
              icon: Icons.layers_rounded,
              accent: const Color(0xFF163832),
            ),
            PracticeStatPill(
              label: 'Остання помилка',
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
        if (queue.isEmpty)
          const PracticePanel(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 32,
                  color: Color(0xFF0F766E),
                ),
                SizedBox(height: 12),
                Text(
                  'Зараз список повторення порожній.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Слова з’являться тут, коли ви почнете новий набір або десь помилитеся востаннє.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          if (lastMistakes.isNotEmpty) ...[
            const _SectionHeader(
              title: 'Після помилки',
              subtitle:
                  'Слова, по яких остання спроба завершилась помилкою.',
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < lastMistakes.length; index += 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == lastMistakes.length - 1 ? 0 : 12,
                ),
                child: _RepetitionCard(
                  entry: lastMistakes[index],
                  audioPlayerFactory: audioPlayerFactory,
                  audioPlaybackAwareness: audioPlaybackAwareness,
                ),
              ),
            const SizedBox(height: 18),
          ],
          if (recentStarts.isNotEmpty) ...[
            const _SectionHeader(
              title: 'Щойно у вивченні',
              subtitle:
                  'Слова, з якими ви вже почали працювати, але вони ще нові у вашому циклі.',
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < recentStarts.length; index += 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == recentStarts.length - 1 ? 0 : 12,
                ),
                child: _RepetitionCard(
                  entry: recentStarts[index],
                  audioPlayerFactory: audioPlayerFactory,
                  audioPlaybackAwareness: audioPlaybackAwareness,
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C665D)),
        ),
      ],
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
    final word = entry.word;
    final sectionAccent = switch (entry.kind) {
      RepetitionKind.lastMistake => const Color(0xFFB45309),
      RepetitionKind.recentStart => const Color(0xFF1D4ED8),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
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
                    _ReasonChip(kind: entry.kind),
                    if (_formatReviewedAt(word.lastReviewedAt) case final label?)
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: label,
                        accent: sectionAccent,
                      ),
                  ],
                ),
              ),
              if (word.hasPlannedAudio)
                _RepetitionAudioButton(
                  word: word,
                  audioPlayerFactory: audioPlayerFactory,
                  audioPlaybackAwareness: audioPlaybackAwareness,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF1F6F2), Color(0xFFF7F3E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  word.hebrew,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF163832),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.transcription,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6C665D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PracticePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Переклад',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6C665D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  word.translation,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF163832),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ContextPanel(contextEntry: word.contexts.isEmpty ? null : word.contexts.first),
        ],
      ),
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
  const _ReasonChip({required this.kind});

  final RepetitionKind kind;

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
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextPanel extends StatelessWidget {
  const _ContextPanel({required this.contextEntry});

  final LearningContext? contextEntry;

  @override
  Widget build(BuildContext context) {
    if (contextEntry == null) {
      return PracticePanel(
        child: Text(
          'Контекст для цього слова ще не додано.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6C665D),
            height: 1.45,
          ),
        ),
      );
    }

    final hebrewText = contextEntry!.hebrew;
    final hasHebrew = hebrewText.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );

    return PracticePanel(
      backgroundColor: const Color(0xFF163832).withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Контекст',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C665D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hebrewText,
            textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
            textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF163832),
              height: 1.4,
            ),
          ),
          if (contextEntry!.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              contextEntry!.translation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6C665D),
                height: 1.45,
              ),
            ),
          ],
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
