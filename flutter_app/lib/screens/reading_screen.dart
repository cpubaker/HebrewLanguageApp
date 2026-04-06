import 'dart:async';

import 'package:flutter/material.dart';

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
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ScrollController _scrollController;

  final Map<String, String> _lessonTitles = <String, String>{};

  String? _selectedLevelKey;
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

  @override
  Widget build(BuildContext context) {
    final lessonGroups = buildReadingLessonGroups(widget.lessons);
    final visibleGroups = _selectedLevelKey == null
        ? lessonGroups
        : lessonGroups
              .where((group) => group.levelKey == _selectedLevelKey)
              .toList(growable: false);
    final visibleLessonCount = visibleGroups.fold<int>(
      0,
      (count, group) => count + group.lessons.length,
    );
    ReadingLessonGroup? selectedGroup;
    if (_selectedLevelKey != null) {
      for (final group in lessonGroups) {
        if (group.levelKey == _selectedLevelKey) {
          selectedGroup = group;
          break;
        }
      }
    }

    final itemCount = visibleGroups.length + 7;

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
                    Text(
                      _selectedLevelKey == null
                          ? '\u0423\u0440\u043e\u043a\u0456\u0432: ${widget.lessons.length}'
                          : '\u041f\u043e\u043a\u0430\u0437\u0430\u043d\u043e: $visibleLessonCount',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }

            if (index == 4) {
              return const SizedBox(height: 18);
            }

            if (index == 5) {
              return _ReadingLevelSelector(
                selectedLabel: selectedGroup?.levelLabel ?? '\u0423\u0441\u0456 \u0440\u0456\u0432\u043d\u0456',
                selectedCount: selectedGroup?.lessons.length ?? widget.lessons.length,
                onTap: () => _showLevelPicker(context, lessonGroups),
              );
            }

            if (index == 6) {
              return const SizedBox(height: 18);
            }

            final group = visibleGroups[index - 7];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _ReadingLevelSection(
                group: group,
                documentLoader: widget.documentLoader,
                titleResolver: _resolvedLessonTitle,
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            offset: _showScrollToTop ? Offset.zero : const Offset(0, 0.25),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _showScrollToTop ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showScrollToTop,
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
      ],
    );
  }

  Future<void> _showLevelPicker(
    BuildContext context,
    List<ReadingLessonGroup> lessonGroups,
  ) async {
    final selectedLevelKey = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
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
                  selected: _selectedLevelKey == null,
                  onTap: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                const SizedBox(height: 10),
                ...lessonGroups.expand(
                  (group) => [
                    _ReadingLevelOption(
                      label: group.levelLabel,
                      count: group.lessons.length,
                      selected: _selectedLevelKey == group.levelKey,
                      onTap: () {
                        Navigator.of(context).pop(group.levelKey);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLevelKey = selectedLevelKey;
    });
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
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonDocument>(
        future: documentLoader.load(lesson.assetPath),
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
          return ListView(
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
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
    required this.resolvedTitle,
    required this.onTap,
  });

  final LessonEntry lesson;
  final String resolvedTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final orderLabel = readingLessonOrderLabel(lesson);

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
                      resolvedTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
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

class _ReadingLevelSection extends StatelessWidget {
  const _ReadingLevelSection({
    required this.group,
    required this.documentLoader,
    required this.titleResolver,
  });

  final ReadingLessonGroup group;
  final LessonDocumentLoader documentLoader;
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
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReadingLessonCard(
              lesson: lesson,
              resolvedTitle: titleResolver(lesson),
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

class _ReadingLevelSelector extends StatelessWidget {
  const _ReadingLevelSelector({
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
