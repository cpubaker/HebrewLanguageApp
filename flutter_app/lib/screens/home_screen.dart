import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/learning_bundle.dart';
import '../services/audio_playback_awareness.dart';
import '../services/bool_setting_store.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_controller.dart';
import '../services/learning_audio_player.dart';
import '../services/progress_snapshot.dart';
import '../services/word_of_day_service.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/app_section_card.dart';

part 'widgets/home/home_action_sections.dart';
part 'widgets/home/home_dashboard_actions.dart';
part 'widgets/home/home_word_of_day_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
    this.audioPlayerFactory = createAssetLearningAudioPlayer,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
    this.wordOfDayDateProvider,
    this.firstActionCompletedStore,
    this.greetingClock,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;
  final DateTime Function()? wordOfDayDateProvider;

  /// Persists whether the user has tapped through the welcome action at least
  /// once. When `null`, the welcome state is skipped — useful for widget tests
  /// that don't care about the first-run experience.
  final BoolSettingStore? firstActionCompletedStore;

  /// Used to derive the time-of-day greeting. Defaults to [DateTime.now].
  final DateTime Function()? greetingClock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Defaults to `true` so we never flash the welcome card while preferences
  // load. The welcome state only appears once we've confirmed it was never
  // completed.
  bool _firstActionCompleted = true;

  @override
  void initState() {
    super.initState();
    final store = widget.firstActionCompletedStore;
    if (store != null) {
      _firstActionCompleted = false;
      unawaited(_loadFirstActionFlag(store));
    }
  }

  Future<void> _loadFirstActionFlag(BoolSettingStore store) async {
    final completed = await store.load();
    if (!mounted) return;
    setState(() {
      _firstActionCompleted = completed;
    });
  }

  void _handleAction(_DashboardAction action) {
    if (action.kind == _DashboardActionKind.welcome &&
        !_firstActionCompleted) {
      _firstActionCompleted = true;
      final store = widget.firstActionCompletedStore;
      if (store != null) {
        unawaited(store.save(true));
      }
    }
    action.onTap();
  }

  String _greetingFor(AppLocalizations localizations, DateTime now) {
    final hour = now.hour;
    if (hour < 5) return localizations.homeGreetingNight;
    if (hour < 12) return localizations.homeGreetingMorning;
    if (hour < 18) return localizations.homeGreetingDay;
    return localizations.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final progress = StudyProgressSnapshot.fromWords(widget.bundle.words);
    final streak = StudyStreakSnapshot.fromWords(widget.bundle.words);
    final flashcards = FlashcardFocusSnapshot.fromWords(widget.bundle.words);
    final localizations = AppLocalizations.of(context);
    final action = _buildContinueAction(
      localizations: localizations,
      tokens: tokens,
      isFirstRun: !_firstActionCompleted,
      bundle: widget.bundle,
      progress: progress,
      flashcards: flashcards,
      onOpenWords: widget.onOpenWords,
      onOpenFlashcards: widget.onOpenFlashcards,
      onOpenReading: widget.onOpenReading,
    );
    final wordOfDay = const WordOfDayService().select(
      words: widget.bundle.words,
      date: (widget.wordOfDayDateProvider ?? DateTime.now)(),
    );
    final greeting = _greetingFor(
      localizations,
      (widget.greetingClock ?? DateTime.now)(),
    );

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        _GreetingHeaderRow(greeting: greeting, streak: streak),
        const SizedBox(height: 16),
        if (wordOfDay != null)
          _WordOfDayHeroPanel(
            entry: wordOfDay,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: widget.audioPlaybackAwareness,
          )
        else
          const _EmptyWordOfDayHeroPanel(),
        const SizedBox(height: 20),
        _TodayActionCard(
          action: _DashboardAction(
            kind: action.kind,
            title: action.title,
            subtitle: action.subtitle,
            buttonLabel: action.buttonLabel,
            icon: action.icon,
            accent: action.accent,
            onTap: () => _handleAction(action),
          ),
        ),
      ],
    );
  }
}
