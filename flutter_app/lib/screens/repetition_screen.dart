import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/learning_audio_controller.dart';
import '../services/learning_audio_player.dart';
import '../services/repetition_queue.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/context_source_badge.dart';
import 'widgets/practice_completion_card.dart';
import 'widgets/practice_panel.dart';

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
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory: widget.audioPlayerFactory,
  );
  int _currentIndex = 0;

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
    _audioController.dispose();
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
    await _audioController.autoplay(entry?.word.audioAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentEntry = _currentEntry;

    if (_queue.isEmpty) {
      return Padding(
        padding: tokens.pagePadding.copyWith(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompactHeader(
              title: localizations.repetitionTitle,
              subtitle: localizations.repetitionEmptySubtitle,
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
            _CompactHeader(
              title: localizations.repetitionTitle,
              subtitle: localizations.repetitionCompletedSubtitle,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _CompletedState(queue: _queue, onRestart: _restart),
            ),
          ],
        ),
      );
    }

    final progressValue = _entries.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _entries.length;
    final isLastCard = _currentIndex == _entries.length - 1;

    return Padding(
      padding: tokens.pagePadding.copyWith(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompactHeader(
            title: localizations.repetitionTitle,
            subtitle: localizations.repetitionActiveSubtitle,
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
              valueColor: AlwaysStoppedAnimation<Color>(tokens.successAccent),
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
            label: Text(
              isLastCard
                  ? localizations.repetitionFinish
                  : localizations.repetitionNext,
            ),
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
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return PracticePanel(
      backgroundColor: tokens.elevatedSurface,
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 36,
            color: tokens.successAccent,
          ),
          const SizedBox(height: 14),
          Text(
            localizations.repetitionEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.repetitionEmptyBody,
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
  const _CompletedState({required this.queue, required this.onRestart});

  final RepetitionQueue queue;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return PracticeCompletionCard(
      badgeLabel: localizations.repetitionDone,
      title: localizations.repetitionCompletedTitle(queue.total),
      padding: const EdgeInsets.all(24),
      stats: [
        PracticeCompletionStat(
          label: localizations.repetitionAfterMistake,
          value: queue.lastMistakeCount,
          icon: Icons.error_outline_rounded,
          accent: tokens.warningAccent,
        ),
        PracticeCompletionStat(
          label: localizations.repetitionReinforcement,
          value: queue.recentStartCount,
          icon: Icons.new_releases_outlined,
          accent: tokens.infoAccent,
        ),
      ],
      primaryAction: PracticeCompletionAction(
        label: localizations.repetitionRestart,
        icon: Icons.refresh_rounded,
        onPressed: onRestart,
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
        final chipMaxWidth = constraints.maxWidth;
        final reviewedAtLabel = _formatReviewedAt(word.lastReviewedAt);

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      word.hebrew,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
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
              ),
              const SizedBox(height: 12),
              PracticePanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).repetitionTranslation,
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
                  contextEntry: word.contexts.isEmpty
                      ? null
                      : word.contexts.first,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReasonChip(kind: entry.kind, maxWidth: chipMaxWidth),
                  if (reviewedAtLabel != null)
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: reviewedAtLabel,
                      accent: tokens.vocabularyAccent,
                      maxWidth: chipMaxWidth,
                    ),
                ],
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
  const _ReasonChip({required this.kind, this.maxWidth});

  final RepetitionKind kind;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    final (label, accent, icon) = switch (kind) {
      RepetitionKind.lastMistake => (
        localizations.repetitionLastMistake,
        tokens.warningAccent,
        Icons.error_outline_rounded,
      ),
      RepetitionKind.recentStart => (
        localizations.repetitionReinforcementWord,
        tokens.infoAccent,
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
    final tokens = Theme.of(context).appTokens;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tokens.accentMutedSurface(accent),
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
    final localizations = AppLocalizations.of(context);

    if (contextEntry == null) {
      return PracticePanel(
        backgroundColor: tokens.subtleSurface,
        child: Center(
          child: Text(
            localizations.repetitionContextEmpty,
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
      backgroundColor: tokens.contextPanelSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                localizations.repetitionContextTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.secondaryText,
                ),
              ),
              if (contextEntry!.isAiGenerated) ...[
                const SizedBox(width: 10),
                ContextSourceBadge(context: contextEntry!),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    hebrewText,
                    textDirection: hasHebrew
                        ? TextDirection.rtl
                        : TextDirection.ltr,
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
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory: widget.audioPlayerFactory,
  )..addListener(_handleAudioStateChanged);

  String get _audioAssetPath => widget.word.audioAssetPath ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_checkAudioAvailability());
  }

  Future<void> _checkAudioAvailability() async {
    await _audioController.checkAvailability(
      widget.word.audioAssetPath,
      prepare: true,
    );
  }

  Future<void> _togglePlayback() async {
    try {
      await _audioController.toggle(
        _audioAssetPath,
        beforePlay: () => showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: widget.audioPlaybackAwareness,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wordOfDayAudioFailure),
        ),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    final tooltip = _audioController.isCheckingAvailability
        ? localizations.wordOfDayAudioChecking
        : _audioController.hasAudio
        ? (_audioController.isPlaying
              ? localizations.wordOfDayAudioStop
              : localizations.wordOfDayAudioPlay)
        : localizations.wordOfDayAudioUnavailable;

    return Container(
      decoration: BoxDecoration(
        color: tokens.accentSurface(tokens.vocabularyAccent),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: _audioController.canToggle ? _togglePlayback : null,
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
                    : tokens.disabledAccent,
              ),
      ),
    );
  }
}
