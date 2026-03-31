import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.words,
  });

  final List<LearningWord> words;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late final FlashcardSession _session;

  FlashcardCard? _currentCard;
  FlashcardAnswerResult? _currentAnswer;

  @override
  void initState() {
    super.initState();
    _session = FlashcardSession(widget.words);
    _moveToNextCard();
  }

  void _moveToNextCard() {
    setState(() {
      _currentCard = _session.nextCard();
      _currentAnswer = null;
    });
  }

  void _answerCard(bool known) {
    setState(() {
      _currentAnswer = _session.answerCard(known);
    });
  }

  void _changeDeckMode(FlashcardDeckMode mode) {
    setState(() {
      _session.setDeckMode(mode);
      _currentCard = _session.nextCard();
      _currentAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _currentCard;
    if (currentCard == null) {
      return _EmptyFlashcardsState(
        mode: _session.deckMode,
        onChanged: _changeDeckMode,
      );
    }

    final word = _currentAnswer?.word ?? currentCard.word;
    final currentContext = _currentAnswer?.context ?? currentCard.context;
    final stats = _session.currentWordStats();
    final hasAnswered = _currentAnswer != null;
    final isKnownAnswer = _currentAnswer?.known == true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Flashcards',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Step through vocabulary one card at a time. Choose a deck, decide first, then reveal the answer and move on.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.45,
              ),
        ),
        const SizedBox(height: 18),
        _DeckModeSection(
          selectedMode: _session.deckMode,
          onChanged: _changeDeckMode,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FlashcardPill(
              label: 'Words',
              value: _session.wordCount,
              accent: const Color(0xFF0F766E),
            ),
            _FlashcardPill(
              label: 'With Context',
              value: _session.wordsWithContextsCount,
              accent: const Color(0xFF1D4ED8),
            ),
            _FlashcardPill(
              label: 'Answered',
              value: _session.answeredCount,
              accent: const Color(0xFF8C6A2A),
            ),
            _FlashcardPill(
              label: 'Seen',
              value: _session.seenCount,
              accent: const Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF163832).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _deckLabel(_session.deckMode),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF163832),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: _session.sessionProgress == 0 ? 0.02 : _session.sessionProgress,
                  backgroundColor: const Color(0xFFE9E2D3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Seen ${_session.seenCount} of ${_session.wordCount} cards in this deck',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                word.hebrew,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF163832),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                word.transcription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
              ),
              const SizedBox(height: 20),
              _FlashcardContextPanel(
                context: currentContext,
                isAnswerRevealed: hasAnswered,
              ),
              const SizedBox(height: 18),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _answerPanelColor(hasAnswered, isKnownAnswer),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      _answerHeadline(hasAnswered, isKnownAnswer),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5F5A52),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasAnswered ? word.english : 'Tap Know or Repeat to reveal the translation.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: hasAnswered
                                ? const Color(0xFF163832)
                                : const Color(0xFF7A746A),
                          ),
                    ),
                    if (hasAnswered && stats.lastCorrect != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Last known: ${_formatLastCorrect(stats.lastCorrect!)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6C665D),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _FlashcardPill(
                      label: 'Correct',
                      value: stats.correct,
                      accent: const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FlashcardPill(
                      label: 'Wrong',
                      value: stats.wrong,
                      accent: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (hasAnswered)
                FilledButton.icon(
                  onPressed: _moveToNextCard,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next Card'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _answerCard(false),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Repeat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _answerCard(true),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Know'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _deckLabel(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'All words deck';
      case FlashcardDeckMode.withContexts:
        return 'Context-rich deck';
      case FlashcardDeckMode.needsReview:
        return 'Needs review deck';
    }
  }

  String _answerHeadline(bool hasAnswered, bool isKnownAnswer) {
    if (!hasAnswered) {
      return 'Hold the answer in your head first';
    }

    return isKnownAnswer ? 'Marked as known' : 'Marked for review';
  }

  Color _answerPanelColor(bool hasAnswered, bool isKnownAnswer) {
    if (!hasAnswered) {
      return const Color(0xFFEDF3EF);
    }

    return isKnownAnswer ? const Color(0xFFEAF5EE) : const Color(0xFFF7EEE8);
  }

  String _formatLastCorrect(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.${local.year} $hour:$minute';
  }
}

class _DeckModeSection extends StatelessWidget {
  const _DeckModeSection({
    required this.selectedMode,
    required this.onChanged,
  });

  final FlashcardDeckMode selectedMode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study deck',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DeckChoiceChip(
              label: 'All',
              isSelected: selectedMode == FlashcardDeckMode.allWords,
              onTap: () => onChanged(FlashcardDeckMode.allWords),
            ),
            _DeckChoiceChip(
              label: 'Context',
              isSelected: selectedMode == FlashcardDeckMode.withContexts,
              onTap: () => onChanged(FlashcardDeckMode.withContexts),
            ),
            _DeckChoiceChip(
              label: 'Review',
              isSelected: selectedMode == FlashcardDeckMode.needsReview,
              onTap: () => onChanged(FlashcardDeckMode.needsReview),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeckChoiceChip extends StatelessWidget {
  const _DeckChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF163832) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF163832)
                  : const Color(0xFF163832).withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF163832),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardContextPanel extends StatelessWidget {
  const _FlashcardContextPanel({
    required this.context,
    required this.isAnswerRevealed,
  });

  final LearningContext? context;
  final bool isAnswerRevealed;

  @override
  Widget build(BuildContext context) {
    if (this.context == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3E8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'This word does not have a shared context sentence yet.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6C665D),
                height: 1.45,
              ),
        ),
      );
    }

    final hebrewText = this.context!.hebrew;
    final hasHebrew = _containsHebrew(hebrewText);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF163832).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Context',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5F5A52),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            hebrewText,
            textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
            textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF163832),
                  height: 1.4,
                ),
          ),
          if (isAnswerRevealed && this.context!.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              this.context!.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6C665D),
                    height: 1.45,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  bool _containsHebrew(String text) {
    return text.runes.any((codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF);
  }
}

class _FlashcardPill extends StatelessWidget {
  const _FlashcardPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFlashcardsState extends StatelessWidget {
  const _EmptyFlashcardsState({
    required this.mode,
    required this.onChanged,
  });

  final FlashcardDeckMode mode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Flashcards',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose another study deck or come back after you have more review data.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.45,
              ),
        ),
        const SizedBox(height: 18),
        _DeckModeSection(
          selectedMode: mode,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                _emptyTitle(mode),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _emptyBody(mode),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
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
        return 'No vocabulary cards are available yet.';
      case FlashcardDeckMode.withContexts:
        return 'No context-backed flashcards are available yet.';
      case FlashcardDeckMode.needsReview:
        return 'Nothing needs review right now.';
    }
  }

  String _emptyBody(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Add vocabulary data to the shared dataset and sync it into Flutter assets.';
      case FlashcardDeckMode.withContexts:
        return 'Add shared context sentences for more words to unlock this deck.';
      case FlashcardDeckMode.needsReview:
        return 'Once you mark cards with Repeat, they will appear here as a focused review deck.';
    }
  }
}
