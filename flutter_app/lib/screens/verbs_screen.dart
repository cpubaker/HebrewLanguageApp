import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';

class VerbsScreen extends StatelessWidget {
  const VerbsScreen({
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
          'Verbs',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Core verb lessons synced from the desktop content, ready for list/detail study on mobile.',
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
              color: const Color(0xFF7C3AED).withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.play_lesson_rounded,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 12),
              Text(
                '${lessons.length} verb lessons available',
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
            child: _VerbLessonCard(
              lesson: lesson,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerbDetailScreen(
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

class VerbDetailScreen extends StatelessWidget {
  const VerbDetailScreen({
    super.key,
    required this.lesson,
    required this.documentLoader,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;

  @override
  Widget build(BuildContext context) {
    final media = _VerbMediaPaths.fromLesson(lesson);

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
                  'Could not load this verb lesson.',
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
                      Color(0xFF5B21B6),
                      Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  document.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              _VerbImageCard(imageAssetPath: media.imageAssetPath),
              const SizedBox(height: 18),
              _VerbSupportCard(audioAssetPath: media.audioAssetPath),
              const SizedBox(height: 18),
              _VerbLessonBody(body: document.body),
            ],
          );
        },
      ),
    );
  }
}

class _VerbLessonCard extends StatelessWidget {
  const _VerbLessonCard({
    required this.lesson,
    required this.onTap,
  });

  final LessonEntry lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  lesson.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF7C3AED),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerbImageCard extends StatelessWidget {
  const _VerbImageCard({
    required this.imageAssetPath,
  });

  final String imageAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.asset(
          imageAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF2EBDD),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported_outlined,
                    size: 36,
                    color: Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No synced illustration for this verb yet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerbSupportCard extends StatelessWidget {
  const _VerbSupportCard({
    required this.audioAssetPath,
  });

  final String audioAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_up_rounded,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio wiring is the next media step.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prepared asset path: $audioAssetPath',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F5A52),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerbLessonBody extends StatelessWidget {
  const _VerbLessonBody({
    required this.body,
  });

  final String body;

  @override
  Widget build(BuildContext context) {
    final lines = body.split('\n');
    final children = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 12));
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line.trim());
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final title = headingMatch.group(2)!.trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: _headingStyleForLevel(context, level),
            ),
          ),
        );
        continue;
      }

      if (line.trimLeft().startsWith('- ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    line.trimLeft().substring(2).trim(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SelectableText(
            line.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  TextStyle? _headingStyleForLevel(BuildContext context, int level) {
    if (level <= 2) {
      return Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          );
    }

    return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
  }
}

class _VerbMediaPaths {
  const _VerbMediaPaths({
    required this.imageAssetPath,
    required this.audioAssetPath,
  });

  final String imageAssetPath;
  final String audioAssetPath;

  factory _VerbMediaPaths.fromLesson(LessonEntry lesson) {
    final filename = lesson.assetPath.split('/').last;
    final lessonStem = filename.replaceFirst(RegExp(r'\.md$'), '');
    final assetStem = lessonStem.replaceFirst(RegExp(r'^\d+[_-]*'), '');

    return _VerbMediaPaths(
      imageAssetPath: 'assets/learning/input/images/verbs/$assetStem.png',
      audioAssetPath: 'assets/learning/input/audio/verbs/$assetStem.mp3',
    );
  }
}
