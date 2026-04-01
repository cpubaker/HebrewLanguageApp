import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
    this.initialDeckMode = FlashcardDeckMode.allWords,
    this.deckRequestToken = 0,
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;
  final FlashcardDeckMode initialDeckMode;
  final int deckRequestToken;

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
    _session = FlashcardSession(
      widget.words,
      deckMode: widget.initialDeckMode,
    );
    _moveToNextCard();
  }

  @override
  void didUpdateWidget(covariant FlashcardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deckRequestToken != widget.deckRequestToken) {
      _session.resetDeck(mode: widget.initialDeckMode);
      _moveToNextCard();
    }
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

    final answer = _currentAnswer;
    if (answer != null) {
      widget.onWordProgressChanged(answer.word);
    }
  }

  void _changeDeckMode(FlashcardDeckMode mode) {
    setState(() {
      _session.setDeckMode(mode);
      _currentCard = _session.nextCard();
      _currentAnswer = null;
    });
  }

  void _restartDeck([FlashcardDeckMode? mode]) {
    setState(() {
      _session.resetDeck(mode: mode ?? _session.deckMode);
      _currentCard = _session.nextCard();
      _currentAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _currentCard;
    if (currentCard == null) {
      if (_session.wordCount > 0 && _session.answeredCount > 0) {
        return _CompletedFlashcardsState(
          mode: _session.deckMode,
          wordCount: _session.wordCount,
          correctAnswers: _session.correctAnswers,
          repeatAnswers: _session.repeatAnswers,
          reviewWordCount: _session.reviewWordCount,
          onRestartDeck: _restartDeck,
          onChanged: _changeDeckMode,
        );
      }

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
    final totalWordCount = widget.words.length;
    final contextWordCount = widget.words
        .where((word) => word.contexts.isNotEmpty)
        .length;
    final reviewWordCount = widget.words
        .where((word) => word.wrong > 0 || word.wrong > word.correct)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _CompactFlashcardsHeader(
          selectedMode: _session.deckMode,
          totalWordCount: totalWordCount,
          contextWordCount: contextWordCount,
          reviewWordCount: reviewWordCount,
          onChanged: _changeDeckMode,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
              _DeckStatusHeader(
                deckLabel: _deckLabel(_session.deckMode),
                currentCardNumber: _session.currentCardNumber,
                wordCount: _session.wordCount,
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
                _session.remainingCount > 0
                    ? '${_session.remainingCount} cards left after this one'
                    : 'This is the last card in the deck',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
              ),
              const SizedBox(height: 20),
              _PromptPanel(
                hebrew: word.hebrew,
                transcription: word.transcription,
              ),
              const SizedBox(height: 20),
              _FlashcardContextPanel(
                context: currentContext,
                isAnswerRevealed: hasAnswered,
              ),
              const SizedBox(height: 18),
              _AnswerStatusCard(
                hasAnswered: hasAnswered,
                isKnownAnswer: isKnownAnswer,
                translation: word.english,
                lastCorrect: stats.lastCorrect == null
                    ? null
                    : _formatLastCorrect(stats.lastCorrect!),
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
                  label: Text(
                    _session.seenCount == _session.wordCount
                        ? 'See Summary'
                        : 'Next Card',
                  ),
                )
              else
                Column(
                  children: [
                    _AnswerActionButton(
                      label: 'Know',
                      subtitle: 'Mark it as known and continue',
                      icon: Icons.check_rounded,
                      accent: const Color(0xFF0F766E),
                      filled: true,
                      onPressed: () => _answerCard(true),
                    ),
                    const SizedBox(height: 12),
                    _AnswerActionButton(
                      label: 'Repeat',
                      subtitle: 'Keep it in your review deck',
                      icon: Icons.refresh_rounded,
                      accent: const Color(0xFFB45309),
                      filled: false,
                      onPressed: () => _answerCard(false),
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

class _DeckStatusHeader extends StatelessWidget {
  const _DeckStatusHeader({
    required this.deckLabel,
    required this.currentCardNumber,
    required this.wordCount,
  });

  final String deckLabel;
  final int currentCardNumber;
  final int wordCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF163832).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            deckLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF163832),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const Spacer(),
        Text(
          'Card $currentCardNumber of $wordCount',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF6C665D),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _CompactFlashcardsHeader extends StatelessWidget {
  const _CompactFlashcardsHeader({
    required this.selectedMode,
    required this.totalWordCount,
    required this.contextWordCount,
    required this.reviewWordCount,
    required this.onChanged,
  });

  final FlashcardDeckMode selectedMode;
  final int totalWordCount;
  final int contextWordCount;
  final int reviewWordCount;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final deckCount = switch (selectedMode) {
      FlashcardDeckMode.allWords => totalWordCount,
      FlashcardDeckMode.withContexts => contextWordCount,
      FlashcardDeckMode.needsReview => reviewWordCount,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Flashcards',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF163832).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$deckCount cards',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF163832),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _DeckChoiceChip(
                label: 'All $totalWordCount',
                isSelected: selectedMode == FlashcardDeckMode.allWords,
                onTap: () => onChanged(FlashcardDeckMode.allWords),
              ),
              const SizedBox(width: 10),
              _DeckChoiceChip(
                label: 'Context $contextWordCount',
                isSelected: selectedMode == FlashcardDeckMode.withContexts,
                onTap: () => onChanged(FlashcardDeckMode.withContexts),
              ),
              const SizedBox(width: 10),
              _DeckChoiceChip(
                label: 'Review $reviewWordCount',
                isSelected: selectedMode == FlashcardDeckMode.needsReview,
                onTap: () => onChanged(FlashcardDeckMode.needsReview),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.hebrew,
    required this.transcription,
  });

  final String hebrew;
  final String transcription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF1F6F2),
            Color(0xFFF7F3E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Recall the meaning before you reveal it',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5F5A52),
                ),
          ),
          const SizedBox(height: 14),
          Text(
            hebrew,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF163832),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            transcription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                ),
          ),
        ],
      ),
    );
  }
}

