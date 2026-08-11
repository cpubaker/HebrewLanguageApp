import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/feature_access_localizations.dart';
import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import '../services/ai_context_service.dart';
import '../services/ai_context_settings_store.dart';
import '../services/ai_practice_text_service.dart';
import '../services/ai_practice_text_settings_store.dart';
import '../services/ai_learning_helpers.dart';
import '../services/app_locale_store.dart';
import '../services/app_shell_settings_store.dart';
import '../services/audio_playback_awareness.dart';
import '../services/bool_setting_store.dart';
import '../services/feature_access_service.dart';
import '../services/flashcard_session.dart';
import '../services/latest_request_tracker.dart';
import '../services/lesson_document_loader.dart';
import '../services/lesson_status_updates.dart';
import '../services/learning_bundle_word_updates.dart';
import '../services/learning_progress_repository.dart';
import '../services/learning_word_progress.dart';
import '../services/sprint_stats_store.dart';
import '../services/theme_mode_store.dart';
import '../services/verb_audio_player.dart';
import 'app_shell_navigation.dart';
import 'app_shell_workspaces.dart';
import 'bottom_nav_auto_hide_behavior.dart';
import 'flashcards_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'ai_practice_text_screen.dart';
import 'reading_screen.dart';
import 'repetition_screen.dart';
import 'sprint_screen.dart';
import 'verbs_screen.dart';
import 'words_screen.dart';
import 'writing_screen.dart';

typedef _LessonStatusPersister =
    Future<void> Function(String lessonKey, GuideLessonStatus status);
