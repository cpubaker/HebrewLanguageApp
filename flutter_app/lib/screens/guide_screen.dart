import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/guide_detail_links.dart';
import '../services/lesson_document_loader.dart';
import '../services/lesson_status_updates.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'widgets/app_section_card.dart';
import 'widgets/guide/guide_adjacent_lessons_card.dart';
import 'widgets/guide/guide_detail_header.dart';
import 'widgets/guide/guide_empty_search_state.dart';
import 'widgets/guide/guide_lesson_card.dart';
import 'widgets/guide/guide_outline_card.dart';
import 'widgets/guide/guide_related_topics_card.dart';
import 'widgets/guide/guide_search_card.dart';
import 'widgets/markdown_lesson_body.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({
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
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;

  final Map<String, LessonDocument> _lessonDocuments =
      <String, LessonDocument>{};
  late Map<String, GuideLessonStatus> _lessonStatuses;

  String _query = '';
  final Set<String> _selectedSectionIds = <String>{};
  bool _searchVisible = false;
  bool _showScrollToTop = false;
  bool _isLoadingLessonDocuments = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode();
    _lessonStatuses = Map<String, GuideLessonStatus>.from(
      widget.lessonStatuses,
    );
    unawaited(_primeLessonDocuments());
  }

  @override
  void didUpdateWidget(covariant GuideScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonStatuses != widget.lessonStatuses) {
      _lessonStatuses = Map<String, GuideLessonStatus>.from(
        widget.lessonStatuses,
      );
    }
    if (oldWidget.lessons != widget.lessons) {
      final availableSectionIds = _availableSections
          .map((section) => section.id)
          .toSet();
      final invalidSectionIds = _selectedSectionIds
          .where((sectionId) => !availableSectionIds.contains(sectionId))
          .toList(growable: false);
      if (invalidSectionIds.isNotEmpty) {
        _selectedSectionIds.removeAll(invalidSectionIds);
      }
      unawaited(_primeLessonDocuments());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  GuideLessonStatus _statusFor(LessonEntry lesson) {
    return _lessonStatuses[lesson.progressKey] ?? GuideLessonStatus.unread;
  }

  Future<void> _handleLessonStatusSelected(
    LessonEntry lesson,
    GuideLessonStatus status,
  ) async {
    final lessonKey = lesson.progressKey;
    final previousStatus = _lessonStatuses[lessonKey];
    setState(() {
      _lessonStatuses = applyLessonStatus(
        _lessonStatuses,
        lessonKey: lessonKey,
        status: status,
      );
    });

    final saved = await widget.onStatusChanged(lessonKey, status);
    if (!saved && mounted) {
      setState(() {
        _lessonStatuses = restoreLessonStatus(
          _lessonStatuses,
          lessonKey: lessonKey,
          previousStatus: previousStatus,
        );
      });
    }
  }

  Future<void> _primeLessonDocuments() async {
    if (_isLoadingLessonDocuments) {
      return;
    }

    final missingLessons = widget.lessons
        .where((lesson) => !_lessonDocuments.containsKey(lesson.assetPath))
        .toList(growable: false);
    if (missingLessons.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingLessonDocuments = true;
    });

    const batchSize = 18;

    try {
      for (
        var startIndex = 0;
        startIndex < missingLessons.length;
        startIndex += batchSize
      ) {
        final batch = missingLessons.skip(startIndex).take(batchSize);
        final resolvedDocuments = await Future.wait(
          batch.map((lesson) async {
            try {
              final document = await widget.documentLoader.load(
                lesson.assetPath,
              );
              return MapEntry<String, LessonDocument?>(
                lesson.assetPath,
                document,
              );
            } catch (_) {
              return MapEntry<String, LessonDocument?>(lesson.assetPath, null);
            }
          }),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          for (final entry in resolvedDocuments) {
            final document = entry.value;
            if (document != null) {
              _lessonDocuments[entry.key] = document;
            }
          }
        });

        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLessonDocuments = false;
        });
      }
    }
  }

  Future<void> _ensureLessonDocumentsLoaded() async {
    if (_isLoadingLessonDocuments) {
      while (mounted && _isLoadingLessonDocuments) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
      return;
    }

    if (_lessonDocuments.length < widget.lessons.length) {
      await _primeLessonDocuments();
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

  Future<void> _openSearch() async {
    if (!_searchVisible) {
      setState(() {
        _searchVisible = true;
      });
    }

    await _scrollToTop();
    if (!mounted) {
      return;
    }

    _searchFocusNode.requestFocus();
    unawaited(_ensureLessonDocumentsLoaded());
  }

  Future<void> _showSectionPicker(
    BuildContext context,
    List<_GuideSectionOption> sections,
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
                    'Секція довідника',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Можна лишити весь каталог або вибрати кілька секцій.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GuideSectionOptionTile(
                    label: 'Усі теми',
                    count: widget.lessons.length,
                    selected: _selectedSectionIds.isEmpty,
                    onTap: () {
                      setState(() {
                        _selectedSectionIds.clear();
                      });
                      bottomSheetSetState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  ...sections.expand(
                    (section) => [
                      GuideSectionOptionTile(
                        label: section.label,
                        count: section.count,
                        selected: _selectedSectionIds.contains(section.id),
                        onTap: () {
                          setState(() {
                            if (_selectedSectionIds.contains(section.id)) {
                              _selectedSectionIds.remove(section.id);
                            } else {
                              _selectedSectionIds.add(section.id);
                            }
                          });
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

  void _toggleSearchVisibility() {
    if (!_searchVisible) {
      unawaited(_openSearch());
      return;
    }

    if (_query.isNotEmpty) {
      _searchController.clear();
      setState(() {
        _query = '';
      });
      return;
    }

    _searchFocusNode.unfocus();
    setState(() {
      _searchVisible = false;
    });
  }

  String _resolvedLessonTitle(LessonEntry lesson) {
    final cachedTitle = _lessonDocuments[lesson.assetPath]?.title;
    if (cachedTitle != null && cachedTitle.trim().isNotEmpty) {
      return cachedTitle.trim();
    }

    return lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '');
  }

  String _resolvedLessonSummary(LessonEntry lesson) {
    return _lessonDocuments[lesson.assetPath]?.summary.trim() ?? '';
  }

  List<_GuideSectionOption> get _availableSections {
    final sections = <String, _GuideSectionOption>{};

    for (final lesson in widget.lessons) {
      final sectionId = lesson.sectionId;
      final sectionLabel = lesson.sectionLabel;
      if (sectionId == null ||
          sectionId.trim().isEmpty ||
          sectionLabel == null ||
          sectionLabel.trim().isEmpty) {
        continue;
      }

      sections.putIfAbsent(
        sectionId,
        () => _GuideSectionOption(id: sectionId, label: sectionLabel, count: 0),
      );
      sections[sectionId] = sections[sectionId]!.copyWith(
        count: sections[sectionId]!.count + 1,
      );
    }

    return sections.values.toList(growable: false);
  }

  List<LessonEntry> get _filteredLessons {
    final normalizedQuery = _query.trim().toLowerCase();

    return widget.lessons
        .where((lesson) {
          if (_selectedSectionIds.isNotEmpty &&
              !_selectedSectionIds.contains(lesson.sectionId)) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          final document = _lessonDocuments[lesson.assetPath];
          final haystack = <String>[
            _resolvedLessonTitle(lesson),
            lesson.displayName,
            lesson.assetPath.split('/').last,
            lesson.sectionLabel ?? '',
            ...lesson.aliases,
            document?.summary ?? '',
            ...?document?.headings,
            document?.body ?? '',
          ].join('\n').toLowerCase();

          return haystack.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final progress = LessonProgressSnapshot.fromLessons(
      lessons: widget.lessons,
      lessonStatuses: widget.lessonStatuses,
    );
    final filteredLessons = _filteredLessons;
    final hasResults = filteredLessons.isNotEmpty;
    final availableSections = _availableSections;
    final selectedSectionLabels = availableSections
        .where((section) => _selectedSectionIds.contains(section.id))
        .map((section) => section.label)
        .toList(growable: false);

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: tokens.pagePadding.copyWith(bottom: 108),
          children: [
            if (widget.topContent != null) ...[
              widget.topContent!,
              const SizedBox(height: 18),
            ],
            Text(
              'Довідник',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            AppSectionCard(
              child: GuideSearchCard(
                totalCount: widget.lessons.length,
                completedLabel: progress.completedLabel('тем'),
                visibleCount: filteredLessons.length,
                query: _query,
                selectedSectionLabels: selectedSectionLabels,
                isSearchVisible: _searchVisible,
                isLoadingLessonDocuments: _isLoadingLessonDocuments,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onToggleSearch: _toggleSearchVisibility,
                onOpenSectionPicker: availableSections.isEmpty
                    ? null
                    : () => _showSectionPicker(context, availableSections),
                onQueryChanged: (value) {
                  setState(() {
                    _query = value;
                    if (value.trim().isNotEmpty) {
                      _searchVisible = true;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            if (!hasResults)
              const GuideEmptySearchState()
            else
              ...filteredLessons.map(
                (lesson) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GuideLessonCard(
                    lesson: lesson,
                    status: _statusFor(lesson),
                    resolvedTitle: _resolvedLessonTitle(lesson),
                    resolvedSummary: _resolvedLessonSummary(lesson),
                    onStatusSelected: (status) {
                      unawaited(_handleLessonStatusSelected(lesson, status));
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GuideDetailScreen(
                            lesson: lesson,
                            allLessons: widget.lessons,
                            documentLoader: widget.documentLoader,
                            lessonStatuses: widget.lessonStatuses,
                            initialStatus: _statusFor(lesson),
                            onStatusChanged: (status) {
                              return widget.onStatusChanged(
                                lesson.progressKey,
                                status,
                              );
                            },
                          ),
                        ),
                      );
                    },
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
                offset: _showScrollToTop ? Offset.zero : const Offset(0, 0.25),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showScrollToTop ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showScrollToTop,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton.small(
                        heroTag: 'guideScrollToTop',
                        onPressed: _scrollToTop,
                        backgroundColor: tokens.elevatedSurface,
                        foregroundColor: tokens.guideAccent,
                        child: const Icon(Icons.vertical_align_top_rounded),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
    this.allLessons = const <LessonEntry>[],
    this.lessonStatuses = const <String, GuideLessonStatus>{},
    required this.documentLoader,
    required this.initialStatus,
    required this.onStatusChanged,
  });

  final LessonEntry lesson;
  final List<LessonEntry> allLessons;
  final Map<String, GuideLessonStatus> lessonStatuses;
  final LessonDocumentLoader documentLoader;
  final GuideLessonStatus initialStatus;
  final FutureOr<bool> Function(GuideLessonStatus status) onStatusChanged;

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late GuideLessonStatus _status;
  late final GuideDetailLinkResolver _linkResolver;
  late final Future<LessonDocument> _lessonDocumentFuture;
  late final Future<Map<String, String>> _adjacentLessonTitlesFuture;
  late final Future<GuideRelatedTopicsResolution> _relatedTopicsFuture;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus == GuideLessonStatus.unread
        ? GuideLessonStatus.studying
        : widget.initialStatus;
    _linkResolver = GuideDetailLinkResolver(
      lesson: widget.lesson,
      allLessons: widget.allLessons,
      documentLoader: widget.documentLoader,
    );
    _lessonDocumentFuture = widget.documentLoader.load(widget.lesson.assetPath);
    _adjacentLessonTitlesFuture = _linkResolver.resolveAdjacentLessonTitles();
    _relatedTopicsFuture = _lessonDocumentFuture.then(
      (document) =>
          _linkResolver.resolveRelatedTopics(currentDocument: document),
    );

    if (widget.initialStatus == GuideLessonStatus.unread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        unawaited(Future.value(widget.onStatusChanged(_status)));
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
    unawaited(Future.value(widget.onStatusChanged(status)));
  }

  LessonEntry? get _previousLesson => _linkResolver.previousLesson;

  LessonEntry? get _nextLesson => _linkResolver.nextLesson;

  void _openLesson(LessonEntry lesson) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GuideDetailScreen(
          lesson: lesson,
          allLessons: widget.allLessons,
          lessonStatuses: widget.lessonStatuses,
          documentLoader: widget.documentLoader,
          initialStatus:
              widget.lessonStatuses[lesson.progressKey] ??
              GuideLessonStatus.unread,
          onStatusChanged: widget.onStatusChanged,
        ),
      ),
    );
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
    final tokens = Theme.of(context).appTokens;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<LessonDocument>(
          future: _lessonDocumentFuture,
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
                  GuideDetailHeader(
                    lesson: widget.lesson,
                    title: document.title,
                    summary: document.summary,
                    status: _status,
                    onStatusPressed: () {
                      _updateStatus(nextLessonProgressStatus(_status));
                    },
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  MarkdownLessonBody(
                    body: document.body,
                    accentColor: tokens.guideSecondaryAccent,
                  ),
                  if (document.headings.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    GuideOutlineCard(headings: document.headings),
                  ],
                  if (_previousLesson != null || _nextLesson != null) ...[
                    const SizedBox(height: 18),
                    FutureBuilder<Map<String, String>>(
                      future: _adjacentLessonTitlesFuture,
                      builder: (context, adjacentSnapshot) {
                        final titlesByAssetPath =
                            adjacentSnapshot.data ?? const <String, String>{};
                        return GuideAdjacentLessonsCard(
                          previousLessonTitle: _previousLesson == null
                              ? null
                              : titlesByAssetPath[_previousLesson!.assetPath] ??
                                    fallbackLessonTitle(_previousLesson!),
                          nextLessonTitle: _nextLesson == null
                              ? null
                              : titlesByAssetPath[_nextLesson!.assetPath] ??
                                    fallbackLessonTitle(_nextLesson!),
                          onOpenPrevious: _previousLesson == null
                              ? null
                              : () => _openLesson(_previousLesson!),
                          onOpenNext: _nextLesson == null
                              ? null
                              : () => _openLesson(_nextLesson!),
                        );
                      },
                    ),
                  ],
                  if (document.relatedTopics.isNotEmpty ||
                      widget.lesson.relatedIds.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    FutureBuilder<GuideRelatedTopicsResolution>(
                      future: _relatedTopicsFuture,
                      builder: (context, relatedSnapshot) {
                        if (relatedSnapshot.connectionState !=
                            ConnectionState.done) {
                          return const GuideRelatedTopicsLoadingCard();
                        }

                        final resolution =
                            relatedSnapshot.data ??
                            GuideRelatedTopicsResolution.empty();
                        return GuideRelatedTopicsCard(
                          resolution: resolution,
                          onOpenLesson: _openLesson,
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GuideSectionOption {
  const _GuideSectionOption({
    required this.id,
    required this.label,
    required this.count,
  });

  final String id;
  final String label;
  final int count;

  _GuideSectionOption copyWith({String? id, String? label, int? count}) {
    return _GuideSectionOption(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }
}
