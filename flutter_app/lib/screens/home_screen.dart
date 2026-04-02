import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/lesson_document_loader.dart';
import 'reading_lesson_catalog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.bundle,
    required this.documentLoader,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final LessonDocumentLoader documentLoader;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final progress = _StudyProgressSnapshot.fromWords(bundle.words);
    final flashcards = _FlashcardFocusSnapshot.fromWords(bundle.words);
    final readingPreviewLessons = sortReadingLessons(
      bundle.readingLessons,
    ).take(3);

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
              label: 'Слова',
              value: bundle.words.length,
              accent: const Color(0xFF0F766E),
              onTap: onOpenWords,
            ),
            _SummaryCard(
              label: 'Картки',
              value: bundle.words
                  .where((word) => word.contexts.isNotEmpty)
                  .length,
              accent: const Color(0xFFBE5B00),
              onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
            ),
            _SummaryCard(
              label: 'Довідник',
              value: bundle.guideLessons.length,
              accent: const Color(0xFFB45309),
              onTap: onOpenGuide,
            ),
            _SummaryCard(
              label: 'Дієслова',
              value: bundle.verbLessons.length,
              accent: const Color(0xFF7C3AED),
              onTap: onOpenVerbs,
            ),
            _SummaryCard(
              label: 'Читання',
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
        _FlashcardFocusCard(
          snapshot: flashcards,
          onOpenAll: () => onOpenFlashcards(FlashcardDeckMode.allWords),
          onOpenContext: flashcards.withContexts > 0
              ? () => onOpenFlashcards(FlashcardDeckMode.withContexts)
              : null,
          onOpenReview: flashcards.needsReview > 0
              ? () => onOpenFlashcards(FlashcardDeckMode.needsReview)
              : null,
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Слова під рукою',
          subtitle: 'Швидкий перехід до словника з пошуком і прогресом.',
          child: Column(
            children: bundle.words
                .take(6)
                .map((word) => _WordTile(word: word))
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Що почитати',
          subtitle: 'Кілька уроків, з яких зручно продовжити просто зараз.',
          child: Column(
            children: [
              ...readingPreviewLessons.map(
                (lesson) => _ReadingLessonTile(
                  lesson: lesson,
                  documentLoader: documentLoader,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onOpenReading,
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('До читання'),
          ),
        ),
      ],
    );
  }
}

class _FlashcardFocusSnapshot {
  const _FlashcardFocusSnapshot({
    required this.total,
    required this.withContexts,
    required this.needsReview,
    required this.known,
  });

  factory _FlashcardFocusSnapshot.fromWords(List<LearningWord> words) {
    var withContexts = 0;
    var needsReview = 0;
    var known = 0;

    for (final word in words) {
      if (word.contexts.isNotEmpty) {
        withContexts += 1;
      }

      if (word.wrong > 0 || word.wrong > word.correct) {
        needsReview += 1;
      } else if (word.correct > 0) {
        known += 1;
      }
    }

    return _FlashcardFocusSnapshot(
      total: words.length,
      withContexts: withContexts,
      needsReview: needsReview,
      known: known,
    );
  }

  final int total;
  final int withContexts;
  final int needsReview;
  final int known;
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
  const _HeroPanel({required this.bundle});

  final LearningBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF163832), Color(0xFF2B5D4F), Color(0xFF8C6A2A)],
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
              'Мобільна версія',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Вчимо іврит',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'У мобільній версії вже є слова, картки, довідник, дієслова й читання. Усе працює з тією самою навчальною базою, що й десктопний застосунок.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFF7F3E8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${bundle.words.length} слів уже доступні на цьому пристрої',
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F5A52)),
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
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => onOpenFlashcards(FlashcardDeckMode.allWords),
          icon: const Icon(Icons.style_rounded),
          label: const Text('До карток'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenWords,
          icon: const Icon(Icons.translate_rounded),
          label: const Text('До слів'),
        ),
        OutlinedButton.icon(
          onPressed: onOpenGuide,
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('До довідника'),
        ),
      ],
    );
  }
}

class _FlashcardFocusCard extends StatelessWidget {
  const _FlashcardFocusCard({
    required this.snapshot,
    required this.onOpenAll,
    required this.onOpenContext,
    required this.onOpenReview,
  });

  final _FlashcardFocusSnapshot snapshot;
  final VoidCallback onOpenAll;
  final VoidCallback? onOpenContext;
  final VoidCallback? onOpenReview;

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
            'Картки на сьогодні',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.needsReview > 0
                ? 'У вас є слова на повторення. Можна продовжити або перейти до карток із прикладами.'
                : 'Оберіть режим: усі слова або картки з прикладами.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5F5A52),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ProgressMetric(
                label: 'Усі',
                value: snapshot.total,
                accent: const Color(0xFF163832),
              ),
              _ProgressMetric(
                label: 'З прикладами',
                value: snapshot.withContexts,
                accent: const Color(0xFF1D4ED8),
              ),
              _ProgressMetric(
                label: 'На повторенні',
                value: snapshot.needsReview,
                accent: const Color(0xFFB45309),
              ),
              _ProgressMetric(
                label: 'Вивчені',
                value: snapshot.known,
                accent: const Color(0xFF0F766E),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (onOpenReview != null)
                FilledButton.icon(
                  onPressed: onOpenReview,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Продовжити'),
                ),
              OutlinedButton.icon(
                onPressed: onOpenContext,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('З прикладами'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenAll,
                icon: const Icon(Icons.style_outlined),
                label: const Text('Усі'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({required this.progress});

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
            'Ваш поступ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Прогрес зберігається на цьому пристрої, тож можна спокійно продовжити пізніше.',
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Опрацьовано ${progress.seen} із ${progress.total} слів',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C665D)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ProgressMetric(
                label: 'Опрацьовані',
                value: progress.seen,
                accent: const Color(0xFF1D4ED8),
              ),
              _ProgressMetric(
                label: 'Вивчені',
                value: progress.known,
                accent: const Color(0xFF0F766E),
              ),
              _ProgressMetric(
                label: 'Повторити',
                value: progress.needsReview,
                accent: const Color(0xFFB45309),
              ),
              _ProgressMetric(
                label: 'Нові',
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F5A52)),
          ),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.word});

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
    required this.documentLoader,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;

  @override
  Widget build(BuildContext context) {
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final fallbackTitle = readingLessonTitle(lesson);

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
                  FutureBuilder<LessonDocument>(
                    future: documentLoader.load(lesson.assetPath),
                    builder: (context, snapshot) {
                      final document = snapshot.data;
                      final resolvedTitle =
                          document != null && document.title.trim().isNotEmpty
                          ? document.title.trim()
                          : fallbackTitle;

                      return Text(
                        resolvedTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      );
                    },
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
