import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import 'widgets/markdown_lesson_body.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({
    super.key,
    required this.lessons,
    required this.documentLoader,
    required this.readLessonPaths,
    required this.onReadChanged,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;
  final Set<String> readLessonPaths;
  final void Function(String assetPath, bool isRead) onReadChanged;

  @override
  Widget build(BuildContext context) {
    final readCount = lessons
        .where((lesson) => readLessonPaths.contains(lesson.assetPath))
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Guide',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Grammar and structure lessons synced from the desktop guide folder.',
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
              color: const Color(0xFFB45309).withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$readCount of ${lessons.length} guide lessons marked read',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GuideLessonCard(
              lesson: lesson,
              isRead: readLessonPaths.contains(lesson.assetPath),
              onToggleRead: () {
                final isRead = readLessonPaths.contains(lesson.assetPath);
                onReadChanged(lesson.assetPath, !isRead);
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GuideDetailScreen(
                      lesson: lesson,
                      documentLoader: documentLoader,
                      isRead: readLessonPaths.contains(lesson.assetPath),
                      onReadChanged: (isRead) {
                        onReadChanged(lesson.assetPath, isRead);
                      },
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

class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({
    super.key,
    required this.lesson,
    required this.documentLoader,
    required this.isRead,
    required this.onReadChanged,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final bool isRead;
  final ValueChanged<bool> onReadChanged;

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  bool _hasMarkedReadFromScroll = false;

  bool get _isRead => widget.isRead || _hasMarkedReadFromScroll;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_hasMarkedReadFromScroll || !_isAtBottom(notification.metrics)) {
      return false;
    }

    setState(() {
      _hasMarkedReadFromScroll = true;
    });
    widget.onReadChanged(true);
    return false;
  }

  bool _isAtBottom(ScrollMetrics metrics) {
    if (metrics.maxScrollExtent <= 0) {
      return false;
    }

    return metrics.pixels >= metrics.maxScrollExtent - 24;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonDocument>(
        future: widget.documentLoader.load(widget.lesson.assetPath),
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
                  'Could not load this guide lesson.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final document = snapshot.requireData;
          return NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8C6A2A),
                        Color(0xFFB45309),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          _isRead ? 'Read' : 'Reading',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MarkdownLessonBody(
                  body: document.body,
                  accentColor: const Color(0xFF8C6A2A),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuideLessonCard extends StatelessWidget {
  const _GuideLessonCard({
    required this.lesson,
    required this.isRead,
    required this.onTap,
    required this.onToggleRead,
  });

  final LessonEntry lesson;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
    final orderLabel = orderMatch?.group(1) ?? '*';
    final titleLabel = lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '');

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
                  color: isRead
                      ? const Color(0xFF0F766E).withValues(alpha: 0.14)
                      : const Color(0xFFB45309).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color:
                            isRead ? const Color(0xFF0F766E) : const Color(0xFF8C6A2A),
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRead ? 'Read' : 'Unread',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isRead
                                ? const Color(0xFF0F766E)
                                : const Color(0xFF6C665D),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isRead ? 'Mark as unread' : 'Mark as read',
                onPressed: onToggleRead,
                icon: Icon(
                  isRead
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isRead ? const Color(0xFF0F766E) : const Color(0xFF8C6A2A),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF8C6A2A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
