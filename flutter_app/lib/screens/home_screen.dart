import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_player.dart';
import '../services/lesson_document_loader.dart';
import '../services/progress_snapshot.dart';
import '../services/word_of_day_service.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'reading_lesson_catalog.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_metric_tile.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';

part 'widgets/home/home_action_sections.dart';
part 'widgets/home/home_dashboard_actions.dart';
part 'widgets/home/home_inventory_overview_card.dart';
part 'widgets/home/home_preview_sections.dart';
part 'widgets/home/home_progress_cards.dart';
part 'widgets/home/home_word_of_day_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.bundle,
    required this.documentLoader,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
    required this.onOpenReadingLesson,
    this.audioPlayerFactory = createAssetLearningAudioPlayer,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
    this.wordOfDayDateProvider,
  });

  final LearningBundle bundle;
  final LessonDocumentLoader documentLoader;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;
  final ValueChanged<LessonEntry> onOpenReadingLesson;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;
  final DateTime Function()? wordOfDayDateProvider;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final progress = StudyProgressSnapshot.fromWords(bundle.words);
    final streak = StudyStreakSnapshot.fromWords(bundle.words);
    final flashcards = FlashcardFocusSnapshot.fromWords(bundle.words);
    final continueAction = _buildContinueAction(
      tokens: tokens,
      bundle: bundle,
      progress: progress,
      flashcards: flashcards,
      onOpenWords: onOpenWords,
      onOpenFlashcards: onOpenFlashcards,
      onOpenReading: onOpenReading,
    );
    final recommendedActions = _buildRecommendedActions(
      tokens: tokens,
      bundle: bundle,
      progress: progress,
      flashcards: flashcards,
      onOpenFlashcards: onOpenFlashcards,
      onOpenWriting: onOpenWriting,
      onOpenGuide: onOpenGuide,
    );
    final wordOfDay = const WordOfDayService().select(
      words: bundle.words,
      date: (wordOfDayDateProvider ?? DateTime.now)(),
    );

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        if (wordOfDay != null)
          _WordOfDayHeroPanel(
            entry: wordOfDay,
            audioPlayerFactory: audioPlayerFactory,
            audioPlaybackAwareness: audioPlaybackAwareness,
          )
        else
          const _EmptyWordOfDayHeroPanel(),
        const SizedBox(height: 16),
        _StudyStreakCard(streak: streak),
        const SizedBox(height: 20),
        _DashboardPrimaryActionCard(action: continueAction),
        const SizedBox(height: 16),
        _DashboardRecommendationsCard(actions: recommendedActions),
        const SizedBox(height: 16),
        _QuickActionStrip(
          onOpenWords: onOpenWords,
          onOpenFlashcards: onOpenFlashcards,
          onOpenWriting: onOpenWriting,
          onOpenSprint: onOpenSprint,
          onOpenGuide: onOpenGuide,
          onOpenVerbs: onOpenVerbs,
          onOpenReading: onOpenReading,
        ),
        const SizedBox(height: 16),
        _StudyProgressCard(progress: progress),
        const SizedBox(height: 16),
        _FlashcardFocusCard(
          snapshot: flashcards,
          onOpenAll: () => onOpenFlashcards(FlashcardDeckMode.allWords),
          onOpenContext: flashcards.withContexts > 0
              ? () => onOpenFlashcards(FlashcardDeckMode.withContexts)
              : null,
          onOpenReview: flashcards.needsReview > 0
              ? () => onOpenFlashcards(FlashcardDeckMode.needsReview)
              : null,
        ),
        const SizedBox(height: 16),
        _VocabularyPreviewCard(words: bundle.words),
        const SizedBox(height: 16),
        _InventoryOverviewCard(
          bundle: bundle,
          onOpenWords: onOpenWords,
          onOpenFlashcards: () => onOpenFlashcards(FlashcardDeckMode.allWords),
          onOpenWriting: onOpenWriting,
          onOpenGuide: onOpenGuide,
          onOpenVerbs: onOpenVerbs,
          onOpenReading: onOpenReading,
        ),
        const SizedBox(height: 16),
        _ReadingPreviewCard(
          lessons: bundle.readingLessons,
          documentLoader: documentLoader,
          onOpenLesson: onOpenReadingLesson,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onOpenReading,
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('До читання'),
          ),
        ),
      ],
    );
  }
}
