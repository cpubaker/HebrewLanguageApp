import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import 'widgets/markdown_lesson_body.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({
    super.key,
    required this.lessons,
    required this.documentLoader,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Reading',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reading lessons grouped by difficulty and synced from the desktop reading folders.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 12),
              Text(
                '${lessons.length} reading lessons available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReadingLessonCard(
              lesson: lesson,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReadingDetailScreen(
                      lesson: lesson,
                      documentLoader: documentLoader,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ReadingDetailScreen extends StatelessWidget {
  const ReadingDetailScreen({
    super.key,
    required this.lesson,
    required this.documentLoader,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;

  @override
  Widget build(BuildContext context) {
    final level = _readingLevelFromAssetPath(lesson.assetPath);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonDocument>(
        future: documentLoader.load(lesson.assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load this reading lesson.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final document = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E40AF),
                      Color(0xFF1D4ED8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        level,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MarkdownLessonBody(
                body: document.body,
                accentColor: const Color(0xFF1D4ED8),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadingLessonCard extends StatelessWidget {
  const _ReadingLessonCard({
    required this.lesson,
    required this.onTap,
  });

  final LessonEntry lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = _readingLevelFromAssetPath(lesson.assetPath);
    final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
    final orderLabel = orderMatch?.group(1) ?? '*';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D4ED8),
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5F5A52),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF1D4ED8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _readingLevelFromAssetPath(String assetPath) {
  final parts = assetPath.split('/');
  final readingIndex = parts.indexOf('reading');
  if (readingIndex == -1 || readingIndex + 1 >= parts.length) {
    return 'Reading';
  }

  final rawLevel = parts[readingIndex + 1];
  return rawLevel
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
