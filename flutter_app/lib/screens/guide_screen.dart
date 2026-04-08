import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guide_lesson_status.dart';
import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import 'widgets/markdown_lesson_body.dart';

class GuideScreen extends StatefulWidget {
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

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;

  final Map<String, LessonDocument> _lessonDocuments =
      <String, LessonDocument>{};

  String _query = '';
  String? _selectedSectionId;
  bool _searchVisible = false;
  bool _showScrollToTop = false;
  bool _isLoadingLessonDocuments = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode();
    unawaited(_primeLessonDocuments());
  }

  @override
  void didUpdateWidget(covariant GuideScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons != widget.lessons) {
      if (_selectedSectionId != null &&
          !_availableSections.any((section) => section.id == _selectedSectionId)) {
        _selectedSectionId = null;
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

  GuideLessonStatus _statusFor(String assetPath) {
    return widget.lessonStatuses[assetPath] ?? GuideLessonStatus.unread;
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
              final document = await widget.documentLoader.load(lesson.assetPath);
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
        () => _GuideSectionOption(id: sectionId, label: sectionLabel),
      );
    }

    return sections.values.toList(growable: false);
  }

  List<LessonEntry> get _filteredLessons {
    final normalizedQuery = _query.trim().toLowerCase();

    return widget.lessons.where((lesson) {
      if (_selectedSectionId != null && lesson.sectionId != _selectedSectionId) {
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
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final readCount = widget.lessons
        .where(
          (lesson) => _statusFor(lesson.assetPath) == GuideLessonStatus.read,
        )
        .length;
    final filteredLessons = _filteredLessons;
    final hasResults = filteredLessons.isNotEmpty;
    final availableSections = _availableSections;
    final selectedSectionLabel = availableSections
        .where((section) => section.id == _selectedSectionId)
        .map((section) => section.label)
        .toList(growable: false);

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
          children: [
            Text(
              'Довідник',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Короткі статті з граматики, синтаксису та живої мови. Їх можна читати підряд або швидко знаходити за темою.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5F5A52),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _GuideSearchCard(
              totalCount: widget.lessons.length,
              visibleCount: filteredLessons.length,
              query: _query,
              selectedSectionLabel: selectedSectionLabel.isEmpty
                  ? null
                  : selectedSectionLabel.first,
              isSearchVisible: _searchVisible,
              isLoadingLessonDocuments: _isLoadingLessonDocuments,
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
            if (availableSections.isNotEmpty) ...[
              const SizedBox(height: 14),
              _GuideSectionFilters(
                sections: availableSections,
                selectedSectionId: _selectedSectionId,
                onSelected: (sectionId) {
                  setState(() {
                    _selectedSectionId = sectionId;
                  });
                },
              ),
            ],
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
                      'Прочитано $readCount із ${widget.lessons.length} тем',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!hasResults)
              const _EmptyGuideSearchState()
            else
              ...filteredLessons.map(
                (lesson) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GuideLessonCard(
                    lesson: lesson,
                    status: _statusFor(lesson.assetPath),
                    resolvedTitle: _resolvedLessonTitle(lesson),
                    resolvedSummary: _resolvedLessonSummary(lesson),
                    onStatusSelected: (status) {
                      widget.onStatusChanged(lesson.assetPath, status);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GuideDetailScreen(
                            lesson: lesson,
                            allLessons: widget.lessons,
                            documentLoader: widget.documentLoader,
                            lessonStatuses: widget.lessonStatuses,
                            initialStatus: _statusFor(lesson.assetPath),
                            onStatusChanged: (status) {
                              widget.onStatusChanged(lesson.assetPath, status);
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
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFB45309),
                        child: const Icon(Icons.vertical_align_top_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton.small(
                heroTag: 'guideSearch',
                tooltip: 'Пошук по довіднику',
                onPressed: _openSearch,
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                child: const Icon(Icons.search_rounded),
              ),
            ],
          ),
        ),
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
  final ValueChanged<GuideLessonStatus> onStatusChanged;

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
    final adjacentLessons = <LessonEntry>[
      if (_previousLesson != null) _previousLesson!,
      if (_nextLesson != null) _nextLesson!,
    ];

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
        titlesByAssetPath[widget.lesson.assetPath] ?? _fallbackLessonTitle(widget.lesson);
    final normalizedCurrentLessonTitle = _normalizeForMatching(currentLessonTitle);

    void addResolvedTopic(LessonEntry lesson) {
      final resolvedLabel =
          titlesByAssetPath[lesson.assetPath] ?? _fallbackLessonTitle(lesson);
      final normalizedResolvedLabel = _normalizeForMatching(resolvedLabel);
      if (lesson.assetPath == widget.lesson.assetPath ||
          !usedAssetPaths.add(lesson.assetPath) ||
          normalizedResolvedLabel.isEmpty ||
          !usedTopicKeys.add(normalizedResolvedLabel)) {
        return;
      }

      resolvedTopics.add(
        _GuideResolvedTopic(
          label: resolvedLabel,
          lesson: lesson,
        ),
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
      return _GuideRelatedTopicsResolution(
        resolvedTopics: resolvedTopics,
      );
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

    return _GuideRelatedTopicsResolution(
      resolvedTopics: resolvedTopics,
    );
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
              widget.lessonStatuses[lesson.assetPath] ?? GuideLessonStatus.unread,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.lesson.sectionLabel != null)
                            _GuideSectionPill(
                              label: widget.lesson.sectionLabel!,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          const Spacer(),
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
                      const SizedBox(height: 14),
                      Text(
                        document.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (document.summary.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          document.summary.trim(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.45,
                          ),
                        ),
                      ],
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

                      final resolution = relatedSnapshot.data ??
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
    );
  }
}

class _GuideSearchCard extends StatelessWidget {
  const _GuideSearchCard({
    required this.totalCount,
    required this.visibleCount,
    required this.query,
    required this.selectedSectionLabel,
    required this.isSearchVisible,
    required this.isLoadingLessonDocuments,
    required this.searchController,
    required this.searchFocusNode,
    required this.onToggleSearch,
    required this.onQueryChanged,
  });

  final int totalCount;
  final int visibleCount;
  final String query;
  final String? selectedSectionLabel;
  final bool isSearchVisible;
  final bool isLoadingLessonDocuments;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    final subtitle = hasQuery || selectedSectionLabel != null
        ? 'Знайдено: $visibleCount із $totalCount'
        : 'Тем: $totalCount';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB45309).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore_rounded, color: Color(0xFFB45309)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: isSearchVisible ? 'Сховати пошук' : 'Показати пошук',
                onPressed: onToggleSearch,
                icon: Icon(
                  isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isSearchVisible || hasQuery
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              selectedSectionLabel == null
                  ? 'Шукайте по назві теми, ключових словах, короткому опису або тексту статті.'
                  : 'Активна секція: $selectedSectionLabel. Можна ще звузити пошук словами.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F5A52),
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _GuideSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: 'Шукати тему в довіднику',
                onChanged: onQueryChanged,
                onClear: hasQuery
                    ? () {
                        searchController.clear();
                        onQueryChanged('');
                      }
                    : null,
              ),
            ),
          ),
          if (isLoadingLessonDocuments && (isSearchVisible || hasQuery)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Підтягуємо короткі описи та заголовки для точнішого пошуку.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F5A52),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideSearchField extends StatelessWidget {
  const _GuideSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0x1FB45309)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFB45309), width: 1.5),
        ),
      ),
    );
  }
}

