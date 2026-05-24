import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'mixins/lesson_scroll_mixin.dart';
import 'mixins/lesson_status_handler_mixin.dart';
import 'reading_lesson_catalog.dart';
import 'widgets/lesson_status_controls.dart';
import 'widgets/markdown_lesson_body.dart';
import 'widgets/reading/reading_empty_search_state.dart';
import 'widgets/reading/reading_search_card.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({
    super.key,
    required this.lessons,
    required this.documentLoader,
    required this.lessonStatuses,
    required this.onStatusChanged,
    this.topContent,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;
  final Map<String, GuideLessonStatus> lessonStatuses;
  final LessonStatusChangeHandler onStatusChanged;
  final Widget? topContent;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with
        LessonScrollMixin<ReadingScreen>,
        LessonStatusHandlerMixin<ReadingScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  final Map<String, String> _lessonTitles = <String, String>{};

  final Set<String> _selectedLevelKeys = <String>{};
  String _query = '';
  bool _searchVisible = false;
  bool _isLoadingLessonTitles = false;

  @override
  Map<String, GuideLessonStatus> get widgetLessonStatuses =>
      widget.lessonStatuses;

  @override
  LessonStatusChangeHandler get widgetOnStatusChanged => widget.onStatusChanged;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    unawaited(_primeLessonTitles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons != widget.lessons) {
      unawaited(_primeLessonTitles());
    }
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
              final document = await widget.documentLoader.load(
                lesson.assetPath,
              );
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

  void _toggleSearchVisibility() {
    setState(() {
      if (_searchVisible) {
        _searchVisible = false;
        if (_query.trim().isEmpty) {
          _searchFocusNode.unfocus();
        }
      } else {
        _searchVisible = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final accentForeground = tokens.heroText;
    final progress = LessonProgressSnapshot.fromLessons(
      lessons: widget.lessons,
      lessonStatuses: widget.lessonStatuses,
    );
    final lessonGroups = buildReadingLessonGroups(widget.lessons);
    final levelFilteredGroups = _selectedLevelKeys.isEmpty
        ? lessonGroups
        : lessonGroups
              .where((group) => _selectedLevelKeys.contains(group.levelKey))
              .toList(growable: false);
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleGroups = normalizedQuery.isEmpty
        ? levelFilteredGroups
        : levelFilteredGroups
              .map(
                (group) => ReadingLessonGroup(
                  levelKey: group.levelKey,
                  levelLabel: group.levelLabel,
                  lessons: group.lessons
                      .where(
                        (lesson) => _resolvedLessonTitle(lesson)
                            .toLowerCase()
                            .contains(normalizedQuery),
                      )
                      .toList(growable: false),
                ),
              )
              .where((group) => group.lessons.isNotEmpty)
              .toList(growable: false);
    final visibleLessonCount = visibleGroups.fold<int>(
      0,
      (count, group) => count + group.lessons.length,
    );
    final hasResults = visibleLessonCount > 0;

    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: tokens.pagePadding.copyWith(bottom: 108),
          children: [
            if (widget.topContent != null) ...[
              widget.topContent!,
              const SizedBox(height: 18),
            ],
            Text(
              '\u0427\u0438\u0442\u0430\u043d\u043d\u044f',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '\u0422\u0435\u043a\u0441\u0442\u0438 \u0434\u043b\u044f \u0447\u0438\u0442\u0430\u043d\u043d\u044f, \u0440\u043e\u0437\u043a\u043b\u0430\u0434\u0435\u043d\u0456 \u0437\u0430 \u0440\u0456\u0432\u043d\u044f\u043c\u0438.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: tokens.mutedText,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ReadingSearchCard(
              totalCount: widget.lessons.length,
              visibleCount: visibleLessonCount,
              completedLabel: progress.completedLabel('\u0443\u0440\u043e\u043a\u0456\u0432'),
              query: _query,
              hasLevelFilter: _selectedLevelKeys.isNotEmpty,
              isSearchVisible: _searchVisible,
              isLoadingLessonTitles: _isLoadingLessonTitles,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              onToggleSearch: _toggleSearchVisibility,
              onQueryChanged: (value) {
                setState(() {
                  _query = value;
                  if (value.trim().isNotEmpty) {
                    _searchVisible = true;
                  }
                });
              },
            ),
            const SizedBox(height: 18),
            if (!hasResults)
              const ReadingEmptySearchState()
            else
              ...visibleGroups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _ReadingLevelSection(
                    group: group,
                    documentLoader: widget.documentLoader,
                    statusFor: statusFor,
                    onStatusChanged: handleLessonStatusSelected,
                    titleResolver: _resolvedLessonTitle,
                  ),
                ),
              ),
          ],
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
                offset: showScrollToTop ? Offset.zero : const Offset(0, 0.25),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: showScrollToTop ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showScrollToTop,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton.small(
                        heroTag: 'readingScrollToTop',
                        onPressed: scrollToTop,
                        backgroundColor: tokens.elevatedSurface,
                        foregroundColor: tokens.readingAccent,
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
                backgroundColor: tokens.readingAccent,
                foregroundColor: accentForeground,
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
        final tokens = Theme.of(context).appTokens;
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Можна лишити весь каталог або вибрати один рівень.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedText,
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
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final heroForeground = tokens.heroText;
    final level = readingLevelLabelFromAssetPath(widget.lesson.assetPath);

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
                    gradient: LinearGradient(
                      colors: [tokens.primaryAccent, tokens.readingAccent],
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
                                color: tokens.heroControlSurface(
                                  heroForeground,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                level,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: heroForeground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              document.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: heroForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      LessonStatusToggleButton(
                        status: _status,
                        onPressed: () {
                          _updateStatus(nextLessonProgressStatus(_status));
                        },
                        foregroundColor: heroForeground,
                        backgroundColor: tokens.heroControlSurface(
                          heroForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 20),
                MarkdownLessonBody(
                  body: document.body,
                  accentColor: tokens.readingAccent,
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
    final tokens = Theme.of(context).appTokens;
    final statusTheme = lessonStatusVisuals(status, tokens: tokens);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
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
                  color: tokens.accentMediumSurface(statusTheme.color),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: tokens.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              LessonStatusToggleButton(
                status: status,
                compact: true,
                onPressed: () {
                  onStatusSelected(nextLessonProgressStatus(status));
                },
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: tokens.readingAccent,
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
  final GuideLessonStatus Function(LessonEntry lesson) statusFor;
  final Future<void> Function(LessonEntry lesson, GuideLessonStatus status)
  onStatusChanged;
  final String Function(LessonEntry lesson) titleResolver;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.secondaryText),
              ),
            ],
          ),
        ),
        ...group.lessons.map((lesson) {
          final lessonStatus = statusFor(lesson);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReadingLessonCard(
              lesson: lesson,
              resolvedTitle: titleResolver(lesson),
              status: lessonStatus,
              onStatusSelected: (status) {
                unawaited(onStatusChanged(lesson, status));
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReadingDetailScreen(
                      lesson: lesson,
                      documentLoader: documentLoader,
                      initialStatus: lessonStatus,
                      onStatusChanged: (status) {
                        unawaited(onStatusChanged(lesson, status));
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
    final tokens = Theme.of(context).appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: tokens.accentSurface(tokens.readingAccent),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accentMutedSurface(tokens.readingAccent),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.tune_rounded, color: tokens.readingAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рівень',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: tokens.secondaryText,
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
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: tokens.readingAccent,
              ),
            ],
          ),
        ),
      ),
    );
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
    final tokens = Theme.of(context).appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? tokens.accentSubtleSurface(tokens.readingAccent)
                : tokens.subtleSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? tokens.accentSelectedBorder(tokens.readingAccent)
                  : tokens.outlineSoft,
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? tokens.readingAccent : tokens.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
