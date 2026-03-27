import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import '../services/learning_bundle_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.loader,
  });

  final LearningBundleLoader loader;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<LearningBundle> _bundleFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LearningBundle>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _reload);
          }

          final bundle = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                _HeroPanel(bundle: bundle),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryCard(
                      label: 'Words',
                      value: bundle.words.length,
                      accent: const Color(0xFF0F766E),
                    ),
                    _SummaryCard(
                      label: 'Guide',
                      value: bundle.guideLessons.length,
                      accent: const Color(0xFFB45309),
                    ),
                    _SummaryCard(
                      label: 'Verbs',
                      value: bundle.verbLessons.length,
                      accent: const Color(0xFF7C3AED),
                    ),
                    _SummaryCard(
                      label: 'Reading',
                      value: bundle.readingLessons.length,
                      accent: const Color(0xFF1D4ED8),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Vocabulary Preview',
                  subtitle:
                      'First mobile slice powered by the same local data as Tkinter.',
                  child: Column(
                    children: bundle.words
                        .take(6)
                        .map((word) => _WordTile(word: word))
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Guide Roadmap',
                  subtitle: 'Markdown lessons discovered from synced assets.',
                  child: Column(
                    children: bundle.guideLessons
                        .take(5)
                        .map((lesson) => _LessonTile(lesson: lesson))
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Verb Lessons',
                  subtitle:
                      'Audio and image wiring will come after the basic learning flow.',
                  child: Column(
                    children: bundle.verbLessons
                        .take(5)
                        .map((lesson) => _LessonTile(lesson: lesson))
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.bundle,
  });

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF163832),
            Color(0xFF2B5D4F),
            Color(0xFF8C6A2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Android Migration',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hebrew Language App',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tkinter stays live on desktop while Flutter grows into the Android experience. This first slice already reads ${bundle.words.length} vocabulary entries from the shared dataset.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFF7F3E8),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
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
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.word,
  });

  final LearningWord word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3E8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.transcription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
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
                color: const Color(0xFF163832),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
  });

  final LessonEntry lesson;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEE2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF8C6A2A),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lesson.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('Loading shared learning content...'),
        ],
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
    return Center(
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
    );
  }
}