class _GuideSectionFilters extends StatelessWidget {
  const _GuideSectionFilters({
    required this.sections,
    required this.selectedSectionId,
    required this.onSelected,
  });

  final List<_GuideSectionOption> sections;
  final String? selectedSectionId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Усі'),
          selected: selectedSectionId == null,
          onSelected: (_) => onSelected(null),
          selectedColor: const Color(0xFFFDE7D4),
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: selectedSectionId == null
                ? const Color(0xFF8C6A2A)
                : const Color(0xFF5F5A52),
          ),
          side: BorderSide.none,
        ),
        ...sections.map(
          (section) => ChoiceChip(
            label: Text(section.label),
            selected: selectedSectionId == section.id,
            onSelected: (_) => onSelected(section.id),
            selectedColor: const Color(0xFFFDE7D4),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: selectedSectionId == section.id
                  ? const Color(0xFF8C6A2A)
                  : const Color(0xFF5F5A52),
            ),
            side: BorderSide.none,
          ),
        ),
      ],
    );
  }
}

class _GuideLessonCard extends StatelessWidget {
  const _GuideLessonCard({
    required this.lesson,
    required this.status,
    required this.resolvedTitle,
    required this.resolvedSummary,
    required this.onTap,
    required this.onStatusSelected,
  });

  final LessonEntry lesson;
  final GuideLessonStatus status;
  final String resolvedTitle;
  final String resolvedSummary;
  final VoidCallback onTap;
  final ValueChanged<GuideLessonStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final statusTheme = _GuideLessonStatusTheme.fromStatus(status);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (lesson.sectionLabel != null) ...[
                      _GuideSectionPill(label: lesson.sectionLabel!),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      resolvedTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (resolvedSummary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        resolvedSummary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5F5A52),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
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
              const SizedBox(width: 8),
              Column(
                children: [
                  _GuideStatusToggleButton(
                    status: status,
                    compact: true,
                    onPressed: () {
                      onStatusSelected(_nextGuideLessonStatus(status));
                    },
                  ),
                  const SizedBox(height: 18),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF8C6A2A),
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

class _GuideOutlineCard extends StatelessWidget {
  const _GuideOutlineCard({required this.headings});

  final List<String> headings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED1)),
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
                        color: const Color(0xFF443D35),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DED1)),
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
                            ? const Color(0xFF9A9288)
                            : const Color(0xFF443D35),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED1)),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F5A52),
              ),
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
    if (resolution.resolvedTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED1)),
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
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
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

class _GuideSectionPill extends StatelessWidget {
  const _GuideSectionPill({
    required this.label,
    this.foregroundColor = const Color(0xFF8C6A2A),
    this.backgroundColor = const Color(0xFFFDE7D4),
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyGuideSearchState extends StatelessWidget {
  const _EmptyGuideSearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 32,
            color: Color(0xFFB45309),
          ),
          const SizedBox(height: 12),
          Text(
            'Нічого не знайдено.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Спробуйте інший запит або скиньте фільтр секції.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F5A52)),
          ),
        ],
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

class _GuideSectionOption {
  const _GuideSectionOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class _GuideRelatedTopicsResolution {
  const _GuideRelatedTopicsResolution({
    required this.resolvedTopics,
  });

  const _GuideRelatedTopicsResolution.empty()
    : resolvedTopics = const <_GuideResolvedTopic>[];

  final List<_GuideResolvedTopic> resolvedTopics;
}

class _GuideResolvedTopic {
  const _GuideResolvedTopic({
    required this.label,
    required this.lesson,
  });

  final String label;
  final LessonEntry lesson;
}
