import 'package:flutter/material.dart';

import '../models/generated_practice_text.dart';
import '../models/learning_word.dart';
import '../services/ai_practice_text_service.dart';
import '../theme/app_theme.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_section_card.dart';
import 'widgets/practice_panel.dart';

class AiPracticeTextScreen extends StatefulWidget {
  const AiPracticeTextScreen({
    super.key,
    required this.words,
    required this.textService,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
  });

  final List<LearningWord> words;
  final AiPracticeTextService textService;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenWriting;

  @override
  State<AiPracticeTextScreen> createState() => _AiPracticeTextScreenState();
}

class _AiPracticeTextScreenState extends State<AiPracticeTextScreen> {
  late Future<List<GeneratedPracticeText>> _textsFuture;

  @override
  void initState() {
    super.initState();
    _textsFuture = _loadTexts();
  }

  Future<List<GeneratedPracticeText>> _loadTexts() {
    return widget.textService.textsForRequest(
      AiPracticeTextRequest(
        words: widget.words,
        level: 'adaptive',
        mode: 'practice_hub',
        maxTexts: 1,
      ),
    );
  }

  void _refresh() {
    setState(() {
      _textsFuture = _loadTexts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return FutureBuilder<List<GeneratedPracticeText>>(
      future: _textsFuture,
      builder: (context, snapshot) {
        return ListView(
          padding: tokens.pagePadding.copyWith(bottom: 32),
          children: [
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppPageHeader(
                    title: 'Текст зі словами',
                    subtitle:
                        'Короткий текст на івриті з поточними словами, перекладом і переходом до вправ.',
                  ),
                  const SizedBox(height: 18),
                  _TargetWordsPanel(words: widget.words),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState != ConnectionState.done)
              const _LoadingPanel()
            else if (snapshot.hasError)
              _ErrorPanel(onRetry: _refresh)
            else if ((snapshot.data ?? const <GeneratedPracticeText>[]).isEmpty)
              _EmptyPanel(onRetry: _refresh)
            else
              _GeneratedTextPanel(
                text: snapshot.data!.first,
                words: widget.words,
                onRefresh: _refresh,
                onOpenFlashcards: widget.onOpenFlashcards,
                onOpenWriting: widget.onOpenWriting,
              ),
          ],
        );
      },
    );
  }
}

class _TargetWordsPanel extends StatelessWidget {
  const _TargetWordsPanel({required this.words});

  final List<LearningWord> words;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final visibleWords = words.take(12).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Слова для тексту',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final word in visibleWords)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: tokens.subtleSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: tokens.outlineSoft),
                ),
                child: Text(
                  '${word.hebrew} · ${word.translation}',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GeneratedTextPanel extends StatelessWidget {
  const _GeneratedTextPanel({
    required this.text,
    required this.words,
    required this.onRefresh,
    required this.onOpenFlashcards,
    required this.onOpenWriting,
  });

  final GeneratedPracticeText text;
  final List<LearningWord> words;
  final VoidCallback onRefresh;
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenWriting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final usedWords = _usedWords();

    return PracticePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  text.title.trim().isEmpty ? 'Текст для практики' : text.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (text.isNew) const _NewTextBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text.hebrew,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.55,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.subtleSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              text.translation,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: tokens.secondaryText,
              ),
            ),
          ),
          if (usedWords.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'У тексті',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final word in usedWords)
                  Chip(
                    label: Text('${word.hebrew} · ${word.translation}'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          AppActionWrap(
            children: [
              FilledButton.icon(
                onPressed: onOpenFlashcards,
                icon: const Icon(Icons.style_rounded),
                label: const Text('Картки'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenWriting,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Написання'),
              ),
              IconButton.filledTonal(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Оновити текст',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<LearningWord> _usedWords() {
    final wordIds = text.wordIds.toSet();
    if (wordIds.isEmpty) {
      return const <LearningWord>[];
    }

    return words
        .where((word) => wordIds.contains(word.wordId))
        .toList(growable: false);
  }
}

class _NewTextBadge extends StatelessWidget {
  const _NewTextBadge();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            'Нове!',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return PracticePanel(
      backgroundColor: tokens.subtleSurface,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      title: 'Текст ще не згенеровано',
      message:
          'Перевірте endpoint для ШІ-текстів або спробуйте оновити запит пізніше.',
      icon: Icons.auto_awesome_outlined,
      actionLabel: 'Спробувати ще раз',
      onAction: onRetry,
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      title: 'Не вдалося отримати текст',
      message: 'Збережена практика лишається доступною. Спробуйте ще раз.',
      icon: Icons.cloud_off_rounded,
      actionLabel: 'Повторити',
      onAction: onRetry,
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.title,
    required this.message,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return PracticePanel(
      backgroundColor: tokens.subtleSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: tokens.mutedText),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
