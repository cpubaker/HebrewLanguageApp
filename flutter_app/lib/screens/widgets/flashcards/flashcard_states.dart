import 'package:flutter/material.dart';

import '../../../services/flashcard_session.dart';
import '../../../theme/app_theme.dart';
import '../practice_completion_card.dart';
import '../practice_header.dart';
import 'flashcard_deck_mode_section.dart';

class FlashcardEmptyState extends StatelessWidget {
  const FlashcardEmptyState({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Картки',
          subtitle:
              'Зараз тут порожньо. Оберіть інший режим або поверніться трохи пізніше.',
        ),
        FlashcardDeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                _emptyTitle(mode),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _emptyBody(mode),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _emptyTitle(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Слова ще не завантажені.';
      case FlashcardDeckMode.withContexts:
        return 'Карток із прикладами поки немає.';
      case FlashcardDeckMode.needsReview:
        return 'На повторенні поки порожньо.';
    }
  }

  String _emptyBody(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Щойно слова з’являться, тут можна буде почати тренування.';
      case FlashcardDeckMode.withContexts:
        return 'Коли для слів з’являться приклади, цей режим стане доступним.';
      case FlashcardDeckMode.needsReview:
        return 'Позначайте слова як «Ще раз», і вони з’являться тут окремо.';
    }
  }
}

class FlashcardCompletedState extends StatelessWidget {
  const FlashcardCompletedState({
    super.key,
    required this.mode,
    required this.wordCount,
    required this.correctAnswers,
    required this.repeatAnswers,
    required this.reviewWordCount,
    required this.onRestartDeck,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final int wordCount;
  final int correctAnswers;
  final int repeatAnswers;
  final int reviewWordCount;
  final void Function([FlashcardDeckMode? mode]) onRestartDeck;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Картки',
          subtitle:
              'Цю колоду вже пройдено. Можна почати ще раз або перейти далі.',
        ),
        FlashcardDeckModeSection(selectedMode: mode, onChanged: onChanged),
        const SizedBox(height: 18),
        PracticeCompletionCard(
          badgeLabel: 'Готово',
          title: '$wordCount карток пройдено',
          body: _completionBody(mode, reviewWordCount),
          stats: [
            PracticeCompletionStat(
              label: 'Знаю',
              value: correctAnswers,
              icon: Icons.check_rounded,
              accent: tokens.successAccent,
            ),
            PracticeCompletionStat(
              label: 'Повторити',
              value: repeatAnswers,
              icon: Icons.refresh_rounded,
              accent: tokens.warningAccent,
            ),
          ],
          primaryAction: PracticeCompletionAction(
            label: 'Почати ще раз',
            icon: Icons.refresh_rounded,
            onPressed: () => onRestartDeck(),
          ),
          secondaryAction:
              mode != FlashcardDeckMode.needsReview && reviewWordCount > 0
              ? PracticeCompletionAction(
                  label: 'До повторення',
                  icon: Icons.rule_rounded,
                  onPressed: () => onRestartDeck(FlashcardDeckMode.needsReview),
                  style: PracticeCompletionActionStyle.outlined,
                )
              : null,
        ),
      ],
    );
  }

  String _completionBody(FlashcardDeckMode mode, int reviewWordCount) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        if (reviewWordCount > 0) {
          return 'На повторення чекають $reviewWordCount карток.';
        }
        return 'Усі слова з цієї колоди вже переглянуті.';
      case FlashcardDeckMode.withContexts:
        if (reviewWordCount > 0) {
          return 'Після цього проходу $reviewWordCount карток перейшли на повторення.';
        }
        return 'Усі картки з прикладами вже пройдені.';
      case FlashcardDeckMode.needsReview:
        return 'Ви вже все повторили.';
    }
  }
}
