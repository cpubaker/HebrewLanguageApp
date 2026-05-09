part of '../../home_screen.dart';

class _VocabularyPreviewCard extends StatelessWidget {
  const _VocabularyPreviewCard({required this.words});

  final List<LearningWord> words;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Словник',
            subtitle: 'Повний список слів із пошуком і позначками прогресу.',
          ),
          const SizedBox(height: 14),
          Column(
            children: words
                .take(6)
                .map((word) => _WordTile(word: word))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ReadingPreviewCard extends StatelessWidget {
  const _ReadingPreviewCard({
    required this.lessons,
    required this.documentLoader,
    required this.onOpenLesson,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;
  final ValueChanged<LessonEntry> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final previewLessons = sortReadingLessons(lessons).take(3);

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Що почитати',
            subtitle: 'Кілька уроків, з яких зручно продовжити просто зараз.',
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              ...previewLessons.map(
                (lesson) => _ReadingLessonTile(
                  lesson: lesson,
                  documentLoader: documentLoader,
                  onTap: () => onOpenLesson(lesson),
                ),
              ),
            ],
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
    final tokens = theme.appTokens;
    final learningState = classifyWordLearningState(word);
    final status = switch (learningState) {
      WordLearningState.unseen => (
        label: 'Нове',
        color: tokens.newContentAccent,
        background: tokens.wordNewSurface,
      ),
      WordLearningState.known => (
        label: 'Вивчене',
        color: tokens.successAccent,
        background: tokens.wordKnownSurface,
      ),
      WordLearningState.needsReview => (
        label: 'Повторити',
        color: tokens.warningAccent,
        background: tokens.wordReviewSurface,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).appTokens.subtleSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.translation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.transcription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).appTokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w700,
                      ),
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
                color: theme.colorScheme.primary,
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
    required this.onTap,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final level = readingLevelLabelFromAssetPath(lesson.assetPath);
    final fallbackTitle = readingLessonTitle(lesson);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).appTokens.subtleSurface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tokens.accentMediumSurface(tokens.contextAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: tokens.contextAccent,
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
                              document != null &&
                                  document.title.trim().isNotEmpty
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
                          color: Theme.of(context).appTokens.mutedText,
                        ),
                      ),
                    ],
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