typedef _LessonStatusesRestorer =
    void Function(Map<String, GuideLessonStatus> statuses);

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.progressRepository,
    required this.documentLoader,
    required this.featureAccessService,
    required this.aiContextService,
    required this.aiContextSettingsStore,
    required this.aiPracticeTextService,
    required this.aiPracticeTextSettingsStore,
    required this.appShellSettingsStore,
    required this.sprintStatsStore,
    required this.audioPlayerFactory,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.localePreference,
    required this.onLocalePreferenceChanged,
    this.audioPlaybackAwarenessFactory = createAudioPlaybackAwareness,
  });

  final LearningProgressRepository progressRepository;
  final LessonDocumentLoader documentLoader;
  final FeatureAccessService featureAccessService;
  final AiContextService aiContextService;
  final AiContextSettingsStore aiContextSettingsStore;
  final AiPracticeTextService aiPracticeTextService;
  final AiPracticeTextSettingsStore aiPracticeTextSettingsStore;
  final AppShellSettingsStore appShellSettingsStore;
  final SprintStatsStore sprintStatsStore;
  final CreateVerbAudioPlayer audioPlayerFactory;
  final CreateAudioPlaybackAwareness audioPlaybackAwarenessFactory;
  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final AppLocalePreference localePreference;
  final ValueChanged<AppLocalePreference> onLocalePreferenceChanged;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  static const Duration _bottomNavAnimationDuration = Duration(
    milliseconds: 260,
  );
  static const double _expandedBodyBottomInset =
      appShellBottomNavigationHeight + 16;
  static const double _collapsedBodyBottomInset = 36;
  static const BottomNavAutoHideBehavior _bottomNavAutoHideBehavior =
      BottomNavAutoHideBehavior();

  late Future<LearningBundle> _bundleFuture;
  late final AudioPlaybackAwareness _audioPlaybackAwareness = widget
      .audioPlaybackAwarenessFactory();
  LearningBundle? _bundle;
  Future<LearningBundle>? _fullWordContextsFuture;
  Map<String, GuideLessonStatus> _guideLessonStatuses =
      <String, GuideLessonStatus>{};
  Map<String, GuideLessonStatus> _readingLessonStatuses =
      <String, GuideLessonStatus>{};
  final LatestRequestTracker _guidePersistenceRequests = LatestRequestTracker();
  final LatestRequestTracker _readingPersistenceRequests =
      LatestRequestTracker();
  final LatestRequestTracker _wordPersistenceRequests = LatestRequestTracker();
  AppRootArea _selectedArea = AppRootArea.home;
  bool _autoHideBottomNavOnScroll = true;
  bool _aiWordContextsEnabled = false;
  bool _aiPracticeTextsEnabled = false;
  bool _isBottomNavVisible = true;
  bool? _pendingBottomNavVisibility;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
    unawaited(_restoreAutoHideBottomNavOnScroll());
    unawaited(_restoreAiWordContextsEnabled());
    unawaited(_restoreAiPracticeTextsEnabled());
  }

  Future<void> _restoreAutoHideBottomNavOnScroll() async {
    final enabled = await widget.appShellSettingsStore
        .loadAutoHideBottomNavOnScroll();
    if (!mounted || enabled == _autoHideBottomNavOnScroll) {
      return;
    }

    setState(() {
      _autoHideBottomNavOnScroll = enabled;
      if (!enabled) {
        _isBottomNavVisible = true;
      }
    });
  }

  Future<void> _restoreAiWordContextsEnabled() async {
    final enabled = await widget.aiContextSettingsStore.loadEnabled();
    if (!mounted ||
        !shouldRestoreEnabledFeature(
          storedEnabled: enabled,
          featureEnabled: widget.featureAccessService.isEnabled(
            AppFeature.aiWordContexts,
          ),
        )) {
      return;
    }

    setState(() {
      _aiWordContextsEnabled = true;
    });
  }

  Future<void> _restoreAiPracticeTextsEnabled() async {
    final enabled = await widget.aiPracticeTextSettingsStore.loadEnabled();
    if (!mounted ||
        !shouldRestoreEnabledFeature(
          storedEnabled: enabled,
          featureEnabled: widget.featureAccessService.isEnabled(
            AppFeature.aiPracticeTexts,
          ),
        )) {
      return;
    }

    setState(() {
      _aiPracticeTextsEnabled = true;
    });
  }

  Future<void> _reload() async {
    setState(() {
      _bundle = null;
      _fullWordContextsFuture = null;
      _bundleFuture = _loadBundle();
    });
    await _bundleFuture;
  }

  Future<LearningBundle> _loadBundle() async {
    final loadedState = await widget.progressRepository.load();

    _guideLessonStatuses = loadedState.guideLessonStatuses;
    _readingLessonStatuses = loadedState.readingLessonStatuses;
    _bundle = loadedState.bundle;
    _primeFullWordContextsForHome(loadedState.bundle);
    return loadedState.bundle;
  }

  void _primeFullWordContextsForHome(LearningBundle bundle) {
    if (bundle.hasFullWordContexts ||
        bundle.words.every((word) => word.contexts.isEmpty)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_ensureFullWordContextsLoaded());
    });
  }

  void _handleThemePreferenceChangeRequested(AppThemePreference preference) {
    final decision = widget.featureAccessService.accessFor(
      AppFeature.nightMode,
    );
    if (preference.requiresNightMode && !decision.isEnabled) {
      _showFeatureLocked(decision);
      return;
    }

    widget.onThemePreferenceChanged(preference);
  }

  Future<LearningBundle> _ensureFullWordContextsLoaded() {
    final activeBundle = _bundle;
    if (activeBundle != null && activeBundle.hasFullWordContexts) {
      return Future<LearningBundle>.value(activeBundle);
    }

    return _fullWordContextsFuture ??= _loadFullWordContexts();
  }

  Future<LearningBundle> _loadFullWordContexts() async {
    try {
      final loadedState = await widget.progressRepository
          .loadWithFullWordContexts();
      final loadedBundle = _mergeCurrentWordProgress(loadedState.bundle);

      if (mounted) {
        setState(() {
          _guideLessonStatuses = loadedState.guideLessonStatuses;
          _readingLessonStatuses = loadedState.readingLessonStatuses;
          _bundle = loadedBundle;
        });
      }

      return loadedBundle;
    } finally {
      _fullWordContextsFuture = null;
    }
  }

  LearningBundle _mergeCurrentWordProgress(LearningBundle loadedBundle) {
    final activeBundle = _bundle;
    if (activeBundle == null) {
      return loadedBundle;
    }

    final activeWordsById = <String, LearningWord>{
      for (final word in activeBundle.words) word.wordId: word,
    };

    return loadedBundle.copyWith(
      words: loadedBundle.words
          .map((loadedWord) {
            final activeWord = activeWordsById[loadedWord.wordId];
            if (activeWord == null) {
              return loadedWord;
            }

            return LearningWordProgress.fromWord(
              activeWord,
            ).applyTo(loadedWord);
          })
          .toList(growable: false),
    );
  }

  Future<LearningBundle> _withAiContextsForWords(
    LearningBundle bundle,
    List<LearningWord> scopeWords,
  ) async {
    if (!shouldLoadAiWordContexts(
      aiWordContextsEnabled: _aiWordContextsEnabled,
      featureEnabled: widget.featureAccessService.isEnabled(
        AppFeature.aiWordContexts,
      ),
      scopeWords: scopeWords,
    )) {
      return bundle;
    }

    try {
      final contextsByWordId = await widget.aiContextService.contextsForWords(
        scopeWords,
      );
      if (contextsByWordId.isEmpty) {
        return bundle;
      }

      final updatedBundle = mergeGeneratedContexts(bundle, contextsByWordId);
      if (mounted) {
        setState(() {
          _bundle = updatedBundle;
        });
      }
      return updatedBundle;
    } catch (error) {
      debugPrint('Failed to load AI word contexts: $error');
      return bundle;
    }
  }

  Future<LearningWord> _resolveWordWithAiContext(LearningWord word) async {
    if (!shouldLoadAiWordContexts(
      aiWordContextsEnabled: _aiWordContextsEnabled,
      featureEnabled: widget.featureAccessService.isEnabled(
        AppFeature.aiWordContexts,
      ),
      scopeWords: <LearningWord>[word],
    )) {
      return word;
    }

    try {
      final contextsByWordId = await widget.aiContextService.contextsForWords(
        <LearningWord>[word],
      );
      final generatedContexts = contextsByWordId[word.wordId];
      if (generatedContexts == null || generatedContexts.isEmpty) {
        return word;
      }

      final updatedWord = word.copyWith(
        contexts: mergeWordContexts(word.contexts, generatedContexts),
      );
      final activeBundle = _bundle;
      if (mounted && activeBundle != null) {
        final updatedBundle = mergeGeneratedContexts(activeBundle, {
          word.wordId: generatedContexts,
        });
        setState(() {
          _bundle = updatedBundle;
        });
      }
      return updatedWord;
    } catch (error) {
      debugPrint('Failed to load AI word context for ${word.wordId}: $error');
      return word;
    }
  }

  void _handleWordProgressChanged(LearningWord updatedWord) {
    final activeBundle = _bundle;
    LearningWord? previousWord;

    if (activeBundle != null) {
      final update = applyWordUpdate(activeBundle, updatedWord);
      previousWord = update.previousWord;
      if (update.didUpdate) {
        setState(() {
          _bundle = update.bundle;
        });
      }
    }

    final requestToken = _wordPersistenceRequests.start(updatedWord.wordId);
    unawaited(
      _persistWordProgress(
        updatedWord: updatedWord,
        previousWord: previousWord,
        requestToken: requestToken,
      ),
    );
  }

  Future<bool> _handleGuideStatusChanged(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    final previousStatuses = Map<String, GuideLessonStatus>.from(
      _guideLessonStatuses,
    );
    setState(() {
      _guideLessonStatuses = applyLessonStatus(
        _guideLessonStatuses,
        lessonKey: lessonKey,
        status: status,
      );
    });

    final requestToken = _guidePersistenceRequests.start(lessonKey);
    return _persistLessonStatusChange(
      lessonKey: lessonKey,
      status: status,
      previousStatuses: previousStatuses,
      requestToken: requestToken,
      requestTracker: _guidePersistenceRequests,
      persistStatus: widget.progressRepository.setGuideLessonStatus,
      restoreStatuses: (statuses) {
        _guideLessonStatuses = statuses;
      },
      progressLabel: 'guide',
      errorMessage: AppLocalizations.of(context).shellGuideSaveFailure,
    );
  }

  Future<bool> _handleReadingStatusChanged(
    String lessonKey,
    GuideLessonStatus status,
  ) async {
    final previousStatuses = Map<String, GuideLessonStatus>.from(
      _readingLessonStatuses,
    );
    setState(() {
      _readingLessonStatuses = applyLessonStatus(
        _readingLessonStatuses,
        lessonKey: lessonKey,
        status: status,
      );
    });

    final requestToken = _readingPersistenceRequests.start(lessonKey);
    return _persistLessonStatusChange(
      lessonKey: lessonKey,
      status: status,
      previousStatuses: previousStatuses,
      requestToken: requestToken,
      requestTracker: _readingPersistenceRequests,
      persistStatus: widget.progressRepository.setReadingLessonStatus,
      restoreStatuses: (statuses) {
        _readingLessonStatuses = statuses;
      },
      progressLabel: 'reading',
      errorMessage: AppLocalizations.of(context).shellReadingSaveFailure,
    );
  }

  void _selectArea(int index) {
    setState(() {
      _selectedArea = AppRootArea.values[index];
      _isBottomNavVisible = true;
    });
  }

  void _openLearnWords() {
    unawaited(_openLearnWordsWithFullContexts());
  }

  Future<void> _openLearnWordsWithFullContexts() async {
    final LearningBundle bundle;
    try {
      bundle = await _ensureFullWordContextsLoaded();
    } catch (error) {
      debugPrint('Failed to load word contexts for dictionary: $error');
      if (!mounted) {
        return;
      }
      _showPersistenceError(
        AppLocalizations.of(context).shellContextsLoadFailure,
      );
      return;
    }
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: WordsScreen(
            words: bundle.words,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: _audioPlaybackAwareness,
            resolveWordContexts: _resolveWordWithAiContext,
            onWordProgressChanged: _handleWordProgressChanged,
          ),
        ),
      ),
    );
  }

  void _openLearnVerbs() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: VerbsScreen(
            lessons: _bundle?.verbLessons ?? const <LessonEntry>[],
            documentLoader: widget.documentLoader,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: _audioPlaybackAwareness,
          ),
        ),
      ),
    );
  }

  void _openFlashcards([FlashcardDeckMode mode = FlashcardDeckMode.allWords]) {
    unawaited(_openFlashcardsWithFullContexts(mode));
  }

  Future<void> _openFlashcardsWithFullContexts(FlashcardDeckMode mode) async {
    LearningBundle bundle;
    try {
      bundle = await _ensureFullWordContextsLoaded();
      bundle = await _withAiContextsForWords(
        bundle,
        aiContextScopeWords(bundle, mode),
      );
    } catch (error) {
      debugPrint('Failed to load word contexts for flashcards: $error');
      if (mounted) {
        _showPersistenceError(
          AppLocalizations.of(context).shellContextsLoadFailure,
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: FlashcardsScreen(
            words: bundle.words,
            onWordProgressChanged: _handleWordProgressChanged,
            initialDeckMode: mode,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: _audioPlaybackAwareness,
          ),
        ),
      ),
    );
  }

  void _openWritingPractice([
    WritingPracticeMode mode = WritingPracticeMode.typing,
  ]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: WritingScreen(
            words: _bundle?.words ?? const <LearningWord>[],
            onWordProgressChanged: _handleWordProgressChanged,
            initialMode: mode,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: _audioPlaybackAwareness,
          ),
        ),
      ),
    );
  }

  void _openSprint() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: SprintScreen(
            words: _bundle?.words ?? const <LearningWord>[],
            onWordProgressChanged: _handleWordProgressChanged,
            audioPlayerFactory: widget.audioPlayerFactory,
            statsStore: widget.sprintStatsStore,
          ),
        ),
      ),
    );
  }

  void _openAiPracticeText() {
    final decision = widget.featureAccessService.accessFor(
      AppFeature.aiPracticeTexts,
    );
    if (!decision.isEnabled) {
      _showFeatureLocked(decision);
      return;
    }

    if (!_aiPracticeTextsEnabled) {
      _showPersistenceError(
        AppLocalizations.of(context).shellAiTextsDisabled,
      );
      return;
    }

    final scopeWords = aiPracticeTextScopeWords(
      _bundle?.words ?? const <LearningWord>[],
    );
    if (scopeWords.isEmpty) {
      _showPersistenceError(AppLocalizations.of(context).shellNoWordsForText);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: AiPracticeTextScreen(
            words: scopeWords,
            textService: widget.aiPracticeTextService,
            onOpenFlashcards: () => _openFlashcards(FlashcardDeckMode.allWords),
            onOpenWriting: () => _openWritingPractice(),
          ),
        ),
      ),
    );
  }

  void _openRepetition() {
    unawaited(_openRepetitionWithFullContexts());
  }

  Future<void> _openRepetitionWithFullContexts() async {
    LearningBundle bundle;
    try {
      bundle = await _ensureFullWordContextsLoaded();
      bundle = await _withAiContextsForWords(
        bundle,
        aiContextScopeWords(bundle, FlashcardDeckMode.needsReview),
      );
    } catch (error) {
      debugPrint('Failed to load word contexts for repetition: $error');
      if (mounted) {
        _showPersistenceError(
          AppLocalizations.of(context).shellContextsLoadFailure,
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: RepetitionScreen(
            words: bundle.words,
            audioPlayerFactory: widget.audioPlayerFactory,
            audioPlaybackAwareness: _audioPlaybackAwareness,
          ),
        ),
      ),
    );
  }

  void _openGuide() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: GuideScreen(
            lessons: _bundle?.guideLessons ?? const <LessonEntry>[],
            documentLoader: widget.documentLoader,
            lessonStatuses: _guideLessonStatuses,
            onStatusChanged: _handleGuideStatusChanged,
          ),
        ),
      ),
    );
  }

  void _openReading() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenModuleScreen(
          child: ReadingScreen(
            lessons: _bundle?.readingLessons ?? const <LessonEntry>[],
            documentLoader: widget.documentLoader,
            lessonStatuses: _readingLessonStatuses,
            onStatusChanged: _handleReadingStatusChanged,
          ),
        ),
      ),
    );
  }

  void _setBottomNavVisibility(bool isVisible) {
    if (_isBottomNavVisible == isVisible || !mounted) {
      return;
    }

    final schedulerPhase = WidgetsBinding.instance.schedulerPhase;
    final canUpdateImmediately =
        schedulerPhase == SchedulerPhase.idle ||
        schedulerPhase == SchedulerPhase.postFrameCallbacks;

    if (!canUpdateImmediately) {
      if (_pendingBottomNavVisibility == isVisible) {
        return;
      }

      _pendingBottomNavVisibility = isVisible;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _pendingBottomNavVisibility = null;
          return;
        }

        final pendingVisibility = _pendingBottomNavVisibility;
        _pendingBottomNavVisibility = null;
        if (pendingVisibility == null ||
            _isBottomNavVisible == pendingVisibility) {
          return;
        }

        setState(() {
          _isBottomNavVisible = pendingVisibility;
        });
      });
      return;
    }

    _pendingBottomNavVisibility = null;
    setState(() {
      _isBottomNavVisible = isVisible;
    });
  }

  bool _handleShellScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    final decision = _bottomNavAutoHideBehavior.decisionFor(
      autoHideEnabled: _autoHideBottomNavOnScroll,
      axis: metrics.axis,
      maxScrollExtent: metrics.maxScrollExtent,
      pixels: metrics.pixels,
      userScrollDirection: notification is UserScrollNotification
          ? notification.direction
          : null,
      scrollDelta: notification is ScrollUpdateNotification
          ? notification.scrollDelta
          : null,
    );
    _applyBottomNavVisibilityDecision(decision);

    return false;
  }

  void _applyBottomNavVisibilityDecision(BottomNavVisibilityDecision decision) {
    switch (decision) {
      case BottomNavVisibilityDecision.show:
        _setBottomNavVisibility(true);
      case BottomNavVisibilityDecision.hide:
        _setBottomNavVisibility(false);
      case BottomNavVisibilityDecision.none:
        break;
    }
  }

  void _setAutoHideBottomNavOnScroll(bool value) {
    setState(() {
      _autoHideBottomNavOnScroll = value;
      if (!value) {
        _isBottomNavVisible = true;
      }
    });
    unawaited(
      widget.appShellSettingsStore.saveAutoHideBottomNavOnScroll(value),
    );
  }

  void _setAiWordContextsEnabled(bool value) {
    final decision = widget.featureAccessService.accessFor(
      AppFeature.aiWordContexts,
    );
    if (value && !decision.isEnabled) {
      _showFeatureLocked(decision);
      return;
    }

    setState(() {
      _aiWordContextsEnabled = value;
    });
    unawaited(widget.aiContextSettingsStore.saveEnabled(value));
  }

  void _setAiPracticeTextsEnabled(bool value) {
    final decision = widget.featureAccessService.accessFor(
      AppFeature.aiPracticeTexts,
    );
    if (value && !decision.isEnabled) {
      _showFeatureLocked(decision);
      return;
    }

    setState(() {
      _aiPracticeTextsEnabled = value;
    });
    unawaited(widget.aiPracticeTextSettingsStore.saveEnabled(value));
  }

  Future<void> _persistWordProgress({
    required LearningWord updatedWord,
    required LearningWord? previousWord,
    required int requestToken,
  }) async {
    try {
      await widget.progressRepository.saveWord(updatedWord);
    } catch (error) {
      debugPrint(
        'Failed to save word progress for ${updatedWord.wordId}: $error',
      );

      if (!mounted ||
          !_wordPersistenceRequests.isLatest(
            updatedWord.wordId,
            requestToken,
          )) {
        return;
      }

      final activeBundle = _bundle;
      if (activeBundle != null && previousWord != null) {
        final restoredBundle = restoreWordUpdate(activeBundle, previousWord);
        if (identical(restoredBundle, activeBundle)) {
          return;
        }

        setState(() {
          _bundle = restoredBundle;
        });
      }

      _showPersistenceError(
        AppLocalizations.of(context).shellWordSaveFailure,
      );
    }
  }

  Future<bool> _persistLessonStatusChange({
    required String lessonKey,
    required GuideLessonStatus status,
    required Map<String, GuideLessonStatus> previousStatuses,
    required int requestToken,
    required LatestRequestTracker requestTracker,
    required _LessonStatusPersister persistStatus,
    required _LessonStatusesRestorer restoreStatuses,
    required String progressLabel,
    required String errorMessage,
  }) async {
    try {
      await persistStatus(lessonKey, status);
      return true;
    } catch (error) {
      debugPrint(
        'Failed to save $progressLabel progress for $lessonKey: $error',
      );

      if (!mounted || !requestTracker.isLatest(lessonKey, requestToken)) {
        return false;
      }

      setState(() {
        restoreStatuses(previousStatuses);
      });

      _showPersistenceError(errorMessage);
      return false;
    }
  }

  void _showPersistenceError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFeatureLocked(FeatureAccessDecision decision) {
    final localizations = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final hasUpgradePath = decision.localizedUpgradeKey.isNotEmpty;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${decision.localizedTitle(localizations)}: ${decision.localizedDescription(localizations)}',
          ),
          action: hasUpgradePath
              ? SnackBarAction(
                  label: localizations.featureUpgradePro,
                  onPressed: () {},
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearningBundle>(
      future: _bundleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingState();
        }

        if (snapshot.hasError) {
          return _ErrorState(
            onRetry: _reload,
            details: kDebugMode ? snapshot.error?.toString() : null,
          );
        }

        final bundle = _bundle ?? snapshot.requireData;
        return Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: _handleShellScrollNotification,
            child: Stack(
              children: [
                SafeArea(
                  child: AnimatedPadding(
                    duration: _bottomNavAnimationDuration,
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(
                      bottom: _isBottomNavVisible
                          ? _expandedBodyBottomInset
                          : _collapsedBodyBottomInset,
                    ),
                    child: IndexedStack(
                      index: _selectedArea.index,
                      children: [
                        HomeScreen(
                          bundle: bundle,
                          audioPlayerFactory: widget.audioPlayerFactory,
                          audioPlaybackAwareness: _audioPlaybackAwareness,
                          onOpenWords: _openLearnWords,
                          onOpenFlashcards: _openFlashcards,
                          onOpenWriting: () => _openWritingPractice(),
                          onOpenSprint: _openSprint,
                          onOpenGuide: _openGuide,
                          onOpenVerbs: _openLearnVerbs,
                          onOpenReading: _openReading,
                          firstActionCompletedStore:
                              const SharedPreferencesBoolSettingStore(
                            key: 'home.first_action_completed',
                          ),
                        ),
                        AppShellLearnWorkspace(
                          onOpenWords: _openLearnWords,
                          onOpenVerbs: _openLearnVerbs,
                          onOpenGuide: _openGuide,
                          onOpenReading: _openReading,
                        ),
                        AppShellPracticeWorkspace(
                          onOpenFlashcards: _openFlashcards,
                          onOpenWriting: () => _openWritingPractice(),
                          onOpenWritingConstructor: () => _openWritingPractice(
                            WritingPracticeMode.constructor,
                          ),
                          onOpenRepetition: _openRepetition,
                          onOpenSprint: _openSprint,
                          onOpenAiPracticeText: _openAiPracticeText,
                        ),
                        AppShellProfileWorkspace(
                          bundle: bundle,
                          guideLessonStatuses: _guideLessonStatuses,
                          readingLessonStatuses: _readingLessonStatuses,
                          autoHideBottomNavOnScroll: _autoHideBottomNavOnScroll,
                          onAutoHideBottomNavOnScrollChanged:
                              _setAutoHideBottomNavOnScroll,
                          aiWordContextsEnabled: _aiWordContextsEnabled,
                          aiWordContextsAccess: widget.featureAccessService
                              .accessFor(AppFeature.aiWordContexts),
                          onAiWordContextsEnabledChanged:
                              _setAiWordContextsEnabled,
                          aiPracticeTextsEnabled: _aiPracticeTextsEnabled,
                          aiPracticeTextsAccess: widget.featureAccessService
                              .accessFor(AppFeature.aiPracticeTexts),
                          onAiPracticeTextsEnabledChanged:
                              _setAiPracticeTextsEnabled,
                          themePreference: widget.themePreference,
                          nightModeAccess: widget.featureAccessService
                              .accessFor(AppFeature.nightMode),
                          onThemePreferenceChanged:
                              _handleThemePreferenceChangeRequested,
                          localePreference: widget.localePreference,
                          onLocalePreferenceChanged:
                              widget.onLocalePreferenceChanged,
                          onOpenWords: _openLearnWords,
                          onOpenWriting: () => _openWritingPractice(),
                          onOpenGuide: _openGuide,
                          onOpenReading: _openReading,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppShellBottomNavigation(
                    isVisible: _isBottomNavVisible,
                    duration: _bottomNavAnimationDuration,
                    selectedIndex: _selectedArea.index,
                    onDestinationSelected: _selectArea,
                    onRevealRequested: () => _setBottomNavVisibility(true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FullscreenModuleScreen extends StatelessWidget {
  const _FullscreenModuleScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child));
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(AppLocalizations.of(context).shellLoadingMaterials),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, this.details});

  final Future<void> Function() onRetry;
  final String? details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).shellMaterialsLoadFailure,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (details != null && details!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  details!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  onRetry();
                },
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
