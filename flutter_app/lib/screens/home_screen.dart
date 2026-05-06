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
    final pagePadding = tokens.pagePadding;
    final progress = StudyProgressSnapshot.fromWords(bundle.words);
    final streak = StudyStreakSnapshot.fromWords(bundle.words);
    final flashcards = FlashcardFocusSnapshot.fromWords(bundle.words);
    final readingPreviewLessons = sortReadingLessons(
      bundle.readingLessons,
    ).take(3);
    final continueAction = _buildContinueAction(
      tokens: tokens,
      progress: progress,
      flashcards: flashcards,
    );
    final recommendedActions = _buildRecommendedActions(
      tokens: tokens,
      progress: progress,
      flashcards: flashcards,
    );
    final wordOfDay = const WordOfDayService().select(
      words: bundle.words,
      date: (wordOfDayDateProvider ?? DateTime.now)(),
    );

    return ListView(
      padding: pagePadding.copyWith(bottom: 32),
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
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Словник',
                subtitle:
                    'Повний список слів із пошуком і позначками прогресу.',
              ),
              const SizedBox(height: 14),
              Column(
                children: bundle.words
                    .take(6)
                    .map((word) => _WordTile(word: word))
                    .toList(growable: false),
              ),
            ],
          ),
        ),
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
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Що почитати',
                subtitle:
                    'Кілька уроків, з яких зручно продовжити просто зараз.',
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  ...readingPreviewLessons.map(
                    (lesson) => _ReadingLessonTile(
                      lesson: lesson,
                      documentLoader: documentLoader,
                      onTap: () => onOpenReadingLesson(lesson),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  _DashboardAction _buildContinueAction({
    required AppThemeTokens tokens,
    required StudyProgressSnapshot progress,
    required FlashcardFocusSnapshot flashcards,
  }) {
    if (flashcards.needsReview > 0) {
      return _DashboardAction(
        title: 'Продовжити повторення',
        subtitle:
            '${flashcards.needsReview} слів чекають у картках на повторення.',
        buttonLabel: 'До повторення',
        icon: Icons.refresh_rounded,
        accent: tokens.warningAccent,
        onTap: () => onOpenFlashcards(FlashcardDeckMode.needsReview),
      );
    }

    if (progress.unseen > 0) {
      return _DashboardAction(
        title: 'Почати нові слова',
        subtitle: '${progress.unseen} слів ще не відкривали в тренуванні.',
        buttonLabel: 'До карток',
        icon: Icons.style_rounded,
        accent: tokens.successAccent,
        onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
      );
    }

    if (bundle.readingLessons.isNotEmpty) {
      return _DashboardAction(
        title: 'Почитати далі',
        subtitle: 'У бібліотеці вже є тексти, з яких можна продовжити.',
        buttonLabel: 'До читання',
        icon: Icons.auto_stories_rounded,
        accent: tokens.newContentAccent,
        onTap: onOpenReading,
      );
    }

    return _DashboardAction(
      title: 'Повернутися до словника',
      subtitle: 'Перегляньте слова, щоб обрати наступний напрям навчання.',
      buttonLabel: 'До слів',
      icon: Icons.translate_rounded,
      accent: tokens.primaryAccent,
      onTap: onOpenWords,
    );
  }

  List<_DashboardAction> _buildRecommendedActions({
    required AppThemeTokens tokens,
    required StudyProgressSnapshot progress,
    required FlashcardFocusSnapshot flashcards,
  }) {
    final actions = <_DashboardAction>[
      _DashboardAction(
        title: 'Картки з прикладами',
        subtitle: flashcards.withContexts > 0
            ? '${flashcards.withContexts} слів уже мають контекст для практики.'
            : 'Контекстні картки з’являтимуться, коли для слів буде більше прикладів.',
        buttonLabel: 'Відкрити',
        icon: Icons.chat_bubble_outline_rounded,
        accent: tokens.contextAccent,
        onTap: () => onOpenFlashcards(FlashcardDeckMode.withContexts),
      ),
      _DashboardAction(
        title: 'Письмо',
        subtitle: progress.seen > 0
            ? 'Повторіть знайомі слова й потренуйте написання.'
            : 'Спочатку відкрийте кілька слів у картках, а потім тренуйте їхнє написання тут.',
        buttonLabel: 'Тренувати',
        icon: Icons.edit_rounded,
        accent: tokens.newContentAccent,
        onTap: onOpenWriting,
      ),
      _DashboardAction(
        title: 'Матеріали',
        subtitle: bundle.guideLessons.isNotEmpty
            ? 'У довіднику й читанні вже є теми для наступного кроку.'
            : 'Матеріали з’являться тут, коли їх буде завантажено.',
        buttonLabel: 'Відкрити',
        icon: Icons.menu_book_rounded,
        accent: tokens.vocabularyAccent,
        onTap: onOpenGuide,
      ),
    ];

    return actions;
  }
}

class _WordOfDayHeroPanel extends StatefulWidget {
  const _WordOfDayHeroPanel({
    required this.entry,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final WordOfDayEntry entry;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_WordOfDayHeroPanel> createState() => _WordOfDayHeroPanelState();
}

class _WordOfDayHeroPanelState extends State<_WordOfDayHeroPanel> {
  StreamSubscription<bool>? _playbackSubscription;
  LearningAudioPlayer? _audioPlayer;
  bool _isCheckingAudio = false;
  bool _hasAudio = false;
  bool _isAudioBusy = false;
  bool _isAudioPlaying = false;
  int _audioRequestToken = 0;

  String? get _audioAssetPath {
    final path = widget.entry.word.audioAssetPath?.trim();
    return path == null || path.isEmpty ? null : path;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_checkAudioAvailability());
  }

  @override
  void didUpdateWidget(covariant _WordOfDayHeroPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.word.wordId != widget.entry.word.wordId ||
        oldWidget.entry.word.audioAssetPath !=
            widget.entry.word.audioAssetPath) {
      unawaited(_stopAudio());
      unawaited(_checkAudioAvailability());
    }
  }

  LearningAudioPlayer _ensureAudioPlayer() {
    final existingPlayer = _audioPlayer;
    if (existingPlayer != null) {
      return existingPlayer;
    }

    final player = widget.audioPlayerFactory();
    _playbackSubscription = player.isPlayingStream.listen((isPlaying) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAudioPlaying = isPlaying;
      });
    });
    _audioPlayer = player;
    return player;
  }

  Future<void> _checkAudioAvailability() async {
    final requestToken = ++_audioRequestToken;
    final audioAssetPath = _audioAssetPath;
    if (audioAssetPath == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCheckingAudio = false;
        _hasAudio = false;
      });
      return;
    }

    setState(() {
      _isCheckingAudio = true;
      _hasAudio = false;
    });

    var hasAudio = false;
    try {
      final player = _ensureAudioPlayer();
      hasAudio = await player.assetExists(audioAssetPath);
      if (hasAudio) {
        hasAudio = await player.prepareAsset(audioAssetPath);
      }
    } catch (error) {
      debugPrint('Failed to prepare word of day audio: $error');
      hasAudio = false;
    }

    if (!mounted || _audioRequestToken != requestToken) {
      return;
    }

    setState(() {
      _isCheckingAudio = false;
      _hasAudio = hasAudio;
    });
  }

  Future<void> _toggleAudio() async {
    if (_isAudioBusy) {
      return;
    }

    final audioAssetPath = _audioAssetPath;
    final player = _audioPlayer;
    if (audioAssetPath == null || player == null || !_hasAudio) {
      return;
    }

    setState(() {
      _isAudioBusy = true;
    });

    try {
      if (_isAudioPlaying) {
        await player.stop();
      } else {
        await showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: widget.audioPlaybackAwareness,
        );
        await player.playAsset(audioAssetPath);
      }
    } catch (error) {
      debugPrint('Failed to play word of day audio: $error');
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Не вдалося відтворити озвучку слова.'),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAudioBusy = false;
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    _audioRequestToken += 1;
    final player = _audioPlayer;
    if (player == null) {
      return;
    }

    try {
      await player.stop();
    } catch (error) {
      debugPrint('Failed to stop word of day audio: $error');
    }

    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    final player = _audioPlayer;
    if (player != null) {
      unawaited(player.stop());
      unawaited(player.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final contextSentence = widget.entry.context;
    final audioEnabled = _hasAudio && !_isAudioBusy && !_isCheckingAudio;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            tokens.heroGradientStart,
            tokens.heroGradientMiddle,
            tokens.heroGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.heroShadowColor,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tokens.heroChipBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Слово дня',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.heroText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: _isCheckingAudio
                    ? 'Перевіряємо озвучку'
                    : _hasAudio
                    ? (_isAudioPlaying
                          ? 'Зупинити озвучку'
                          : 'Увімкнути озвучку')
                    : 'Озвучка ще недоступна',
                child: Material(
                  color: tokens.heroChipBackground,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const ValueKey('word-of-day-audio-button'),
                    customBorder: const CircleBorder(),
                    onTap: audioEnabled ? _toggleAudio : null,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: _isCheckingAudio || _isAudioBusy
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tokens.heroText,
                                  ),
                                ),
                              )
                            : Icon(
                                _hasAudio
                                    ? (_isAudioPlaying
                                          ? Icons.stop_rounded
                                          : Icons.volume_up_rounded)
                                    : Icons.volume_off_rounded,
                                color: _hasAudio
                                    ? tokens.heroText
                                    : tokens.heroMutedText,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.entry.word.hebrew,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: tokens.heroText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.entry.word.translation,
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.entry.word.transcription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.heroMutedText,
              height: 1.35,
            ),
          ),
          if (contextSentence != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.heroChipBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contextSentence.hebrew.trim().isNotEmpty) ...[
                    Text(
                      contextSentence.hebrew,
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.heroText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (contextSentence.translation.trim().isNotEmpty) ...[
                    if (contextSentence.hebrew.trim().isNotEmpty)
                      const SizedBox(height: 6),
                    Text(
                      contextSentence.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.heroMutedText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyWordOfDayHeroPanel extends StatelessWidget {
  const _EmptyWordOfDayHeroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            tokens.heroGradientStart,
            tokens.heroGradientMiddle,
            tokens.heroGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.heroShadowColor,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.heroChipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Слово дня',
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.heroText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Слова з’являться після завантаження навчальної бази.',
            style: theme.textTheme.titleLarge?.copyWith(
              color: tokens.heroText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final card = Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: onTap == null
          ? card
          : InkWell(
              borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
              onTap: onTap,
              child: card,
            ),
    );
  }
}

class _QuickActionStrip extends StatelessWidget {
  const _QuickActionStrip({
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenSprint,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenSprint;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Швидкі дії',
            subtitle: 'Швидкий доступ до основних вправ і матеріалів.',
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              FilledButton.icon(
                onPressed: () => onOpenFlashcards(FlashcardDeckMode.allWords),
                icon: const Icon(Icons.style_rounded),
                label: const Text('До карток'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWriting,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('До письма'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenSprint,
                icon: const Icon(Icons.timer_rounded),
                label: const Text('До спринту'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWords,
                icon: const Icon(Icons.translate_rounded),
                label: const Text('До слів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenVerbs,
                icon: const Icon(Icons.play_lesson_rounded),
                label: const Text('До дієслів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenGuide,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('До довідника'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReading,
                icon: const Icon(Icons.auto_stories_rounded),
                label: const Text('До читання'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardPrimaryActionCard extends StatelessWidget {
  const _DashboardPrimaryActionCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: action.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Продовжити',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).appTokens.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).appTokens.mutedText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: action.onTap,
                  icon: Icon(action.icon),
                  label: Text(action.buttonLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRecommendationsCard extends StatelessWidget {
  const _DashboardRecommendationsCard({required this.actions});

  final List<_DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Що далі',
            subtitle: 'Рекомендовані вправи й матеріали для продовження.',
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < actions.length; index += 1) ...[
            _DashboardRecommendationTile(action: actions[index]),
            if (index != actions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DashboardRecommendationTile extends StatelessWidget {
  const _DashboardRecommendationTile({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).appTokens.subtleSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: action.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: action.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).appTokens.mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: action.onTap,
            child: Text(action.buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _InventoryOverviewCard extends StatelessWidget {
  const _InventoryOverviewCard({
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    final summaryCards = [
      _SummaryCard(
        label: 'Слова',
        value: bundle.words.length,
        accent: tokens.successAccent,
        onTap: onOpenWords,
      ),
      _SummaryCard(
        label: 'Картки',
        value: bundle.words.where((word) => word.contexts.isNotEmpty).length,
        accent: tokens.warningAccent,
        onTap: onOpenFlashcards,
      ),
      _SummaryCard(
        label: 'Письмо',
        value: bundle.words
            .where((word) => word.writingCorrect > 0 || word.writingWrong > 0)
            .length,
        accent: tokens.newContentAccent,
        onTap: onOpenWriting,
      ),
      _SummaryCard(
        label: 'Довідник',
        value: bundle.guideLessons.length,
        accent: tokens.vocabularyAccent,
        onTap: onOpenGuide,
      ),
      _SummaryCard(
        label: 'Дієслова',
        value: bundle.verbLessons.length,
        accent: tokens.verbAccent,
        onTap: onOpenVerbs,
      ),
      _SummaryCard(
        label: 'Читання',
        value: bundle.readingLessons.length,
        accent: tokens.readingAccent,
        onTap: onOpenReading,
      ),
    ];

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Усі модулі',
            subtitle: 'Усі розділи навчальної бази зібрані в одному місці.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final card in summaryCards)
                    SizedBox(width: itemWidth, child: card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FlashcardFocusCard extends StatelessWidget {
  const _FlashcardFocusCard({
    required this.snapshot,
    required this.onOpenAll,
    required this.onOpenContext,
    required this.onOpenReview,
  });

  final FlashcardFocusSnapshot snapshot;
  final VoidCallback onOpenAll;
  final VoidCallback? onOpenContext;
  final VoidCallback? onOpenReview;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Картки на сьогодні',
            subtitle: snapshot.needsReview > 0
                ? 'У вас є слова на повторення. Можна продовжити або перейти до карток із прикладами.'
                : 'Оберіть режим: усі слова або картки з прикладами.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppMetricTile(
                label: 'Усі',
                value: snapshot.total,
                accent: tokens.primaryAccent,
              ),
              AppMetricTile(
                label: 'З прикладами',
                value: snapshot.withContexts,
                accent: tokens.contextAccent,
              ),
              AppMetricTile(
                label: 'На повторенні',
                value: snapshot.needsReview,
                accent: tokens.warningAccent,
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: snapshot.known,
                accent: tokens.successAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              if (onOpenReview != null)
                FilledButton.icon(
                  onPressed: onOpenReview,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Продовжити'),
                ),
              OutlinedButton.icon(
                onPressed: onOpenContext,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('З прикладами'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenAll,
                icon: const Icon(Icons.style_outlined),
                label: const Text('Усі'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyStreakCard extends StatelessWidget {
  const _StudyStreakCard({required this.streak});

  final StudyStreakSnapshot streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final currentDaysLabel = _dayCountLabel(streak.currentDays);
    final subtitle = _streakSubtitle(streak);

    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.warningAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: tokens.warningAccent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Серія занять',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  streak.currentDays > 0
                      ? '$currentDaysLabel поспіль'
                      : 'Почніть серію сьогодні',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedText,
                    height: 1.45,
                  ),
                ),
                if (streak.activityDays > 0) ...[
                  const SizedBox(height: 12),
                  AppStatChip(
                    label: 'Активні дні',
                    value: streak.activityDays,
                    accent: tokens.primaryAccent,
                    backgroundColor: tokens.subtleSurface,
                    textColor: theme.colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _streakSubtitle(StudyStreakSnapshot streak) {
    if (streak.wasActiveToday) {
      return 'Сьогоднішнє заняття вже враховано в серії.';
    }

    if (streak.wasActiveYesterday) {
      return 'Серія ще тримається. Зробіть одне тренування сьогодні, щоб продовжити її.';
    }

    if (streak.hasActivity) {
      return 'Остання активність була раніше, тож поточна серія почнеться з нового заняття.';
    }

    return 'Коли пройдете перше тренування, тут з’явиться ваша серія занять.';
  }

  String _dayCountLabel(int days) {
    final suffix = days % 100;
    final lastDigit = days % 10;
    final noun = suffix >= 11 && suffix <= 14
        ? 'днів'
        : lastDigit == 1
        ? 'день'
        : lastDigit >= 2 && lastDigit <= 4
        ? 'дні'
        : 'днів';

    return '$days $noun';
  }
}

class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({required this.progress});

  final StudyProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Прогрес навчання',
            subtitle:
                'Прогрес зберігається на цьому пристрої, тож можна спокійно продовжити пізніше.',
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.completionRatio,
              backgroundColor: Theme.of(context).appTokens.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.successAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Опрацьовано ${progress.seen} із ${progress.total} слів',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).appTokens.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppMetricTile(
                label: 'Опрацьовані',
                value: progress.seen,
                accent: tokens.primaryAccent,
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: progress.known,
                accent: tokens.successAccent,
              ),
              AppMetricTile(
                label: 'Повторити',
                value: progress.needsReview,
                accent: tokens.warningAccent,
              ),
              AppMetricTile(
                label: 'Нові',
                value: progress.unseen,
                accent: tokens.newContentAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.word});

  final LearningWord word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final learningState = classifyWordLearningState(word);
    final status = switch (learningState) {
      WordLearningState.unseen => (
        label: 'Нове',
        color: tokens.newContentAccent,
        background: tokens.wordNewSurface,
      ),
      WordLearningState.known => (
        label: 'Вивчене',
        color: tokens.successAccent,
        background: tokens.wordKnownSurface,
      ),
      WordLearningState.needsReview => (
        label: 'Повторити',
        color: tokens.warningAccent,
        background: tokens.wordReviewSurface,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).appTokens.subtleSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.translation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.transcription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).appTokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              word.hebrew,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingLessonTile extends StatelessWidget {
  const _ReadingLessonTile({
    required this.lesson,
    required this.documentLoader,
    required this.onTap,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final fallbackTitle = readingLessonTitle(lesson);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).appTokens.subtleSurface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tokens.contextAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: tokens.contextAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<LessonDocument>(
                        future: documentLoader.load(lesson.assetPath),
                        builder: (context, snapshot) {
                          final document = snapshot.data;
                          final resolvedTitle =
                              document != null &&
                                  document.title.trim().isNotEmpty
                              ? document.title.trim()
                              : fallbackTitle;

                          return Text(
                            resolvedTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).appTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
