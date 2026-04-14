import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/lesson_document_loader.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'reading_lesson_catalog.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_metric_tile.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.bundle,
    required this.documentLoader,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final LessonDocumentLoader documentLoader;
  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    final pagePadding = Theme.of(context).appTokens.pagePadding;
    final progress = StudyProgressSnapshot.fromWords(bundle.words);
    final flashcards = FlashcardFocusSnapshot.fromWords(bundle.words);
    final readingPreviewLessons = sortReadingLessons(
      bundle.readingLessons,
    ).take(3);
    final continueAction = _buildContinueAction(
      progress: progress,
      flashcards: flashcards,
    );
    final recommendedActions = _buildRecommendedActions(
      progress: progress,
      flashcards: flashcards,
    );

    return ListView(
      padding: pagePadding.copyWith(bottom: 32),
      children: [
        _HeroPanel(bundle: bundle),
        const SizedBox(height: 20),
        _DashboardPrimaryActionCard(action: continueAction),
        const SizedBox(height: 16),
        _DashboardRecommendationsCard(
          actions: recommendedActions,
        ),
        const SizedBox(height: 16),
        _QuickActionStrip(
          onOpenWords: onOpenWords,
          onOpenFlashcards: onOpenFlashcards,
          onOpenWriting: onOpenWriting,
          onOpenGuide: onOpenGuide,
          onOpenVerbs: onOpenVerbs,
          onOpenReading: onOpenReading,
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
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Слова під рукою',
                subtitle: 'Швидкий перехід до словника з пошуком і прогресом.',
              ),
              const SizedBox(height: 14),
              Column(
                children: bundle.words
                    .take(6)
                    .map((word) => _WordTile(word: word))
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InventoryOverviewCard(
          bundle: bundle,
          onOpenWords: onOpenWords,
          onOpenFlashcards: () => onOpenFlashcards(FlashcardDeckMode.allWords),
          onOpenWriting: onOpenWriting,
          onOpenGuide: onOpenGuide,
          onOpenVerbs: onOpenVerbs,
          onOpenReading: onOpenReading,
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Що почитати',
                subtitle:
                    'Кілька уроків, з яких зручно продовжити просто зараз.',
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  ...readingPreviewLessons.map(
                    (lesson) => _ReadingLessonTile(
                      lesson: lesson,
                      documentLoader: documentLoader,
                    ),
                  ),
                ],
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

  _DashboardAction _buildContinueAction({
    required StudyProgressSnapshot progress,
    required FlashcardFocusSnapshot flashcards,
  }) {
    if (flashcards.needsReview > 0) {
      return _DashboardAction(
        title: 'Продовжити повторення',
        subtitle:
            '${flashcards.needsReview} слів чекають у картках на повторення.',
        buttonLabel: 'До повторення',
        icon: Icons.refresh_rounded,
        accent: const Color(0xFFB45309),
        onTap: () => onOpenFlashcards(FlashcardDeckMode.needsReview),
      );
    }

    if (progress.unseen > 0) {
      return _DashboardAction(
        title: 'Почати нові слова',
        subtitle: '${progress.unseen} слів ще не відкривали в тренуванні.',
        buttonLabel: 'До карток',
        icon: Icons.style_rounded,
        accent: const Color(0xFF0F766E),
        onTap: () => onOpenFlashcards(FlashcardDeckMode.allWords),
      );
    }

    if (bundle.readingLessons.isNotEmpty) {
      return _DashboardAction(
        title: 'Почитати далі',
        subtitle: 'У бібліотеці вже є тексти, з яких можна продовжити.',
        buttonLabel: 'До читання',
        icon: Icons.auto_stories_rounded,
        accent: const Color(0xFF1D4ED8),
        onTap: onOpenReading,
      );
    }

    return _DashboardAction(
      title: 'Повернутися до словника',
      subtitle: 'Перегляньте слова, щоб обрати наступний напрям навчання.',
      buttonLabel: 'До слів',
      icon: Icons.translate_rounded,
      accent: const Color(0xFF2B5D4F),
      onTap: onOpenWords,
    );
  }

  List<_DashboardAction> _buildRecommendedActions({
    required StudyProgressSnapshot progress,
    required FlashcardFocusSnapshot flashcards,
  }) {
    final actions = <_DashboardAction>[
      _DashboardAction(
        title: 'Картки з прикладами',
        subtitle: flashcards.withContexts > 0
            ? '${flashcards.withContexts} слів уже мають контекст для практики.'
            : 'Контекстні картки з’являтимуться, коли для слів буде більше прикладів.',
        buttonLabel: 'Відкрити',
        icon: Icons.chat_bubble_outline_rounded,
        accent: const Color(0xFF1D4ED8),
        onTap: () => onOpenFlashcards(FlashcardDeckMode.withContexts),
      ),
      _DashboardAction(
        title: 'Письмо',
        subtitle: progress.seen > 0
            ? 'Закріпіть знайомі слова через пригадування і написання.'
            : 'Після перших карток тут буде зручно перевіряти пригадування.',
        buttonLabel: 'Тренувати',
        icon: Icons.edit_rounded,
        accent: const Color(0xFF8C3E9F),
        onTap: onOpenWriting,
      ),
      _DashboardAction(
        title: 'Матеріали',
        subtitle: bundle.guideLessons.isNotEmpty
            ? 'У довіднику й читанні вже є теми для наступного кроку.'
            : 'Матеріали з’являться тут, коли їх буде завантажено.',
        buttonLabel: 'Відкрити',
        icon: Icons.menu_book_rounded,
        accent: const Color(0xFFB45309),
        onTap: onOpenGuide,
      ),
    ];

    return actions;
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
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
          const SizedBox(height: 16),
          AppActionWrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppStatChip(
                label: 'Слова',
                value: bundle.words.length,
                accent: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                textColor: Colors.white,
              ),
              AppStatChip(
                label: 'Читання',
                value: bundle.readingLessons.length,
                accent: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                textColor: Colors.white,
              ),
              AppStatChip(
                label: 'Дієслова',
                value: bundle.verbLessons.length,
                accent: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                textColor: Colors.white,
              ),
            ],
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
    final tokens = Theme.of(context).appTokens;
    final card = Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
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
                borderRadius: BorderRadius.circular(tokens.panelRadius + 2),
                onTap: onTap,
                child: card,
              ),
      ),
    );
  }
}

