import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../services/learning_bundle_loader.dart';
import 'home_screen.dart';
import 'words_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    required this.loader,
  });

  final LearningBundleLoader loader;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  late Future<LearningBundle> _bundleFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _bundleFuture = widget.loader.load();
  }

  Future<void> _reload() async {
    setState(() {
      _bundleFuture = widget.loader.load();
    });
    await _bundleFuture;
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
          return _ErrorState(onRetry: _reload);
        }

        final bundle = snapshot.requireData;
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeScreen(
                  bundle: bundle,
                  onOpenWords: () => _selectTab(1),
                  onOpenLibrary: () => _selectTab(2),
                ),
                WordsScreen(words: bundle.words),
                _LibraryScreen(bundle: bundle),
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
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books_rounded),
                label: 'Library',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryScreen extends StatelessWidget {
  const _LibraryScreen({
    required this.bundle,
  });

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Library',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Next migration slices after Words: lesson browsing for guide, verbs, and reading content.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 20),
        _LibraryCard(
          title: 'Guide',
          subtitle: '${bundle.guideLessons.length} lessons ready for a list/detail flow.',
          accent: const Color(0xFFB45309),
          items: bundle.guideLessons.take(5).map((lesson) => lesson.displayName).toList(),
        ),
        const SizedBox(height: 16),
        _LibraryCard(
          title: 'Verbs',
          subtitle: '${bundle.verbLessons.length} lessons ready for text, image, and audio integration.',
          accent: const Color(0xFF7C3AED),
          items: bundle.verbLessons.take(5).map((lesson) => lesson.displayName).toList(),
        ),
        const SizedBox(height: 16),
        _LibraryCard(
          title: 'Reading',
          subtitle: '${bundle.readingLessons.length} lessons discovered from the shared reading folders.',
          accent: const Color(0xFF1D4ED8),
          items: bundle.readingLessons.take(5).map((lesson) => lesson.displayName).toList(),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.items,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  });

  final Future<void> Function() onRetry;

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