class _AnswerStatusCard extends StatelessWidget {
  const _AnswerStatusCard({
    required this.hasAnswered,
    required this.isKnownAnswer,
    required this.translation,
    required this.lastCorrect,
  });

  final bool hasAnswered;
  final bool isKnownAnswer;
  final String translation;
  final String? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final accent = hasAnswered
        ? (isKnownAnswer ? const Color(0xFF0F766E) : const Color(0xFFB45309))
        : const Color(0xFF6C665D);
    final background = hasAnswered
        ? (isKnownAnswer ? const Color(0xFFEAF5EE) : const Color(0xFFF7EEE8))
        : const Color(0xFFEDF3EF);
    final icon = hasAnswered
        ? (isKnownAnswer ? Icons.check_circle_rounded : Icons.refresh_rounded)
        : Icons.lightbulb_outline_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 26),
          const SizedBox(height: 10),
          Text(
            _headline(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5F5A52),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            hasAnswered ? translation : 'Tap Know or Repeat to reveal the translation.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: hasAnswered ? const Color(0xFF163832) : const Color(0xFF7A746A),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _supportingCopy(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                  height: 1.45,
                ),
          ),
          if (hasAnswered && lastCorrect != null) ...[
            const SizedBox(height: 10),
            Text(
              'Last known: $lastCorrect',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6C665D),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _headline() {
    if (!hasAnswered) {
      return 'Hold the answer in your head first';
    }

    return isKnownAnswer ? 'Marked as known' : 'Marked for review';
  }

  String _supportingCopy() {
    if (!hasAnswered) {
      return 'Use the Hebrew prompt and the context sentence to guess before revealing.';
    }

    return isKnownAnswer
        ? 'Nice. This card will count toward your known progress.'
        : 'This one stays in your review deck so you can revisit it later.';
  }
}

class _AnswerActionButton extends StatelessWidget {
  const _AnswerActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = filled ? accent : Colors.white;
    final foreground = filled ? Colors.white : accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: filled ? 0 : 0.20)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.16)
                      : accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: filled
                                ? Colors.white.withValues(alpha: 0.88)
                                : const Color(0xFF6C665D),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class _CompletedFlashcardsState extends StatelessWidget {
  const _CompletedFlashcardsState({
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
          'You finished this flashcard deck. Restart it or switch to the next best study mode.',
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Deck complete',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$wordCount cards finished',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _completionBody(mode, reviewWordCount),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _FlashcardPill(
                    label: 'Known',
                    value: correctAnswers,
                    accent: const Color(0xFF0F766E),
                  ),
                  _FlashcardPill(
                    label: 'Repeat',
                    value: repeatAnswers,
                    accent: const Color(0xFFB45309),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => onRestartDeck(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart Deck'),
              ),
              if (mode != FlashcardDeckMode.needsReview && reviewWordCount > 0) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => onRestartDeck(FlashcardDeckMode.needsReview),
                  icon: const Icon(Icons.rule_rounded),
                  label: const Text('Open Review Deck'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _completionBody(FlashcardDeckMode mode, int reviewWordCount) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        if (reviewWordCount > 0) {
          return '$reviewWordCount cards are ready for focused review.';
        }
        return 'You cleared the all-words deck for this session.';
      case FlashcardDeckMode.withContexts:
        if (reviewWordCount > 0) {
          return '$reviewWordCount cards now need extra review after this pass.';
        }
        return 'You finished every context-backed card in this deck.';
      case FlashcardDeckMode.needsReview:
        return 'You worked through every review card in the deck.';
    }
  }
}
