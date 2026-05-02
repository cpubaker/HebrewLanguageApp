import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import '../services/lesson_status_updates.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'widgets/app_section_card.dart';
import 'widgets/guide/guide_empty_search_state.dart';
import 'widgets/guide/guide_lesson_card.dart';
import 'widgets/guide/guide_search_card.dart';
import 'widgets/guide/guide_section_pill.dart';
import 'widgets/lesson_status_controls.dart';
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
                      color: const Color(0xFF5F5A52),
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
                        foregroundColor: const Color(0xFFB45309),
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
  late final Future<Map<String, String>> _adjacentLessonTitlesFuture;
  late final Future<_GuideRelatedTopicsResolution> _relatedTopicsFuture;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus == GuideLessonStatus.unread
        ? GuideLessonStatus.studying
        : widget.initialStatus;
    _adjacentLessonTitlesFuture = _resolveAdjacentLessonTitles();
    _relatedTopicsFuture = _resolveRelatedTopics();

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

  int get _currentLessonIndex {
    return widget.allLessons.indexWhere(
      (lesson) => lesson.assetPath == widget.lesson.assetPath,
    );
  }

  LessonEntry? get _previousLesson {
    final currentLessonIndex = _currentLessonIndex;
    if (currentLessonIndex <= 0) {
      return null;
    }

    return widget.allLessons[currentLessonIndex - 1];
  }

  LessonEntry? get _nextLesson {
    final currentLessonIndex = _currentLessonIndex;
    if (currentLessonIndex < 0 ||
        currentLessonIndex >= widget.allLessons.length - 1) {
      return null;
    }

    return widget.allLessons[currentLessonIndex + 1];
  }

  Future<Map<String, String>> _resolveAdjacentLessonTitles() async {
    final titlesByAssetPath = <String, String>{};
    final adjacentLessons = [
      _previousLesson,
      _nextLesson,
    ].whereType<LessonEntry>();

    for (final lesson in adjacentLessons) {
      try {
        final document = await widget.documentLoader.load(lesson.assetPath);
        final title = document.title.trim();
        if (title.isNotEmpty) {
          titlesByAssetPath[lesson.assetPath] = title;
        }
      } catch (_) {
        // Keep the navigation usable even if an adjacent lesson fails to load.
      }
    }

    return titlesByAssetPath;
  }

  Future<_GuideRelatedTopicsResolution> _resolveRelatedTopics() async {
    final currentDocument = await widget.documentLoader.load(
      widget.lesson.assetPath,
    );
    if (widget.allLessons.isEmpty) {
      return const _GuideRelatedTopicsResolution.empty();
    }

    final titlesByAssetPath = <String, String>{};
    final lessonsById = <String, LessonEntry>{};
    for (final lesson in widget.allLessons) {
      try {
        final document = await widget.documentLoader.load(lesson.assetPath);
        titlesByAssetPath[lesson.assetPath] = document.title;
      } catch (_) {
        // Ignore broken lessons and keep other navigation links working.
      }

      final lessonId = lesson.lessonId;
      if (lessonId != null && lessonId.trim().isNotEmpty) {
        lessonsById[lessonId] = lesson;
      }
    }

    final resolvedTopics = <_GuideResolvedTopic>[];
    final usedAssetPaths = <String>{};
    final usedTopicKeys = <String>{};
    final currentLessonTitle =
        titlesByAssetPath[widget.lesson.assetPath] ??
        _fallbackLessonTitle(widget.lesson);
    final normalizedCurrentLessonTitle = _normalizeForMatching(
      currentLessonTitle,
    );

    void addResolvedTopic(LessonEntry lesson) {
      final resolvedLabel =
          titlesByAssetPath[lesson.assetPath] ?? _fallbackLessonTitle(lesson);
      final normalizedResolvedLabel = _normalizeForMatching(resolvedLabel);
      final isAdjacentLesson =
          lesson.assetPath == _previousLesson?.assetPath ||
          lesson.assetPath == _nextLesson?.assetPath;
      if (lesson.assetPath == widget.lesson.assetPath ||
          isAdjacentLesson ||
          !usedAssetPaths.add(lesson.assetPath) ||
          normalizedResolvedLabel.isEmpty ||
          !usedTopicKeys.add(normalizedResolvedLabel)) {
        return;
      }

      resolvedTopics.add(
        _GuideResolvedTopic(label: resolvedLabel, lesson: lesson),
      );
    }

    for (final relatedId in widget.lesson.relatedIds) {
      final matchingLesson = lessonsById[relatedId];
      if (matchingLesson == null) {
        continue;
      }
      addResolvedTopic(matchingLesson);
    }

    if (currentDocument.relatedTopics.isEmpty) {
      return _GuideRelatedTopicsResolution(resolvedTopics: resolvedTopics);
    }

    for (final topic in currentDocument.relatedTopics) {
      if (_normalizeForMatching(topic) == normalizedCurrentLessonTitle) {
        continue;
      }

      final matchingLesson = _matchRelatedTopic(
        topic,
        titlesByAssetPath: titlesByAssetPath,
      );
      if (matchingLesson == null) {
        continue;
      }
      addResolvedTopic(matchingLesson);
    }

    return _GuideRelatedTopicsResolution(resolvedTopics: resolvedTopics);
  }

  LessonEntry? _matchRelatedTopic(
    String topic, {
    required Map<String, String> titlesByAssetPath,
  }) {
    final normalizedTopic = _normalizeForMatching(topic);
    if (normalizedTopic.isEmpty) {
      return null;
    }

    final topicTokens = normalizedTopic
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toSet();
    LessonEntry? bestLesson;
    var bestScore = 0;

    for (final lesson in widget.allLessons) {
      final candidates = <String>[
        titlesByAssetPath[lesson.assetPath] ?? '',
        _fallbackLessonTitle(lesson),
        ...lesson.aliases,
      ];

      for (final candidate in candidates) {
        final score = _topicMatchScore(
          normalizedTopic: normalizedTopic,
          topicTokens: topicTokens,
          candidate: candidate,
        );
        if (score > bestScore) {
          bestScore = score;
          bestLesson = lesson;
        }
      }
    }

    if (bestScore < 20) {
      return null;
    }

    return bestLesson;
  }

  int _topicMatchScore({
    required String normalizedTopic,
    required Set<String> topicTokens,
    required String candidate,
  }) {
    final normalizedCandidate = _normalizeForMatching(candidate);
    if (normalizedCandidate.isEmpty) {
      return 0;
    }

    if (normalizedCandidate == normalizedTopic) {
      return 100;
    }

    if (normalizedCandidate.contains(normalizedTopic) ||
        normalizedTopic.contains(normalizedCandidate)) {
      return 80;
    }

    final candidateTokens = normalizedCandidate
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toSet();
    final overlap = topicTokens.intersection(candidateTokens).length;
    if (overlap == 0) {
      return 0;
    }

    var score = overlap * 10;
    if (topicTokens.every(candidateTokens.contains)) {
      score += 20;
    }
    if (candidateTokens.every(topicTokens.contains)) {
      score += 15;
    }

    return score;
  }

  String _normalizeForMatching(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0591-\u05C7]'), '')
        .replaceAll(RegExp(r'[^0-9a-z\u0400-\u04ff\u0590-\u05ff]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _fallbackLessonTitle(LessonEntry lesson) {
    return lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '').trim();
  }

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
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final heroForeground = theme.brightness == Brightness.dark
        ? tokens.heroText
        : Colors.white;
    final heroMutedForeground = theme.brightness == Brightness.dark
        ? tokens.heroMutedText
        : Colors.white.withValues(alpha: 0.92);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<LessonDocument>(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.lesson.sectionLabel != null)
                              GuideSectionPill(
                                label: widget.lesson.sectionLabel!,
                                foregroundColor: heroForeground,
                                backgroundColor: heroForeground.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            const Spacer(),
                            LessonStatusToggleButton(
                              status: _status,
                              onPressed: () {
                                _updateStatus(
                                  nextLessonProgressStatus(_status),
                                );
                              },
                              foregroundColor: heroForeground,
                              backgroundColor: heroForeground.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          document.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: heroForeground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (document.summary.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            document.summary.trim(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: heroMutedForeground,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  MarkdownLessonBody(
                    body: document.body,
                    accentColor: const Color(0xFF8C6A2A),
                  ),
                  if (document.headings.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _GuideOutlineCard(headings: document.headings),
                  ],
                  if (_previousLesson != null || _nextLesson != null) ...[
                    const SizedBox(height: 18),
                    FutureBuilder<Map<String, String>>(
                      future: _adjacentLessonTitlesFuture,
                      builder: (context, adjacentSnapshot) {
                        final titlesByAssetPath =
                            adjacentSnapshot.data ?? const <String, String>{};
                        return _GuideAdjacentLessonsCard(
                          previousLessonTitle: _previousLesson == null
                              ? null
                              : titlesByAssetPath[_previousLesson!.assetPath] ??
                                    _fallbackLessonTitle(_previousLesson!),
                          nextLessonTitle: _nextLesson == null
                              ? null
                              : titlesByAssetPath[_nextLesson!.assetPath] ??
                                    _fallbackLessonTitle(_nextLesson!),
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
                    FutureBuilder<_GuideRelatedTopicsResolution>(
                      future: _relatedTopicsFuture,
                      builder: (context, relatedSnapshot) {
                        if (relatedSnapshot.connectionState !=
                            ConnectionState.done) {
                          return const _GuideRelatedTopicsLoadingCard();
                        }

                        final resolution =
                            relatedSnapshot.data ??
                            _GuideRelatedTopicsResolution.empty();
                        return _GuideRelatedTopicsCard(
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

class _GuideOutlineCard extends StatelessWidget {
  const _GuideOutlineCard({required this.headings});

  final List<String> headings;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'У цій статті',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...headings.map(
            (heading) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      heading,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.secondaryText,
                        height: 1.35,
                      ),
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

class _GuideAdjacentLessonsCard extends StatelessWidget {
  const _GuideAdjacentLessonsCard({
    this.previousLessonTitle,
    this.nextLessonTitle,
    this.onOpenPrevious,
    this.onOpenNext,
  });

  final String? previousLessonTitle;
  final String? nextLessonTitle;
  final VoidCallback? onOpenPrevious;
  final VoidCallback? onOpenNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GuideNavigationButton(
            label: 'Попередня тема',
            title: previousLessonTitle,
            icon: Icons.arrow_back_rounded,
            onPressed: onOpenPrevious,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GuideNavigationButton(
            label: 'Наступна тема',
            title: nextLessonTitle,
            icon: Icons.arrow_forward_rounded,
            iconTrailing: true,
            onPressed: onOpenNext,
          ),
        ),
      ],
    );
  }
}

class _GuideNavigationButton extends StatelessWidget {
  const _GuideNavigationButton({
    required this.label,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconTrailing = false,
  });

  final String label;
  final String? title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF8C6A2A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!iconTrailing)
                    Icon(
                      icon,
                      size: 18,
                      color: onPressed == null
                          ? const Color(0xFFB7ADA1)
                          : const Color(0xFFB45309),
                    ),
                  if (!iconTrailing) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title ?? 'Немає',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPressed == null
                            ? tokens.mutedText.withValues(alpha: 0.75)
                            : tokens.secondaryText,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (iconTrailing) const SizedBox(width: 8),
                  if (iconTrailing)
                    Icon(
                      icon,
                      size: 18,
                      color: onPressed == null
                          ? const Color(0xFFB7ADA1)
                          : const Color(0xFFB45309),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideRelatedTopicsLoadingCard extends StatelessWidget {
  const _GuideRelatedTopicsLoadingCard();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Підбираємо пов’язані теми для швидких переходів.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideRelatedTopicsCard extends StatelessWidget {
  const _GuideRelatedTopicsCard({
    required this.resolution,
    required this.onOpenLesson,
  });

  final _GuideRelatedTopicsResolution resolution;
  final ValueChanged<LessonEntry> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пов’язані теми',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (resolution.resolvedTopics.isEmpty)
            Text(
              'Усі найближчі пов\'язані теми вже є в навігації вище.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...resolution.resolvedTopics.map(
                  (topic) => ActionChip(
                    avatar: const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    label: Text(topic.label),
                    labelStyle: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(
                          color: const Color(0xFF8C6A2A),
                          fontWeight: FontWeight.w700,
                        ),
                    backgroundColor: const Color(0xFFFDE7D4),
                    onPressed: () => onOpenLesson(topic.lesson),
                  ),
                ),
              ],
            ),
        ],
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

class _GuideRelatedTopicsResolution {
  const _GuideRelatedTopicsResolution({required this.resolvedTopics});

  const _GuideRelatedTopicsResolution.empty()
    : resolvedTopics = const <_GuideResolvedTopic>[];

  final List<_GuideResolvedTopic> resolvedTopics;
}

class _GuideResolvedTopic {
  const _GuideResolvedTopic({required this.label, required this.lesson});

  final String label;
  final LessonEntry lesson;
}
