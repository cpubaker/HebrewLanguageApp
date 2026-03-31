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
  String? _selectedLevelKey;

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
                _selectedLevelKey == null
                    ? '${widget.lessons.length} reading lessons available'
                    : '$visibleLessonCount reading lessons shown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ReadingLevelSelector(
          selectedLabel: selectedGroup?.levelLabel ?? 'All levels',
          selectedCount: selectedGroup?.lessons.length ?? widget.lessons.length,
          onTap: () => _showLevelPicker(context, lessonGroups),
        ),
        const SizedBox(height: 18),
        ...visibleGroups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _ReadingLevelSection(
              group: group,
              documentLoader: widget.documentLoader,
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
                  'Choose reading level',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Focus on one difficulty level or keep the full catalog visible.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F5A52),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 16),
                _ReadingLevelOption(
                  label: 'All levels',
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
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final orderLabel = readingLessonOrderLabel(lesson);
    final titleLabel = readingLessonTitle(lesson);

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
                      titleLabel,
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

class _ReadingLevelSection extends StatelessWidget {
  const _ReadingLevelSection({
    required this.group,
    required this.documentLoader,
  });

  final ReadingLessonGroup group;
  final LessonDocumentLoader documentLoader;

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level',
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
                      '$count lessons',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5F5A52),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
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
