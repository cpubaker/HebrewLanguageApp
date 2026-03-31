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

  @override
  Widget build(BuildContext context) {
    final currentCard = _currentCard;
    if (currentCard == null) {
      return const _EmptyFlashcardsState();
    }

    final word = _currentAnswer?.word ?? currentCard.word;
    final currentContext = _currentAnswer?.context ?? currentCard.context;
    final stats = _session.currentWordStats();
    final hasAnswered = _currentAnswer != null;

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
          'Step through vocabulary one card at a time. Decide first, then reveal the answer and move on.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.45,
              ),
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
                    'Card ${_session.answeredCount + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF163832),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
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
                  color: hasAnswered
                      ? const Color(0xFFF7F3E8)
                      : const Color(0xFFEDF3EF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      hasAnswered ? 'Answer' : 'Hold the answer in your head first',
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
  const _EmptyFlashcardsState();

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
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            'No vocabulary cards are available yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
