import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import '../services/guide_progress_store.dart';
import '../services/flashcard_session.dart';
import '../services/lesson_document_loader.dart';
import '../services/learning_bundle_loader.dart';
import '../services/reading_progress_store.dart';
import '../services/verb_audio_player.dart';
import '../services/word_progress_store.dart';
import 'flashcards_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'reading_screen.dart';
import 'verbs_screen.dart';
import 'writing_screen.dart';
import 'words_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.loader,
    required this.documentLoader,
    required this.progressStore,
    required this.guideProgressStore,
    required this.readingProgressStore,
    required this.audioPlayerFactory,
  });

  final LearningBundleLoader loader;
  final LessonDocumentLoader documentLoader;
  final WordProgressStore progressStore;
  final GuideProgressStore guideProgressStore;
  final ReadingProgressStore readingProgressStore;
  final CreateVerbAudioPlayer audioPlayerFactory;

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
  LearningBundle? _bundle;
  Map<String, GuideLessonStatus> _guideLessonStatuses =
      <String, GuideLessonStatus>{};
  Map<String, GuideLessonStatus> _readingLessonStatuses =
      <String, GuideLessonStatus>{};
  final Map<String, int> _guidePersistenceTokens = <String, int>{};
  final Map<String, int> _readingPersistenceTokens = <String, int>{};
  final Map<String, int> _wordPersistenceTokens = <String, int>{};
  FlashcardDeckMode _flashcardDeckMode = FlashcardDeckMode.allWords;
  int _flashcardDeckRequestToken = 0;
  int _selectedIndex = 0;
  bool _isBottomNavVisible = true;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
  }

  Future<void> _reload() async {
    setState(() {
      _bundle = null;
      _bundleFuture = _loadBundle();
    });
    await _bundleFuture;
  }

  Future<LearningBundle> _loadBundle() async {
    final bundle = await widget.loader.load();
    final storedProgress = await widget.progressStore.load();
    final guideLessonStatuses = await widget.guideProgressStore
        .loadLessonStatuses();
    final readingLessonStatuses = await widget.readingProgressStore
        .loadLessonStatuses();

    final hydratedBundle = bundle.copyWith(
      words: bundle.words
          .map((word) {
            final progress = storedProgress[word.wordId];
            if (progress == null) {
              return word;
            }

            return word.copyWith(
              correct: progress.correct,
              wrong: progress.wrong,
              lastCorrect: progress.lastCorrect,
              writingCorrect: progress.writingCorrect,
              writingWrong: progress.writingWrong,
              writingLastCorrect: progress.writingLastCorrect,
            );
          })
          .toList(growable: false),
    );

    _guideLessonStatuses = guideLessonStatuses;
    _readingLessonStatuses = readingLessonStatuses;
    _bundle = hydratedBundle;
    return hydratedBundle;
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

  void _handleGuideStatusChanged(String assetPath, GuideLessonStatus status) {
    final previousStatuses = Map<String, GuideLessonStatus>.from(
      _guideLessonStatuses,
    );
    setState(() {
      if (status == GuideLessonStatus.unread) {
        _guideLessonStatuses = <String, GuideLessonStatus>{
          for (final entry in _guideLessonStatuses.entries)
            if (entry.key != assetPath) entry.key: entry.value,
        };
      } else {
        _guideLessonStatuses = <String, GuideLessonStatus>{
          ..._guideLessonStatuses,
          assetPath: status,
        };
      }
    });

    final requestToken = _nextPersistenceToken(
      _guidePersistenceTokens,
      assetPath,
    );
    unawaited(
      _persistGuideReadChange(
        assetPath: assetPath,
        status: status,
        previousStatuses: previousStatuses,
        requestToken: requestToken,
      ),
    );
  }

  void _handleReadingStatusChanged(String assetPath, GuideLessonStatus status) {
    final previousStatuses = Map<String, GuideLessonStatus>.from(
      _readingLessonStatuses,
    );
    setState(() {
      if (status == GuideLessonStatus.unread) {
        _readingLessonStatuses = <String, GuideLessonStatus>{
          for (final entry in _readingLessonStatuses.entries)
            if (entry.key != assetPath) entry.key: entry.value,
        };
      } else {
        _readingLessonStatuses = <String, GuideLessonStatus>{
          ..._readingLessonStatuses,
          assetPath: status,
        };
      }
    });

    final requestToken = _nextPersistenceToken(
      _readingPersistenceTokens,
      assetPath,
    );
    unawaited(
      _persistReadingStatusChange(
        assetPath: assetPath,
        status: status,
        previousStatuses: previousStatuses,
        requestToken: requestToken,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _isBottomNavVisible = true;
    });
  }

  void _openFlashcards([FlashcardDeckMode mode = FlashcardDeckMode.allWords]) {
    setState(() {
      _flashcardDeckMode = mode;
      _flashcardDeckRequestToken += 1;
      _selectedIndex = 2;
      _isBottomNavVisible = true;
    });
  }

  void _setBottomNavVisibility(bool isVisible) {
    if (_isBottomNavVisible == isVisible || !mounted) {
      return;
    }

    setState(() {
      _isBottomNavVisible = isVisible;
    });
  }

  bool _handleShellScrollNotification(ScrollNotification notification) {
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
      } else if (direction == ScrollDirection.reverse &&
          metrics.pixels > 72) {
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
      await widget.progressStore.saveWord(updatedWord);
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

  Future<void> _persistGuideReadChange({
    required String assetPath,
    required GuideLessonStatus status,
    required Map<String, GuideLessonStatus> previousStatuses,
    required int requestToken,
  }) async {
    try {
      await widget.guideProgressStore.setLessonStatus(assetPath, status);
    } catch (error) {
      debugPrint('Failed to save guide progress for $assetPath: $error');

      if (!mounted || _guidePersistenceTokens[assetPath] != requestToken) {
        return;
      }

      setState(() {
        _guideLessonStatuses = previousStatuses;
      });

      _showPersistenceError(
        'Не вдалося зберегти прогрес довідника. Спробуйте ще раз.',
      );
    }
  }

  Future<void> _persistReadingStatusChange({
    required String assetPath,
    required GuideLessonStatus status,
    required Map<String, GuideLessonStatus> previousStatuses,
    required int requestToken,
  }) async {
    try {
      await widget.readingProgressStore.setLessonStatus(assetPath, status);
    } catch (error) {
      debugPrint('Failed to save reading progress for $assetPath: $error');

      if (!mounted || _readingPersistenceTokens[assetPath] != requestToken) {
        return;
      }

      setState(() {
        _readingLessonStatuses = previousStatuses;
      });

      _showPersistenceError(
        'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р±РµСЂРµРіС‚Рё РїСЂРѕРіСЂРµСЃ С‡РёС‚Р°РЅРЅСЏ. РЎРїСЂРѕР±СѓР№С‚Рµ С‰Рµ СЂР°Р·.',
      );
    }
  }

  void _showPersistenceError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                      index: _selectedIndex,
                      children: [
                        HomeScreen(
                          bundle: bundle,
                          documentLoader: widget.documentLoader,
                          onOpenWords: () => _selectTab(1),
                          onOpenFlashcards: _openFlashcards,
                          onOpenWriting: () => _selectTab(3),
                          onOpenGuide: () => _selectTab(4),
                          onOpenVerbs: () => _selectTab(5),
                          onOpenReading: () => _selectTab(6),
                        ),
                        WordsScreen(
                          words: bundle.words,
                          audioPlayerFactory: widget.audioPlayerFactory,
                        ),
                        FlashcardsScreen(
                          words: bundle.words,
                          onWordProgressChanged: _handleWordProgressChanged,
                          initialDeckMode: _flashcardDeckMode,
                          deckRequestToken: _flashcardDeckRequestToken,
                        ),
                        WritingScreen(
                          words: bundle.words,
                          onWordProgressChanged: _handleWordProgressChanged,
                        ),
                        GuideScreen(
                          lessons: bundle.guideLessons,
                          documentLoader: widget.documentLoader,
                          lessonStatuses: _guideLessonStatuses,
                          onStatusChanged: _handleGuideStatusChanged,
                        ),
                        VerbsScreen(
                          lessons: bundle.verbLessons,
                          documentLoader: widget.documentLoader,
                          audioPlayerFactory: widget.audioPlayerFactory,
                        ),
                        ReadingScreen(
                          lessons: bundle.readingLessons,
                          documentLoader: widget.documentLoader,
                          lessonStatuses: _readingLessonStatuses,
                          onStatusChanged: _handleReadingStatusChanged,
                        ),
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
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _selectTab,
                      onRevealRequested: () => _setBottomNavVisibility(true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Головна',
              ),
              NavigationDestination(
                icon: Icon(Icons.translate_outlined),
                selectedIcon: Icon(Icons.translate_rounded),
                label: 'Слова',
              ),
              NavigationDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style_rounded),
                label: 'Картки',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit_outlined),
                selectedIcon: Icon(Icons.edit_rounded),
                label: 'Письмо',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Довідник',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_lesson_outlined),
                selectedIcon: Icon(Icons.play_lesson_rounded),
                label: 'Дієслова',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: 'Читання',
              ),
            ],
          ),
          */
        );
      },
    );
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
            position:
                Tween<Offset>(
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
          icon: Icon(Icons.translate_outlined),
          selectedIcon: Icon(Icons.translate_rounded),
          label: 'Слова',
        ),
        NavigationDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style_rounded),
          label: 'Картки',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(Icons.edit_rounded),
          label: 'Письмо',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Довідник',
        ),
        NavigationDestination(
          icon: Icon(Icons.play_lesson_outlined),
          selectedIcon: Icon(Icons.play_lesson_rounded),
          label: 'Дієслова',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories_rounded),
          label: 'Читання',
        ),
      ],
    );
  }
}

class _CollapsedBottomNavigationHandle extends StatelessWidget {
  const _CollapsedBottomNavigationHandle({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF8F3E8),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.14),
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
