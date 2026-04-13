import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import 'reading_lesson_catalog.dart';
import 'widgets/markdown_lesson_body.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({
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

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ScrollController _scrollController;

  final Map<String, String> _lessonTitles = <String, String>{};

  final Set<String> _selectedLevelKeys = <String>{};
  bool _isLoadingLessonTitles = false;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    unawaited(_primeLessonTitles());
  }

  @override
  void didUpdateWidget(covariant ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons != widget.lessons) {
      unawaited(_primeLessonTitles());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _primeLessonTitles() async {
    if (_isLoadingLessonTitles) {
      return;
    }

    final missingLessons = widget.lessons
        .where((lesson) => !_lessonTitles.containsKey(lesson.assetPath))
        .toList(growable: false);
    if (missingLessons.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingLessonTitles = true;
    });

    const batchSize = 24;

    try {
      for (
        var startIndex = 0;
        startIndex < missingLessons.length;
        startIndex += batchSize
      ) {
        final batch = missingLessons.skip(startIndex).take(batchSize);
        final resolvedTitles = await Future.wait(
          batch.map((lesson) async {
            try {
              final document = await widget.documentLoader.load(lesson.assetPath);
              final title = document.title.trim();
              return MapEntry<String, String?>(lesson.assetPath, title);
            } catch (_) {
              return MapEntry<String, String?>(lesson.assetPath, null);
            }
          }),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          for (final entry in resolvedTitles) {
            final title = entry.value;
            if (title != null && title.isNotEmpty) {
              _lessonTitles[entry.key] = title;
            }
          }
        });

        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLessonTitles = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final shouldShow = _scrollController.offset > 240;
    if (shouldShow == _showScrollToTop) {
      return;
    }

    setState(() {
      _showScrollToTop = shouldShow;
    });
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  String _resolvedLessonTitle(LessonEntry lesson) {
    final cachedTitle = _lessonTitles[lesson.assetPath];
    if (cachedTitle != null && cachedTitle.trim().isNotEmpty) {
      return cachedTitle.trim();
    }

    return readingLessonTitle(lesson);
  }

  bool _isLevelSelected(String levelKey) {
    return _selectedLevelKeys.contains(levelKey);
  }

  void _clearLevelFilter() {
    if (_selectedLevelKeys.isEmpty) {
      return;
    }

    setState(() {
      _selectedLevelKeys.clear();
    });
  }

  void _toggleLevelSelection(String levelKey) {
    setState(() {
      if (!_selectedLevelKeys.add(levelKey)) {
        _selectedLevelKeys.remove(levelKey);
      }
    });
  }

  GuideLessonStatus _statusFor(String assetPath) {
    return widget.lessonStatuses[assetPath] ?? GuideLessonStatus.unread;
  }

  @override
  Widget build(BuildContext context) {
    final lessonGroups = buildReadingLessonGroups(widget.lessons);
    final visibleGroups = _selectedLevelKeys.isEmpty
        ? lessonGroups
        : lessonGroups
              .where((group) => _selectedLevelKeys.contains(group.levelKey))
              .toList(growable: false);
    final visibleLessonCount = visibleGroups.fold<int>(
      0,
      (count, group) => count + group.lessons.length,
    );

    final itemCount = visibleGroups.length + 5;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                '\u0427\u0438\u0442\u0430\u043d\u043d\u044f',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              );
            }

            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '\u0422\u0435\u043a\u0441\u0442\u0438 \u0434\u043b\u044f \u0447\u0438\u0442\u0430\u043d\u043d\u044f, \u0440\u043e\u0437\u043a\u043b\u0430\u0434\u0435\u043d\u0456 \u0437\u0430 \u0440\u0456\u0432\u043d\u044f\u043c\u0438.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.4,
                  ),
                ),
              );
            }

            if (index == 2) {
              return const SizedBox(height: 18);
            }

            if (index == 3) {
              return Container(
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
                    const Icon(Icons.auto_stories_rounded, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLevelKeys.isEmpty
                                ? '\u0423\u0440\u043e\u043a\u0456\u0432: ${widget.lessons.length}'
                                : '\u041f\u043e\u043a\u0430\u0437\u0430\u043d\u043e: $visibleLessonCount',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u043d\u043e ${widget.lessons.where((lesson) => _statusFor(lesson.assetPath) == GuideLessonStatus.read).length} \u0456\u0437 ${widget.lessons.length}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF5F5A52),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (index == 4) {
              return const SizedBox(height: 18);
            }

            final group = visibleGroups[index - 5];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ReadingLevelSection(
                group: group,
                documentLoader: widget.documentLoader,
                statusFor: _statusFor,
                onStatusChanged: widget.onStatusChanged,
                titleResolver: _resolvedLessonTitle,
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                offset: _showScrollToTop ? Offset.zero : const Offset(0, 0.25),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showScrollToTop ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showScrollToTop,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton.small(
                        heroTag: 'readingScrollToTop',
                        onPressed: _scrollToTop,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4ED8),
                        child: const Icon(Icons.vertical_align_top_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton.small(
                heroTag: 'readingFilter',
                onPressed: () => _showLevelPicker(context, lessonGroups),
                tooltip: _selectedLevelKeys.isEmpty
                    ? 'Відкрити фільтр'
                    : 'Змінити фільтр',
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                child: Icon(
                  _selectedLevelKeys.isEmpty
                      ? Icons.tune_rounded
                      : Icons.filter_alt_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLevelPicker(
    BuildContext context,
    List<ReadingLessonGroup> lessonGroups,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Рівень читання',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Можна лишити весь каталог або вибрати один рівень.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                _ReadingLevelOption(
                  label: 'Усі рівні',
                  count: widget.lessons.length,
                  selected: _selectedLevelKeys.isEmpty,
                  onTap: () {
                    _clearLevelFilter();
                    bottomSheetSetState(() {});
                  },
                ),
                const SizedBox(height: 10),
                ...lessonGroups.expand(
                  (group) => [
                    _ReadingLevelOption(
                      label: group.levelLabel,
                      count: group.lessons.length,
                      selected: _isLevelSelected(group.levelKey),
                      onTap: () {
                        _toggleLevelSelection(group.levelKey);
                        bottomSheetSetState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}

GuideLessonStatus _nextReadingLessonStatus(GuideLessonStatus status) {
  switch (status) {
    case GuideLessonStatus.unread:
      return GuideLessonStatus.studying;
    case GuideLessonStatus.studying:
      return GuideLessonStatus.read;
    case GuideLessonStatus.read:
      return GuideLessonStatus.unread;
  }
}

class ReadingDetailScreen extends StatefulWidget {
  const ReadingDetailScreen({
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
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
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
    final level = readingLevelLabelFromAssetPath(widget.lesson.assetPath);
    final statusTheme = _ReadingLessonStatusTheme.fromStatus(_status);

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
                      colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              document.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ReadingStatusToggleButton(
                        status: _status,
                        onPressed: () {
                          _updateStatus(_nextReadingLessonStatus(_status));
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
                  accentColor: const Color(0xFF1D4ED8),
                  inlineGlossary: document.glossary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReadingLessonCard extends StatelessWidget {
  const _ReadingLessonCard({
    required this.lesson,
    required this.resolvedTitle,
    required this.status,
    required this.onStatusSelected,
    required this.onTap,
  });

  final LessonEntry lesson;
  final String resolvedTitle;
  final GuideLessonStatus status;
  final ValueChanged<GuideLessonStatus> onStatusSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final orderLabel = readingLessonOrderLabel(lesson);
    final statusTheme = _ReadingLessonStatusTheme.fromStatus(status);

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
                    Text(
                      resolvedTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                        Text(
                          level,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6C665D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ReadingStatusToggleButton(
                status: status,
                compact: true,
                onPressed: () {
                  onStatusSelected(_nextReadingLessonStatus(status));
                },
              ),
              const SizedBox(width: 4),
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

class _ReadingLevelSection extends StatelessWidget {
  const _ReadingLevelSection({
    required this.group,
    required this.documentLoader,
    required this.statusFor,
    required this.onStatusChanged,
    required this.titleResolver,
  });

  final ReadingLessonGroup group;
  final LessonDocumentLoader documentLoader;
  final GuideLessonStatus Function(String assetPath) statusFor;
  final void Function(String assetPath, GuideLessonStatus status) onStatusChanged;
  final String Function(LessonEntry lesson) titleResolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                group.levelLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 10),
              Text(
                '${group.lessons.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                ),
              ),
            ],
          ),
        ),
        ...group.lessons.map(
          (lesson) {
            final lessonStatus = statusFor(lesson.assetPath);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReadingLessonCard(
                lesson: lesson,
                resolvedTitle: titleResolver(lesson),
                status: lessonStatus,
                onStatusSelected: (status) {
                  onStatusChanged(lesson.assetPath, status);
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReadingDetailScreen(
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
          },
        ),
      ],
    );
  }
}

class _ReadingStatusToggleButton extends StatelessWidget {
  const _ReadingStatusToggleButton({
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
    final statusTheme = _ReadingLessonStatusTheme.fromStatus(status);
    final resolvedForegroundColor = foregroundColor ?? statusTheme.color;

    return Tooltip(
      message: '\u0417\u043c\u0456\u043d\u0438\u0442\u0438 \u0441\u0442\u0430\u0442\u0443\u0441 \u0443\u0440\u043e\u043a\u0443',
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

class ReadingLevelSelector extends StatelessWidget {
  const ReadingLevelSelector({
    super.key,
    required this.selectedLabel,
    required this.selectedCount,
    required this.onTap,
  });

  final String selectedLabel;
  final int selectedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рівень',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF6C665D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$selectedLabel ($selectedCount)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF1D4ED8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingLessonStatusTheme {
  const _ReadingLessonStatusTheme({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  static _ReadingLessonStatusTheme fromStatus(GuideLessonStatus status) {
    switch (status) {
      case GuideLessonStatus.unread:
        return const _ReadingLessonStatusTheme(
          label: '\u041d\u0435 \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u043d\u043e',
          icon: Icons.radio_button_unchecked_rounded,
          color: Color(0xFF8C6A2A),
        );
      case GuideLessonStatus.studying:
        return const _ReadingLessonStatusTheme(
          label: '\u0412\u0438\u0432\u0447\u0430\u0454\u0442\u044c\u0441\u044f',
          icon: Icons.timelapse_rounded,
          color: Color(0xFF2563EB),
        );
      case GuideLessonStatus.read:
        return const _ReadingLessonStatusTheme(
          label: '\u041f\u0440\u043e\u0447\u0438\u0442\u0430\u043d\u043e',
          icon: Icons.check_circle_rounded,
          color: Color(0xFF0F766E),
        );
    }
  }
}

class _ReadingLevelOption extends StatelessWidget {
  const _ReadingLevelOption({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1D4ED8).withValues(alpha: 0.08)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1D4ED8).withValues(alpha: 0.30)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count уроків',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F5A52),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
