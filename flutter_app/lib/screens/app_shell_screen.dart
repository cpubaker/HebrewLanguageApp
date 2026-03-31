import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import '../services/guide_progress_store.dart';
import '../services/lesson_document_loader.dart';
import '../services/learning_bundle_loader.dart';
import '../services/verb_audio_player.dart';
import '../services/word_progress_store.dart';
import 'flashcards_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'reading_screen.dart';
import 'verbs_screen.dart';
import 'words_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.loader,
    required this.documentLoader,
    required this.progressStore,
    required this.guideProgressStore,
    required this.audioPlayerFactory,
  });

  final LearningBundleLoader loader;
  final LessonDocumentLoader documentLoader;
  final WordProgressStore progressStore;
  final GuideProgressStore guideProgressStore;
  final CreateVerbAudioPlayer audioPlayerFactory;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  late Future<LearningBundle> _bundleFuture;
  LearningBundle? _bundle;
  Set<String> _readGuideLessonPaths = <String>{};
  int _selectedIndex = 0;

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
    final readGuideLessonPaths = await widget.guideProgressStore.loadReadLessons();

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
            );
          })
          .toList(growable: false),
    );

    _readGuideLessonPaths = readGuideLessonPaths;
    _bundle = hydratedBundle;
    return hydratedBundle;
  }

  void _handleWordProgressChanged(LearningWord updatedWord) {
    final activeBundle = _bundle;
    if (activeBundle != null) {
      setState(() {
        _bundle = activeBundle.copyWith(
          words: activeBundle.words
              .map(
                (word) => word.wordId == updatedWord.wordId ? updatedWord : word,
              )
              .toList(growable: false),
        );
      });
    }

    unawaited(widget.progressStore.saveWord(updatedWord));
  }

  void _handleGuideReadChanged(String assetPath, bool isRead) {
    setState(() {
      if (isRead) {
        _readGuideLessonPaths = {
          ..._readGuideLessonPaths,
          assetPath,
        };
      } else {
        _readGuideLessonPaths = {
          for (final existingPath in _readGuideLessonPaths)
            if (existingPath != assetPath) existingPath,
        };
      }
    });

    unawaited(widget.guideProgressStore.setLessonRead(assetPath, isRead));
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            details: snapshot.error?.toString(),
          );
        }

        final bundle = _bundle ?? snapshot.requireData;
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeScreen(
                  bundle: bundle,
                  onOpenWords: () => _selectTab(1),
                  onOpenFlashcards: () => _selectTab(2),
                  onOpenGuide: () => _selectTab(3),
                  onOpenVerbs: () => _selectTab(4),
                  onOpenReading: () => _selectTab(5),
                ),
                WordsScreen(words: bundle.words),
                FlashcardsScreen(
                  words: bundle.words,
                  onWordProgressChanged: _handleWordProgressChanged,
                ),
                GuideScreen(
                  lessons: bundle.guideLessons,
                  documentLoader: widget.documentLoader,
                  readLessonPaths: _readGuideLessonPaths,
                  onReadChanged: _handleGuideReadChanged,
                ),
                VerbsScreen(
                  lessons: bundle.verbLessons,
                  documentLoader: widget.documentLoader,
                  audioPlayerFactory: widget.audioPlayerFactory,
                ),
                ReadingScreen(
                  lessons: bundle.readingLessons,
                  documentLoader: widget.documentLoader,
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.translate_outlined),
                selectedIcon: Icon(Icons.translate_rounded),
                label: 'Words',
              ),
              NavigationDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style_rounded),
                label: 'Cards',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Guide',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_lesson_outlined),
                selectedIcon: Icon(Icons.play_lesson_rounded),
                label: 'Verbs',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: 'Reading',
              ),
            ],
          ),
        );
      },
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
            Text('Loading shared learning content...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
    this.details,
  });

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
                'The Flutter client could not load the synced learning assets.',
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
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