class _QuickActionStrip extends StatelessWidget {
  const _QuickActionStrip({
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final VoidCallback onOpenWords;
  final ValueChanged<FlashcardDeckMode> onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Швидкі дії',
            subtitle: 'Основні переходи для поточного навчального циклу.',
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              FilledButton.icon(
                onPressed: () => onOpenFlashcards(FlashcardDeckMode.allWords),
                icon: const Icon(Icons.style_rounded),
                label: const Text('До карток'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWriting,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('До письма'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWords,
                icon: const Icon(Icons.translate_rounded),
                label: const Text('До слів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenVerbs,
                icon: const Icon(Icons.play_lesson_rounded),
                label: const Text('До дієслів'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenGuide,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('До довідника'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenReading,
                icon: const Icon(Icons.auto_stories_rounded),
                label: const Text('До читання'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardPrimaryActionCard extends StatelessWidget {
  const _DashboardPrimaryActionCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: action.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Продовжити',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF6C665D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: action.onTap,
                  icon: Icon(action.icon),
                  label: Text(action.buttonLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRecommendationsCard extends StatelessWidget {
  const _DashboardRecommendationsCard({required this.actions});

  final List<_DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Що далі',
            subtitle: 'Кілька наступних кроків, які добре працюють разом.',
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < actions.length; index += 1) ...[
            _DashboardRecommendationTile(action: actions[index]),
            if (index != actions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DashboardRecommendationTile extends StatelessWidget {
  const _DashboardRecommendationTile({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: action.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: action.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: action.onTap,
            child: Text(action.buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _InventoryOverviewCard extends StatelessWidget {
  const _InventoryOverviewCard({
    required this.bundle,
    required this.onOpenWords,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
    required this.onOpenGuide,
    required this.onOpenVerbs,
    required this.onOpenReading,
  });

  final LearningBundle bundle;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenWriting;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenVerbs;
  final VoidCallback onOpenReading;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Усі модулі',
            subtitle: 'Повна база застосунку лишається під рукою як довідкова карта.',
          ),
          const SizedBox(height: 16),
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
                onTap: onOpenFlashcards,
              ),
              _SummaryCard(
                label: 'Письмо',
                value: bundle.words
                    .where(
                      (word) => word.writingCorrect > 0 || word.writingWrong > 0,
                    )
                    .length,
                accent: const Color(0xFF8C3E9F),
                onTap: onOpenWriting,
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
        ],
      ),
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

  final FlashcardFocusSnapshot snapshot;
  final VoidCallback onOpenAll;
  final VoidCallback? onOpenContext;
  final VoidCallback? onOpenReview;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Картки на сьогодні',
            subtitle: snapshot.needsReview > 0
                ? 'У вас є слова на повторення. Можна продовжити або перейти до карток із прикладами.'
                : 'Оберіть режим: усі слова або картки з прикладами.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppMetricTile(
                label: 'Усі',
                value: snapshot.total,
                accent: const Color(0xFF163832),
              ),
              AppMetricTile(
                label: 'З прикладами',
                value: snapshot.withContexts,
                accent: const Color(0xFF1D4ED8),
              ),
              AppMetricTile(
                label: 'На повторенні',
                value: snapshot.needsReview,
                accent: const Color(0xFFB45309),
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: snapshot.known,
                accent: const Color(0xFF0F766E),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppActionWrap(
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

  final StudyProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Ваш поступ',
            subtitle:
                'Прогрес зберігається на цьому пристрої, тож можна спокійно продовжити пізніше.',
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
              AppMetricTile(
                label: 'Опрацьовані',
                value: progress.seen,
                accent: const Color(0xFF1D4ED8),
              ),
              AppMetricTile(
                label: 'Вивчені',
                value: progress.known,
                accent: const Color(0xFF0F766E),
              ),
              AppMetricTile(
                label: 'Повторити',
                value: progress.needsReview,
                accent: const Color(0xFFB45309),
              ),
              AppMetricTile(
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

class _WordTile extends StatelessWidget {
  const _WordTile({required this.word});

  final LearningWord word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final learningState = classifyWordLearningState(word);
    final status = switch (learningState) {
      WordLearningState.unseen => (
          label: 'Нове',
          color: const Color(0xFF7C3AED),
          background: const Color(0xFFF3E8FF),
        ),
      WordLearningState.known => (
          label: 'Вивчене',
          color: const Color(0xFF0F766E),
          background: const Color(0xFFE7F8F2),
        ),
      WordLearningState.needsReview => (
          label: 'Повторити',
          color: const Color(0xFFB45309),
          background: const Color(0xFFFFF1E6),
        ),
    };

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
                    word.translation,
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
