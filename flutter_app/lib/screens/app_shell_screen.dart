import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/guide_progress_store.dart';
import '../services/learning_bundle_loader.dart';
import '../services/lesson_document_loader.dart';
import '../services/reading_progress_store.dart';
import '../services/verb_audio_player.dart';
import '../services/word_progress_store.dart';
import 'flashcards_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'reading_screen.dart';
import 'verbs_screen.dart';
import 'workspace_screen.dart';
import 'words_screen.dart';
import 'writing_screen.dart';

enum _RootArea { home, learn, practice, materials, more }

enum _LearnSection { words, verbs }

enum _PracticeSection { flashcards, writing }

enum _MaterialsSection { guide, reading }

enum _MoreSection { overview, progress, settings }

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
  _RootArea _selectedArea = _RootArea.home;
  _LearnSection _learnSection = _LearnSection.words;
  _PracticeSection _practiceSection = _PracticeSection.flashcards;
  _MaterialsSection _materialsSection = _MaterialsSection.guide;
  _MoreSection _moreSection = _MoreSection.overview;
  bool _autoHideBottomNavOnScroll = true;
  bool _preferWritingPractice = false;
  FlashcardDeckMode _preferredFlashcardDeckMode = FlashcardDeckMode.allWords;
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

  void _selectArea(int index) {
    setState(() {
      _selectedArea = _RootArea.values[index];
      _isBottomNavVisible = true;
    });
  }

  void _openLearnSection(_LearnSection section) {
    setState(() {
      _learnSection = section;
      _selectedArea = _RootArea.learn;
      _isBottomNavVisible = true;
    });
  }

  void _openPracticeSection(_PracticeSection section) {
    setState(() {
      _practiceSection = section;
      _selectedArea = _RootArea.practice;
      _isBottomNavVisible = true;
    });
  }

  void _openFlashcards([FlashcardDeckMode mode = FlashcardDeckMode.allWords]) {
    setState(() {
      _flashcardDeckMode = mode;
      _flashcardDeckRequestToken += 1;
      _practiceSection = _PracticeSection.flashcards;
      _selectedArea = _RootArea.practice;
      _isBottomNavVisible = true;
    });
  }

  void _openMaterialsSection(_MaterialsSection section) {
    setState(() {
      _materialsSection = section;
      _selectedArea = _RootArea.materials;
      _isBottomNavVisible = true;
    });
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
        'Не вдалося зберегти прогрес читання. Спробуйте ще раз.',
      );
    }
  }

  void _showPersistenceError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildLearnWorkspace(LearningBundle bundle) {
    return WorkspaceScreen(
      title: 'Вчити',
      subtitle: 'Основні навчальні модулі: слова та дієслова.',
      sections: const [
        WorkspaceSection(label: 'Слова', icon: Icons.translate_rounded),
        WorkspaceSection(label: 'Дієслова', icon: Icons.play_lesson_rounded),
      ],
      selectedIndex: _learnSection.index,
      onSectionSelected: (index) {
        _openLearnSection(_LearnSection.values[index]);
      },
      child: IndexedStack(
        index: _learnSection.index,
        children: [
          WordsScreen(
            words: bundle.words,
            audioPlayerFactory: widget.audioPlayerFactory,
          ),
          VerbsScreen(
            lessons: bundle.verbLessons,
            documentLoader: widget.documentLoader,
            audioPlayerFactory: widget.audioPlayerFactory,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeWorkspace(LearningBundle bundle) {
    return WorkspaceScreen(
      title: 'Практика',
      subtitle: 'Картки та письмо для повторення й активного пригадування.',
      sections: const [
        WorkspaceSection(label: 'Картки', icon: Icons.style_rounded),
        WorkspaceSection(label: 'Письмо', icon: Icons.edit_rounded),
      ],
      selectedIndex: _practiceSection.index,
      onSectionSelected: (index) {
        _openPracticeSection(_PracticeSection.values[index]);
      },
      child: IndexedStack(
        index: _practiceSection.index,
        children: [
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
        ],
      ),
    );
  }

  Widget _buildMaterialsWorkspace(LearningBundle bundle) {
    return WorkspaceScreen(
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
      child: IndexedStack(
        index: _materialsSection.index,
        children: [
          GuideScreen(
            lessons: bundle.guideLessons,
            documentLoader: widget.documentLoader,
            lessonStatuses: _guideLessonStatuses,
            onStatusChanged: _handleGuideStatusChanged,
          ),
          ReadingScreen(
            lessons: bundle.readingLessons,
            documentLoader: widget.documentLoader,
            lessonStatuses: _readingLessonStatuses,
            onStatusChanged: _handleReadingStatusChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreWorkspace(LearningBundle bundle) {
    final shortcuts = [
      WorkspaceShortcut(
        title: 'Головна',
        subtitle:
            'Повернутися до dashboard з рекомендаціями і прогресом.',
        icon: Icons.home_rounded,
        accent: const Color(0xFF2B5D4F),
        onTap: () => _selectArea(_RootArea.home.index),
      ),
      WorkspaceShortcut(
        title: 'Вчити',
        subtitle:
            'Слова й дієслова в одному робочому просторі.',
        icon: Icons.translate_rounded,
        accent: const Color(0xFF0F766E),
        onTap: () => _selectArea(_RootArea.learn.index),
      ),
      WorkspaceShortcut(
        title: 'Практика',
        subtitle:
            'Картки й письмо для активного тренування.',
        icon: Icons.style_rounded,
        accent: const Color(0xFF8C3E9F),
        onTap: () {
          if (_preferWritingPractice) {
            _openPracticeSection(_PracticeSection.writing);
          } else {
            _openFlashcards(_preferredFlashcardDeckMode);
          }
        },
      ),
      WorkspaceShortcut(
        title: 'Матеріали',
        subtitle:
            'Довідник і читання для теорії та контексту.',
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
        WorkspaceSection(
          label: 'Налаштування',
          icon: Icons.tune_rounded,
        ),
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
            onOpenWords: () => _openLearnSection(_LearnSection.words),
            onOpenFlashcards: _openFlashcards,
            onOpenWriting: () => _openPracticeSection(_PracticeSection.writing),
            onOpenGuide: () => _openMaterialsSection(_MaterialsSection.guide),
            onOpenReading: () =>
                _openMaterialsSection(_MaterialsSection.reading),
          ),
          MoreSettingsScreen(
            autoHideBottomNavOnScroll: _autoHideBottomNavOnScroll,
            onAutoHideBottomNavOnScrollChanged: _setAutoHideBottomNavOnScroll,
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
                          onOpenWords: () =>
                              _openLearnSection(_LearnSection.words),
                          onOpenFlashcards: _openFlashcards,
                          onOpenWriting: () =>
                              _openPracticeSection(_PracticeSection.writing),
                          onOpenGuide: () =>
                              _openMaterialsSection(_MaterialsSection.guide),
                          onOpenVerbs: () =>
                              _openLearnSection(_LearnSection.verbs),
                          onOpenReading: () =>
                              _openMaterialsSection(_MaterialsSection.reading),
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
