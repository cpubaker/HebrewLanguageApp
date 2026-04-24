import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/ai_context_service.dart';
import '../services/ai_context_settings_store.dart';
import '../services/audio_playback_awareness.dart';
import '../services/feature_access_service.dart';
import '../services/flashcard_session.dart';
import '../services/lesson_document_loader.dart';
import '../services/learning_progress_repository.dart';
import '../services/progress_snapshot.dart';
import '../services/verb_audio_player.dart';
import '../theme/app_theme.dart';
import 'flashcards_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'reading_screen.dart';
import 'repetition_screen.dart';
import 'sprint_screen.dart';
import 'verbs_screen.dart';
import 'workspace_screen.dart';
import 'words_screen.dart';
import 'writing_screen.dart';

enum _RootArea { home, learn, practice, materials, more }

enum _MaterialsSection { guide, reading }

enum _MoreSection { overview, progress, settings }

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.progressRepository,
    required this.documentLoader,
    required this.featureAccessService,
    required this.aiContextService,
    required this.aiContextSettingsStore,
    required this.audioPlayerFactory,
    required this.isDarkMode,
    required this.onToggleThemeMode,
    this.audioPlaybackAwarenessFactory = createAudioPlaybackAwareness,
  });

  final LearningProgressRepository progressRepository;
  final LessonDocumentLoader documentLoader;
  final FeatureAccessService featureAccessService;
  final AiContextService aiContextService;
  final AiContextSettingsStore aiContextSettingsStore;
  final CreateVerbAudioPlayer audioPlayerFactory;
  final CreateAudioPlaybackAwareness audioPlaybackAwarenessFactory;
  final bool isDarkMode;
  final VoidCallback onToggleThemeMode;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  static const Duration _bottomNavAnimationDuration = Duration(
    milliseconds: 260,
  );
  static const double _expandedBodyBottomInset = 108;
  static const double _collapsedBodyBottomInset = 36;

  late Future<LearningBundle> _bundleFuture;
  late final AudioPlaybackAwareness _audioPlaybackAwareness = widget
      .audioPlaybackAwarenessFactory();
  LearningBundle? _bundle;
  Future<LearningBundle>? _fullWordContextsFuture;
  Map<String, GuideLessonStatus> _guideLessonStatuses =
      <String, GuideLessonStatus>{};
  Map<String, GuideLessonStatus> _readingLessonStatuses =
      <String, GuideLessonStatus>{};
  final Map<String, int> _guidePersistenceTokens = <String, int>{};
  final Map<String, int> _readingPersistenceTokens = <String, int>{};
  final Map<String, int> _wordPersistenceTokens = <String, int>{};
  _RootArea _selectedArea = _RootArea.home;
  _MaterialsSection _materialsSection = _MaterialsSection.guide;
  _MoreSection _moreSection = _MoreSection.overview;
  bool _autoHideBottomNavOnScroll = true;
  bool _aiWordContextsEnabled = false;
  bool _preferWritingPractice = false;
  FlashcardDeckMode _preferredFlashcardDeckMode = FlashcardDeckMode.allWords;
  bool _isBottomNavVisible = true;
  bool? _pendingBottomNavVisibility;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
    unawaited(_restoreAiWordContextsEnabled());
  }

  Future<void> _restoreAiWordContextsEnabled() async {
    final enabled = await widget.aiContextSettingsStore.loadEnabled();
    if (!mounted ||
        !enabled ||
        !widget.featureAccessService.isEnabled(AppFeature.aiWordContexts)) {
      return;
    }

    setState(() {
      _aiWordContextsEnabled = true;
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
    return loadedState.bundle;
  }

  void _handleThemeToggleRequested() {
    final decision = widget.featureAccessService.accessFor(
      AppFeature.nightMode,
    );
    if (!decision.isEnabled) {
      _showFeatureLocked(decision);
      return;
    }

    widget.onToggleThemeMode();
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

            return loadedWord.copyWith(
              correct: activeWord.correct,
              wrong: activeWord.wrong,
              lastCorrect: activeWord.lastCorrect,
              lastReviewedAt: activeWord.lastReviewedAt,
              lastReviewCorrect: activeWord.lastReviewCorrect,
              writingCorrect: activeWord.writingCorrect,
              writingWrong: activeWord.writingWrong,
              writingLastCorrect: activeWord.writingLastCorrect,
            );
          })
          .toList(growable: false),
    );
  }

  Future<LearningBundle> _withAiContextsForWords(
    LearningBundle bundle,
    List<LearningWord> scopeWords,
  ) async {
    if (!_aiWordContextsEnabled ||
        !widget.featureAccessService.isEnabled(AppFeature.aiWordContexts) ||
        scopeWords.isEmpty) {
      return bundle;
    }

    try {
      final contextsByWordId = await widget.aiContextService.contextsForWords(
        scopeWords,
      );
      if (contextsByWordId.isEmpty) {
        return bundle;
      }

      final updatedBundle = _mergeGeneratedContexts(bundle, contextsByWordId);
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

  LearningBundle _mergeGeneratedContexts(
    LearningBundle bundle,
    Map<String, List<LearningContext>> contextsByWordId,
  ) {
    return bundle.copyWith(
      words: bundle.words
          .map((word) {
            final generatedContexts = contextsByWordId[word.wordId];
            if (generatedContexts == null || generatedContexts.isEmpty) {
              return word;
            }

            return word.copyWith(
              contexts: _mergeWordContexts(word.contexts, generatedContexts),
            );
          })
          .toList(growable: false),
    );
  }

  List<LearningContext> _mergeWordContexts(
    List<LearningContext> currentContexts,
    List<LearningContext> generatedContexts,
  ) {
    final seenContextIds = currentContexts
        .map((context) => context.contextId)
        .where((contextId) => contextId.trim().isNotEmpty)
        .toSet();
    final uniqueGeneratedContexts = generatedContexts
        .where((context) => seenContextIds.add(context.contextId))
        .toList(growable: false);

    if (uniqueGeneratedContexts.isEmpty) {
      return currentContexts;
    }

    return <LearningContext>[...uniqueGeneratedContexts, ...currentContexts];
  }

  Future<LearningWord> _resolveWordWithAiContext(LearningWord word) async {
    if (!_aiWordContextsEnabled ||
        !widget.featureAccessService.isEnabled(AppFeature.aiWordContexts)) {
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
        contexts: _mergeWordContexts(word.contexts, generatedContexts),
      );
      final activeBundle = _bundle;
      if (mounted && activeBundle != null) {
        final updatedBundle = _mergeGeneratedContexts(activeBundle, {
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

  List<LearningWord> _practiceScopeWords(
    LearningBundle bundle,
    FlashcardDeckMode mode,
  ) {
    final words = switch (mode) {
      FlashcardDeckMode.allWords => bundle.words,
      FlashcardDeckMode.withContexts => bundle.words,
      FlashcardDeckMode.needsReview =>
        bundle.words
            .where(
              (word) =>
                  classifyWordLearningState(word) ==
                  WordLearningState.needsReview,
            )
            .toList(growable: false),
    };

    return words
        .where(
          (word) => word.contexts.every((context) => !context.isAiGenerated),
        )
        .toList(growable: false);
  }

  void _handleWordProgressChanged(LearningWord updatedWord) {
    final activeBundle = _bundle;
    LearningWord? previousWord;
    int wordIndex = -1;

    if (activeBundle != null) {
      wordIndex = activeBundle.words.indexWhere(
        (word) => word.wordId == updatedWord.wordId,
      );
      if (wordIndex >= 0) {
        previousWord = activeBundle.words[wordIndex];
      }
      if (wordIndex >= 0) {
        final updatedWords = List<LearningWord>.from(activeBundle.words);
        updatedWords[wordIndex] = updatedWord;
        setState(() {
          _bundle = activeBundle.copyWith(words: updatedWords);
        });
      }
    }

    final requestToken = _nextPersistenceToken(
      _wordPersistenceTokens,
      updatedWord.wordId,
    );
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
      if (status == GuideLessonStatus.unread) {
        _guideLessonStatuses = <String, GuideLessonStatus>{
          for (final entry in _guideLessonStatuses.entries)
            if (entry.key != lessonKey) entry.key: entry.value,
        };
      } else {
        _guideLessonStatuses = <String, GuideLessonStatus>{
          ..._guideLessonStatuses,
          lessonKey: status,
        };
      }
    });

    final requestToken = _nextPersistenceToken(
      _guidePersistenceTokens,
      lessonKey,
    );
    return _persistGuideReadChange(
      lessonKey: lessonKey,
      status: status,
      previousStatuses: previousStatuses,
      requestToken: requestToken,
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
      if (status == GuideLessonStatus.unread) {
        _readingLessonStatuses = <String, GuideLessonStatus>{
          for (final entry in _readingLessonStatuses.entries)
            if (entry.key != lessonKey) entry.key: entry.value,
        };
      } else {
        _readingLessonStatuses = <String, GuideLessonStatus>{
          ..._readingLessonStatuses,
          lessonKey: status,
        };
      }
    });

    final requestToken = _nextPersistenceToken(
      _readingPersistenceTokens,
      lessonKey,
    );
    return _persistReadingStatusChange(
      lessonKey: lessonKey,
      status: status,
      previousStatuses: previousStatuses,
      requestToken: requestToken,
    );
  }

  void _selectArea(int index) {
    setState(() {
      _selectedArea = _RootArea.values[index];
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
        'Не вдалося завантажити контексти слів. Спробуйте ще раз.',
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
        _practiceScopeWords(bundle, mode),
      );
    } catch (error) {
      debugPrint('Failed to load word contexts for flashcards: $error');
      if (mounted) {
        _showPersistenceError(
          'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р°РІР°РЅС‚Р°Р¶РёС‚Рё РєРѕРЅС‚РµРєСЃС‚Рё СЃР»С–РІ. РЎРїСЂРѕР±СѓР№С‚Рµ С‰Рµ СЂР°Р·.',
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
        _practiceScopeWords(bundle, FlashcardDeckMode.needsReview),
      );
    } catch (error) {
      debugPrint('Failed to load word contexts for repetition: $error');
      if (mounted) {
        _showPersistenceError(
          'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р°РІР°РЅС‚Р°Р¶РёС‚Рё РєРѕРЅС‚РµРєСЃС‚Рё СЃР»С–РІ. РЎРїСЂРѕР±СѓР№С‚Рµ С‰Рµ СЂР°Р·.',
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

  // ignore: unused_element
  void _openMaterialsSection(_MaterialsSection section) {
    setState(() {
      _materialsSection = section;
      _selectedArea = _RootArea.materials;
      _isBottomNavVisible = true;
    });
  }

  void _openReadingLesson(LessonEntry lesson) {
    final lessonStatus =
        _readingLessonStatuses[lesson.progressKey] ?? GuideLessonStatus.unread;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReadingDetailScreen(
          lesson: lesson,
          documentLoader: widget.documentLoader,
          initialStatus: lessonStatus,
          onStatusChanged: (status) {
            _handleReadingStatusChanged(lesson.progressKey, status);
          },
        ),
      ),
    );
  }

  void _openMoreSection(_MoreSection section) {
    setState(() {
      _moreSection = section;
      _selectedArea = _RootArea.more;
      _isBottomNavVisible = true;
    });
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
    if (!_autoHideBottomNavOnScroll) {
      _setBottomNavVisibility(true);
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) {
      return false;
    }

    if (metrics.maxScrollExtent <= 0 || metrics.pixels <= 24) {
      _setBottomNavVisibility(true);
      return false;
    }

    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.forward) {
        _setBottomNavVisibility(true);
      } else if (direction == ScrollDirection.reverse && metrics.pixels > 72) {
        _setBottomNavVisibility(false);
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 4 && metrics.pixels > 72) {
        _setBottomNavVisibility(false);
      } else if (delta < -4) {
        _setBottomNavVisibility(true);
      }
    }

    return false;
  }

  void _setAutoHideBottomNavOnScroll(bool value) {
    setState(() {
      _autoHideBottomNavOnScroll = value;
      if (!value) {
        _isBottomNavVisible = true;
      }
    });
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

  void _setPreferWritingPractice(bool value) {
    setState(() {
      _preferWritingPractice = value;
    });
  }

  void _setPreferredFlashcardDeckMode(FlashcardDeckMode mode) {
    setState(() {
      _preferredFlashcardDeckMode = mode;
    });
  }

  int _nextPersistenceToken(Map<String, int> tokenMap, String key) {
    final nextToken = (tokenMap[key] ?? 0) + 1;
    tokenMap[key] = nextToken;
    return nextToken;
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
          _wordPersistenceTokens[updatedWord.wordId] != requestToken) {
        return;
      }

      final activeBundle = _bundle;
      if (activeBundle != null && previousWord != null) {
        final wordToRestore = previousWord;
        final restoreIndex = activeBundle.words.indexWhere(
          (word) => word.wordId == wordToRestore.wordId,
        );
        if (restoreIndex < 0) {
          return;
        }

        final restoredWords = List<LearningWord>.from(activeBundle.words);
        restoredWords[restoreIndex] = wordToRestore;
        setState(() {
          _bundle = activeBundle.copyWith(words: restoredWords);
        });
      }

      _showPersistenceError(
        'Не вдалося зберегти прогрес слова. Спробуйте ще раз.',
      );
    }
  }

  Future<bool> _persistGuideReadChange({
    required String lessonKey,
    required GuideLessonStatus status,
    required Map<String, GuideLessonStatus> previousStatuses,
    required int requestToken,
  }) async {
    try {
      await widget.progressRepository.setGuideLessonStatus(lessonKey, status);
      return true;
    } catch (error) {
      debugPrint('Failed to save guide progress for $lessonKey: $error');

      if (!mounted || _guidePersistenceTokens[lessonKey] != requestToken) {
        return false;
      }

      setState(() {
        _guideLessonStatuses = previousStatuses;
      });

      _showPersistenceError(
        'Не вдалося зберегти прогрес довідника. Спробуйте ще раз.',
      );
      return false;
    }
  }

  Future<bool> _persistReadingStatusChange({
    required String lessonKey,
    required GuideLessonStatus status,
    required Map<String, GuideLessonStatus> previousStatuses,
    required int requestToken,
  }) async {
    try {
      await widget.progressRepository.setReadingLessonStatus(lessonKey, status);
      return true;
    } catch (error) {
      debugPrint('Failed to save reading progress for $lessonKey: $error');

      if (!mounted || _readingPersistenceTokens[lessonKey] != requestToken) {
        return false;
      }

      setState(() {
        _readingLessonStatuses = previousStatuses;
      });

      _showPersistenceError(
        'Не вдалося зберегти прогрес читання. Спробуйте ще раз.',
      );
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
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${decision.title}: ${decision.description}'),
          action: SnackBarAction(
            label: decision.upgradeLabel,
            onPressed: () {},
          ),
        ),
      );
  }

  Widget _buildLearnWorkspace(LearningBundle bundle) {
    return WorkspaceHubScreen(
      title: 'Вчити',
      subtitle:
          'Оберіть підмодуль для вивчення. Після вибору він відкриється окремим повноекранним екраном.',
      shortcuts: [
        WorkspaceShortcut(
          title: 'Слова',
          subtitle:
              'Повний словник із пошуком, фільтрами й картками деталей. Доступно: ${bundle.words.length} слів.',
          icon: Icons.translate_rounded,
          accent: const Color(0xFF2B5D4F),
          onTap: _openLearnWords,
        ),
        WorkspaceShortcut(
          title: 'Дієслова',
          subtitle:
              'Добірка дієслівних уроків із поясненнями, озвученням і окремими екранами деталей. Доступно: ${bundle.verbLessons.length} уроків.',
          icon: Icons.play_lesson_rounded,
          accent: const Color(0xFF8C6A2A),
          onTap: _openLearnVerbs,
        ),
      ],
    );
  }

  Widget _buildPracticeWorkspace(LearningBundle bundle) {
    return WorkspaceHubScreen(
      title: 'Практика',
      subtitle:
          'Оберіть формат тренування і відкрийте його окремим повноекранним сеансом.',
      shortcuts: [
        WorkspaceShortcut(
          title: 'Картки',
          subtitle:
              'Швидке повторення перекладу, контексту і наборів на повторення.',
          icon: Icons.style_rounded,
          accent: const Color(0xFF0F766E),
          onTap: () => _openFlashcards(_preferredFlashcardDeckMode),
        ),
        WorkspaceShortcut(
          title: 'Написання',
          subtitle:
              'Введення слова івритом без підказки для активного пригадування.',
          icon: Icons.edit_rounded,
          accent: const Color(0xFF2B5D4F),
          onTap: () => _openWritingPractice(),
        ),
        WorkspaceShortcut(
          title: 'Конструктор',
          subtitle: 'Складання слова з блоків у правильному порядку.',
          icon: Icons.extension_rounded,
          accent: const Color(0xFFB45309),
          onTap: () => _openWritingPractice(WritingPracticeMode.constructor),
        ),
        WorkspaceShortcut(
          title: 'Повторення',
          subtitle:
              'Спокійний перегляд нових слів у вивченні та слів, де остання спроба була з помилкою.',
          icon: Icons.refresh_rounded,
          accent: const Color(0xFF8C6A2A),
          onTap: _openRepetition,
        ),
        WorkspaceShortcut(
          title: 'Спринт',
          subtitle:
              'Хвилинний режим на швидкість: для кожного слова є два варіанти перекладу.',
          icon: Icons.timer_rounded,
          accent: const Color(0xFFB91C1C),
          onTap: _openSprint,
        ),
      ],
    );
  }

  Widget _buildMaterialsWorkspace(LearningBundle bundle) {
    return _buildMaterialsHub(bundle);
  }

  Widget _buildMaterialsHub(LearningBundle bundle) {
    return WorkspaceHubScreen(
      title: 'Матеріали',
      subtitle:
          'Тут зібрані довідник і тексти для читання. Оберіть, з чого продовжити.',
      shortcuts: [
        WorkspaceShortcut(
          title: 'Довідник',
          subtitle:
              'Теми з поясненнями, пошуком і прогресом по матеріалах. Доступно: ${bundle.guideLessons.length} уроків.',
          icon: Icons.menu_book_rounded,
          accent: const Color(0xFF8C6A2A),
          onTap: _openGuide,
        ),
        WorkspaceShortcut(
          title: 'Читання',
          subtitle:
              'Тексти за рівнями складності з відмітками прочитаного. Доступно: ${bundle.readingLessons.length} уроків.',
          icon: Icons.auto_stories_rounded,
          accent: const Color(0xFF0F766E),
          onTap: _openReading,
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildMaterialsHeaderCard(LearningBundle bundle) {
    return WorkspaceHeaderCard(
      title: 'Матеріали',
      subtitle: 'Довідник і тексти для читання в одному робочому просторі.',
      sections: const [
        WorkspaceSection(label: 'Довідник', icon: Icons.menu_book_rounded),
        WorkspaceSection(label: 'Читання', icon: Icons.auto_stories_rounded),
      ],
      selectedIndex: _materialsSection.index,
      onSectionSelected: (index) {
        _openMaterialsSection(_MaterialsSection.values[index]);
      },
    );
  }

  Widget _buildMoreWorkspace(LearningBundle bundle) {
    final shortcuts = [
      WorkspaceShortcut(
        title: 'Головна',
        subtitle: 'Повернутися до dashboard з рекомендаціями і прогресом.',
        icon: Icons.home_rounded,
        accent: const Color(0xFF2B5D4F),
        onTap: () => _selectArea(_RootArea.home.index),
      ),
      WorkspaceShortcut(
        title: 'Вчити',
        subtitle: 'Слова й дієслова в одному робочому просторі.',
        icon: Icons.translate_rounded,
        accent: const Color(0xFF0F766E),
        onTap: () => _selectArea(_RootArea.learn.index),
      ),
      WorkspaceShortcut(
        title: 'Практика',
        subtitle: 'Картки й письмо для активного тренування.',
        icon: Icons.style_rounded,
        accent: const Color(0xFF8C3E9F),
        onTap: () {
          if (_preferWritingPractice) {
            _openWritingPractice();
          } else {
            _openFlashcards(_preferredFlashcardDeckMode);
          }
        },
      ),
      WorkspaceShortcut(
        title: 'Повторення',
        subtitle:
            'Перегляд нових слів у вивченні та останніх помилок без таймера.',
        icon: Icons.refresh_rounded,
        accent: const Color(0xFF8C6A2A),
        onTap: _openRepetition,
      ),
      WorkspaceShortcut(
        title: 'Спринт',
        subtitle:
            'Хвилинна вправа з вибором правильного перекладу між двома варіантами.',
        icon: Icons.timer_rounded,
        accent: const Color(0xFFB91C1C),
        onTap: _openSprint,
      ),
      WorkspaceShortcut(
        title: 'Матеріали',
        subtitle: 'Довідник і читання для теорії та контексту.',
        icon: Icons.menu_book_rounded,
        accent: const Color(0xFFB45309),
        onTap: () => _selectArea(_RootArea.materials.index),
      ),
    ];

    return WorkspaceScreen(
      title: 'Ще',
      subtitle:
          'Тут зібрані додаткові точки входу та оглядові екрани, які не варто тримати в root navigation.',
      sections: const [
        WorkspaceSection(
          label: 'Огляд',
          icon: Icons.dashboard_customize_rounded,
        ),
        WorkspaceSection(label: 'Прогрес', icon: Icons.insights_rounded),
        WorkspaceSection(label: 'Налаштування', icon: Icons.tune_rounded),
      ],
      selectedIndex: _moreSection.index,
      onSectionSelected: (index) {
        _openMoreSection(_MoreSection.values[index]);
      },
      child: IndexedStack(
        index: _moreSection.index,
        children: [
          MoreOverviewScreen(shortcuts: shortcuts),
          MoreProgressScreen(
            bundle: bundle,
            guideLessonStatuses: _guideLessonStatuses,
            readingLessonStatuses: _readingLessonStatuses,
            onOpenWords: _openLearnWords,
            onOpenFlashcards: _openFlashcards,
            onOpenWriting: () => _openWritingPractice(),
            onOpenSprint: _openSprint,
            onOpenGuide: _openGuide,
            onOpenReading: _openReading,
          ),
          MoreSettingsScreen(
            autoHideBottomNavOnScroll: _autoHideBottomNavOnScroll,
            onAutoHideBottomNavOnScrollChanged: _setAutoHideBottomNavOnScroll,
            aiWordContextsEnabled: _aiWordContextsEnabled,
            aiWordContextsAccess: widget.featureAccessService.accessFor(
              AppFeature.aiWordContexts,
            ),
            onAiWordContextsEnabledChanged: _setAiWordContextsEnabled,
            preferWritingPractice: _preferWritingPractice,
            onPreferWritingPracticeChanged: _setPreferWritingPractice,
            preferredFlashcardDeckMode: _preferredFlashcardDeckMode,
            onPreferredFlashcardDeckModeChanged: _setPreferredFlashcardDeckMode,
          ),
        ],
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
                          documentLoader: widget.documentLoader,
                          isDarkMode: widget.isDarkMode,
                          nightModeAccess: widget.featureAccessService
                              .accessFor(AppFeature.nightMode),
                          onToggleThemeMode: _handleThemeToggleRequested,
                          onOpenWords: _openLearnWords,
                          onOpenFlashcards: _openFlashcards,
                          onOpenWriting: () => _openWritingPractice(),
                          onOpenSprint: _openSprint,
                          onOpenGuide: _openGuide,
                          onOpenVerbs: _openLearnVerbs,
                          onOpenReading: _openReading,
                          onOpenReadingLesson: _openReadingLesson,
                        ),
                        _buildLearnWorkspace(bundle),
                        _buildPracticeWorkspace(bundle),
                        _buildMaterialsWorkspace(bundle),
                        _buildMoreWorkspace(bundle),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: _AppShellBottomNavigation(
                      isVisible: _isBottomNavVisible,
                      duration: _bottomNavAnimationDuration,
                      selectedIndex: _selectedArea.index,
                      onDestinationSelected: _selectArea,
                      onRevealRequested: () => _setBottomNavVisibility(true),
                    ),
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

class _AppShellBottomNavigation extends StatelessWidget {
  const _AppShellBottomNavigation({
    required this.isVisible,
    required this.duration,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onRevealRequested,
  });

  final bool isVisible;
  final Duration duration;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onRevealRequested;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isVisible
          ? _ExpandedBottomNavigationBar(
              key: const ValueKey('app-shell-bottom-nav'),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          : _CollapsedBottomNavigationHandle(
              key: const ValueKey('app-shell-nav-handle'),
              onTap: onRevealRequested,
            ),
    );
  }
}

class _ExpandedBottomNavigationBar extends StatelessWidget {
  const _ExpandedBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Головна',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school_rounded),
          label: 'Вчити',
        ),
        NavigationDestination(
          icon: Icon(Icons.bolt_outlined),
          selectedIcon: Icon(Icons.bolt_rounded),
          label: 'Практика',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books_rounded),
          label: 'Матеріали',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_horiz_rounded),
          label: 'Ще',
        ),
      ],
    );
  }
}

class _CollapsedBottomNavigationHandle extends StatelessWidget {
  const _CollapsedBottomNavigationHandle({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).appTokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tokens.navBarBackground,
        elevation: 8,
        shadowColor: tokens.shadowColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Завантажуємо навчальні матеріали...'),
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
                'Не вдалося завантажити навчальні матеріали.',
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
                child: const Text('Спробувати ще раз'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
