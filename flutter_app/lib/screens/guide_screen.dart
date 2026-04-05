import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import 'widgets/markdown_lesson_body.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({
    super.key,
    required this.lessons,
    required this.documentLoader,
    required this.lessonStatuses,
    required this.onStatusChanged,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;
  final Map<String, GuideLessonStatus> lessonStatuses;
  final void Function(String assetPath, GuideLessonStatus status)
  onStatusChanged;

  GuideLessonStatus _statusFor(String assetPath) {
    return lessonStatuses[assetPath] ?? GuideLessonStatus.unread;
  }

  @override
  Widget build(BuildContext context) {
    final readCount = lessons
        .where(
          (lesson) => _statusFor(lesson.assetPath) == GuideLessonStatus.read,
        )
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Довідник',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Короткі уроки з граматики та побудови фраз.',
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
              const Icon(Icons.menu_book_rounded, color: Color(0xFFB45309)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Прочитано $readCount із ${lessons.length} уроків',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...lessons.map((lesson) {
          final lessonStatus = _statusFor(lesson.assetPath);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GuideLessonCard(
              lesson: lesson,
              documentLoader: documentLoader,
              status: lessonStatus,
              onStatusSelected: (status) {
                onStatusChanged(lesson.assetPath, status);
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GuideDetailScreen(
                      lesson: lesson,
                      documentLoader: documentLoader,
                      initialStatus: lessonStatus,
                      onStatusChanged: (status) {
                        onStatusChanged(lesson.assetPath, status);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

GuideLessonStatus _nextGuideLessonStatus(GuideLessonStatus status) {
  switch (status) {
    case GuideLessonStatus.unread:
      return GuideLessonStatus.studying;
    case GuideLessonStatus.studying:
      return GuideLessonStatus.read;
    case GuideLessonStatus.read:
      return GuideLessonStatus.unread;
  }
}

class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({
    super.key,
    required this.lesson,
    required this.documentLoader,
    required this.initialStatus,
    required this.onStatusChanged,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final GuideLessonStatus initialStatus;
  final ValueChanged<GuideLessonStatus> onStatusChanged;

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late GuideLessonStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus == GuideLessonStatus.unread
        ? GuideLessonStatus.studying
        : widget.initialStatus;

    if (widget.initialStatus == GuideLessonStatus.unread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        widget.onStatusChanged(_status);
      });
    }
  }

  void _updateStatus(GuideLessonStatus status) {
    if (_status == status) {
      return;
    }

    setState(() {
      _status = status;
    });
    widget.onStatusChanged(status);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_status == GuideLessonStatus.read ||
        !_isAtBottom(notification.metrics)) {
      return false;
    }

    _updateStatus(GuideLessonStatus.read);
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
    final statusTheme = _GuideLessonStatusTheme.fromStatus(_status);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonDocument>(
        future: widget.documentLoader.load(widget.lesson.assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не вдалося відкрити цей урок.',
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
                      colors: [Color(0xFF8C6A2A), Color(0xFFB45309)],
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
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _GuideStatusToggleButton(
                        status: _status,
                        onPressed: () {
                          _updateStatus(_nextGuideLessonStatus(_status));
                        },
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      statusTheme.icon,
                      size: 18,
                      color: statusTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusTheme.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: statusTheme.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
    required this.documentLoader,
    required this.status,
    required this.onTap,
    required this.onStatusSelected,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final GuideLessonStatus status;
  final VoidCallback onTap;
  final ValueChanged<GuideLessonStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final statusTheme = _GuideLessonStatusTheme.fromStatus(status);
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
                  color: statusTheme.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: statusTheme.color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<LessonDocument>(
                      future: documentLoader.load(lesson.assetPath),
                      builder: (context, snapshot) {
                        final resolvedTitle =
                            snapshot.data?.title.trim().isNotEmpty == true
                            ? snapshot.data!.title.trim()
                            : titleLabel;

                        return Text(
                          resolvedTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          statusTheme.icon,
                          size: 18,
                          color: statusTheme.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusTheme.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: statusTheme.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _GuideStatusToggleButton(
                status: status,
                compact: true,
                onPressed: () {
                  onStatusSelected(_nextGuideLessonStatus(status));
                },
              ),
              const SizedBox(width: 4),
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

class _GuideStatusToggleButton extends StatelessWidget {
  const _GuideStatusToggleButton({
    required this.status,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.compact = false,
  });

  final GuideLessonStatus status;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final statusTheme = _GuideLessonStatusTheme.fromStatus(status);
    final resolvedForegroundColor = foregroundColor ?? statusTheme.color;

    return Tooltip(
      message: 'Змінити статус уроку',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Container(
            padding: compact
                ? const EdgeInsets.all(6)
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: compact
                ? Icon(
                    statusTheme.icon,
                    color: resolvedForegroundColor,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusTheme.icon,
                        color: resolvedForegroundColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusTheme.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: resolvedForegroundColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GuideLessonStatusTheme {
  const _GuideLessonStatusTheme({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  static _GuideLessonStatusTheme fromStatus(GuideLessonStatus status) {
    switch (status) {
      case GuideLessonStatus.unread:
        return const _GuideLessonStatusTheme(
          label: 'Не прочитано',
          icon: Icons.radio_button_unchecked_rounded,
          color: Color(0xFF8C6A2A),
        );
      case GuideLessonStatus.studying:
        return const _GuideLessonStatusTheme(
          label: 'Вивчається',
          icon: Icons.timelapse_rounded,
          color: Color(0xFF2563EB),
        );
      case GuideLessonStatus.read:
        return const _GuideLessonStatusTheme(
          label: 'Прочитано',
          icon: Icons.check_circle_rounded,
          color: Color(0xFF0F766E),
        );
    }
  }
}
