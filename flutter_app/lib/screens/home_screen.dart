import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/learning_word.dart';
import 'reading_lesson_catalog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final progress = _StudyProgressSnapshot.fromWords(bundle.words);
    final readingPreviewLessons = sortReadingLessons(bundle.readingLessons).take(3);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _HeroPanel(bundle: bundle),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Words',
              value: bundle.words.length,
              accent: const Color(0xFF0F766E),
              onTap: onOpenWords,
            ),
            _SummaryCard(
              label: 'Flashcards',
              value: bundle.words.where((word) => word.contexts.isNotEmpty).length,
              accent: const Color(0xFFBE5B00),
              onTap: onOpenFlashcards,
            ),
            _SummaryCard(
              label: 'Guide',
              value: bundle.guideLessons.length,
              accent: const Color(0xFFB45309),
              onTap: onOpenGuide,
            ),
            _SummaryCard(
              label: 'Verbs',
              value: bundle.verbLessons.length,
              accent: const Color(0xFF7C3AED),
              onTap: onOpenVerbs,
            ),
            _SummaryCard(
              label: 'Reading',
              value: bundle.readingLessons.length,
              accent: const Color(0xFF1D4ED8),
              onTap: onOpenReading,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ActionStrip(
          onOpenWords: onOpenWords,
          onOpenFlashcards: onOpenFlashcards,
          onOpenGuide: onOpenGuide,
        ),
        const SizedBox(height: 20),
        _StudyProgressCard(progress: progress),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Vocabulary Preview',
          subtitle:
              'The first real mobile screen is now the searchable Words tab.',
          child: Column(
            children: bundle.words
                .take(6)
                .map((word) => _WordTile(word: word))
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Reading Preview',
          subtitle:
              'Continue with the synced mobile reading lessons right from the home screen.',
          child: Column(
            children: [
              ...readingPreviewLessons
                  .map((lesson) => _ReadingLessonTile(lesson: lesson)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onOpenReading,
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('Open Reading'),
          ),
        ),
      ],
    );
  }
}

class _StudyProgressSnapshot {
  const _StudyProgressSnapshot({
    required this.total,
    required this.seen,
    required this.known,
    required this.needsReview,
    required this.unseen,
  });

  factory _StudyProgressSnapshot.fromWords(List<LearningWord> words) {
    var seen = 0;
    var known = 0;
    var needsReview = 0;

    for (final word in words) {
      final attempts = word.correct + word.wrong;
      if (attempts > 0) {
        seen += 1;
      }

      if (word.wrong > 0 || word.wrong > word.correct) {
        needsReview += 1;
      } else if (word.correct > 0) {
        known += 1;
      }
    }

    return _StudyProgressSnapshot(
      total: words.length,
      seen: seen,
      known: known,
      needsReview: needsReview,
      unseen: words.length - seen,
    );
  }

  final int total;
  final int seen;
  final int known;
  final int needsReview;
  final int unseen;

  double get completionRatio => total == 0 ? 0 : seen / total;
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.bundle,
  });

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF163832),
            Color(0xFF2B5D4F),
            Color(0xFF8C6A2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Android Migration',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hebrew Language App',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The app now has a shared mobile shell, bottom navigation, and a first interactive Flashcards flow. Tkinter still remains the desktop reference while Flutter grows feature by feature.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFF7F3E8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${bundle.words.length} words synced from the desktop dataset',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: 156,
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? card
            : InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: card,
              ),
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenGuide,
  });

  final VoidCallback onOpenWords;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onOpenFlashcards,
          icon: const Icon(Icons.style_rounded),
          label: const Text('Start Flashcards'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenWords,
          icon: const Icon(Icons.translate_rounded),
          label: const Text('Open Words'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenGuide,
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('Open Guide'),
        ),
      ],
    );
  }
}

class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({
    required this.progress,
  });

  final _StudyProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'This device now remembers your flashcard progress between launches.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.completionRatio,
              backgroundColor: const Color(0xFFEAE2D2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.seen} of ${progress.total} words have progress on this device',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ProgressMetric(
                label: 'Seen',
                value: progress.seen,
                accent: const Color(0xFF1D4ED8),
              ),
              _ProgressMetric(
                label: 'Known',
                value: progress.known,
                accent: const Color(0xFF0F766E),
              ),
              _ProgressMetric(
                label: 'Needs Review',
                value: progress.needsReview,
                accent: const Color(0xFFB45309),
              ),
              _ProgressMetric(
                label: 'Unseen',
                value: progress.unseen,
                accent: const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F5A52),
                ),
          ),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.word,
  });

  final LearningWord word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3E8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.transcription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              word.hebrew,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF163832),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingLessonTile extends StatelessWidget {
  const _ReadingLessonTile({
    required this.lesson,
  });

  final LessonEntry lesson;

  @override
  Widget build(BuildContext context) {
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final title = readingLessonTitle(lesson);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
          ],
        ),
      ),
    );
  }
}
