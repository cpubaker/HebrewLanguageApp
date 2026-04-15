import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_panel.dart';
import 'widgets/practice_stat_pill.dart';

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
  static const double _swipeVelocityThreshold = 325;

  late final FlashcardSession _session;

  FlashcardCard? _currentCard;
  FlashcardAnswerResult? _currentAnswer;
  bool _showSessionDetails = false;

  @override
  void initState() {
    super.initState();
    _session = FlashcardSession(widget.words, deckMode: widget.initialDeckMode);
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
      _showSessionDetails = false;
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
      _showSessionDetails = false;
    });
  }

  void _toggleReviewDeck() {
    final reviewWordCount = FlashcardFocusSnapshot.fromWords(
      widget.words,
    ).needsReview;

    if (_session.deckMode == FlashcardDeckMode.needsReview) {
      _changeDeckMode(FlashcardDeckMode.allWords);
      return;
    }

    if (reviewWordCount > 0) {
      _changeDeckMode(FlashcardDeckMode.needsReview);
    }
  }

  void _handleCardSwipe(DragEndDetails details) {
    if (_currentCard == null || _currentAnswer != null) {
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) {
      return;
    }

    _answerCard(velocity > 0);
  }

  void _restartDeck([FlashcardDeckMode? mode]) {
    setState(() {
      _session.resetDeck(mode: mode ?? _session.deckMode);
      _currentCard = _session.nextCard();
      _currentAnswer = null;
      _showSessionDetails = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
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
    final focus = FlashcardFocusSnapshot.fromWords(widget.words);
    final totalWordCount = focus.total;
    final contextWordCount = focus.withContexts;
    final reviewWordCount = focus.needsReview;

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        _CompactFlashcardsHeader(
          selectedMode: _session.deckMode,
          totalWordCount: totalWordCount,
          contextWordCount: contextWordCount,
          reviewWordCount: reviewWordCount,
          onToggleReview: _toggleReviewDeck,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onHorizontalDragEnd: hasAnswered ? null : _handleCardSwipe,
          behavior: HitTestBehavior.opaque,
          child: Container(
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
                if (hasAnswered)
                  _AnswerRevealCard(
                    isKnownAnswer: isKnownAnswer,
                    translation: word.translation,
                    lastCorrect: stats.lastCorrect == null
                        ? null
                        : _formatLastCorrect(stats.lastCorrect!),
                  )
                else
                  _SwipeHintStrip(
                    onRepeatTap: () => _answerCard(false),
                    onKnowTap: () => _answerCard(true),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: PracticeStatPill(
                        label: 'РџСЂР°РІРёР»СЊРЅРѕ',
                        value: stats.correct,
                        icon: Icons.check_rounded,
                        accent: const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PracticeStatPill(
                        label: 'РџРѕРјРёР»РєРё',
                        value: stats.wrong,
                        icon: Icons.close_rounded,
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
                          ? 'Р”Рѕ РїС–РґСЃСѓРјРєСѓ'
                          : 'Р”Р°Р»С–',
                    ),
                  )
                else
                  Text(
                    'Р—РјР°С…РЅС–С‚СЊ РєР°СЂС‚РєСѓ Р°Р±Рѕ РЅР°С‚РёСЃРЅС–С‚СЊ РїРѕС‚СЂС–Р±РЅРёР№ РІР°СЂС–Р°РЅС‚.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
                  ),
                const SizedBox(height: 14),
                _SessionDetailsSection(
                  isExpanded: _showSessionDetails,
                  deckLabel: _deckLabel(_session.deckMode),
                  currentCardNumber: _session.currentCardNumber,
                  wordCount: _session.wordCount,
                  remainingCount: _session.remainingCount,
                  sessionProgress: _session.sessionProgress,
                  correctCount: stats.correct,
                  wrongCount: stats.wrong,
                  onToggle: () {
                    setState(() {
                      _showSessionDetails = !_showSessionDetails;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _deckLabel(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'РЈСЃС– СЃР»РѕРІР°';
      case FlashcardDeckMode.withContexts:
        return 'Р— РїСЂРёРєР»Р°РґР°РјРё';
      case FlashcardDeckMode.needsReview:
        return 'РќР° РїРѕРІС‚РѕСЂРµРЅРЅСЏ';
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

class _SessionDetailsSection extends StatelessWidget {
  const _SessionDetailsSection({
    required this.isExpanded,
    required this.deckLabel,
    required this.currentCardNumber,
    required this.wordCount,
    required this.remainingCount,
    required this.sessionProgress,
    required this.correctCount,
    required this.wrongCount,
    required this.onToggle,
  });

  final bool isExpanded;
  final String deckLabel;
  final int currentCardNumber;
  final int wordCount;
  final int remainingCount;
  final double sessionProgress;
  final int correctCount;
  final int wrongCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return PracticePanel(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'РџРѕС‚РѕС‡РЅР° СЃРµСЃС–СЏ',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF163832),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentCardNumber С–Р· $wordCount',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF6C665D)),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6C665D),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    deckLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF6C665D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: sessionProgress == 0 ? 0.02 : sessionProgress,
                      backgroundColor: const Color(0xFFE9E2D3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0F766E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remainingCount > 0
                        ? 'РџС–СЃР»СЏ РЅРµС— Р»РёС€РёС‚СЊСЃСЏ С‰Рµ $remainingCount РєР°СЂС‚РѕРє'
                        : 'Р¦Рµ РѕСЃС‚Р°РЅРЅСЏ РєР°СЂС‚РєР°',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C665D),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PracticeStatPill(
                          label: 'РџСЂР°РІРёР»СЊРЅРѕ',
                          value: correctCount,
                          icon: Icons.check_rounded,
                          accent: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PracticeStatPill(
                          label: 'РџРѕРјРёР»РєРё',
                          value: wrongCount,
                          icon: Icons.close_rounded,
                          accent: const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CompactFlashcardsHeader extends StatelessWidget {
  const _CompactFlashcardsHeader({
    required this.selectedMode,
    required this.totalWordCount,
    required this.contextWordCount,
    required this.reviewWordCount,
    required this.onToggleReview,
  });

  final FlashcardDeckMode selectedMode;
  final int totalWordCount;
  final int contextWordCount;
  final int reviewWordCount;
  final VoidCallback onToggleReview;

  @override
  Widget build(BuildContext context) {
    final deckLabel = switch (selectedMode) {
      FlashcardDeckMode.allWords => 'РЈСЃС– СЃР»РѕРІР°',
      FlashcardDeckMode.withContexts => 'Р— РїСЂРёРєР»Р°РґР°РјРё',
      FlashcardDeckMode.needsReview => 'РќР° РїРѕРІС‚РѕСЂРµРЅРЅСЏ',
    };
    final countLabel = switch (selectedMode) {
      FlashcardDeckMode.allWords => '$totalWordCount Сѓ РЅР°Р±РѕСЂС–',
      FlashcardDeckMode.withContexts =>
        '$contextWordCount Р· РїСЂРёРєР»Р°РґР°РјРё',
      FlashcardDeckMode.needsReview =>
        '$reviewWordCount РЅР° РїРѕРІС‚РѕСЂРµРЅРЅС–',
    };
    final canToggleReview =
        reviewWordCount > 0 || selectedMode == FlashcardDeckMode.needsReview;
    final helperLabel = switch (selectedMode) {
      FlashcardDeckMode.needsReview =>
        'РќР°С‚РёСЃРЅС–С‚СЊ РЅР° Р»С–С‡РёР»СЊРЅРёРє, С‰РѕР± РїРѕРІРµСЂРЅСѓС‚РёСЃСЏ РґРѕ РІСЃС–С… РєР°СЂС‚РѕРє.',
      FlashcardDeckMode.withContexts when reviewWordCount > 0 =>
        'РќР°С‚РёСЃРЅС–С‚СЊ РЅР° Р»С–С‡РёР»СЊРЅРёРє, С‰РѕР± РїРµСЂРµР№С‚Рё РґРѕ РїРѕРІС‚РѕСЂРµРЅРЅСЏ.',
      FlashcardDeckMode.allWords when reviewWordCount > 0 =>
        'РќР°С‚РёСЃРЅС–С‚СЊ РЅР° Р»С–С‡РёР»СЊРЅРёРє, С‰РѕР± РІС–РґРєСЂРёС‚Рё РїРѕРІС‚РѕСЂРµРЅРЅСЏ.',
      _ => null,
    };
    final pillColor = selectedMode == FlashcardDeckMode.needsReview
        ? const Color(0xFFB45309).withValues(alpha: 0.12)
        : const Color(0xFF163832).withValues(alpha: 0.08);
    final pillTextColor = selectedMode == FlashcardDeckMode.needsReview
        ? const Color(0xFF8A460C)
        : const Color(0xFF163832);

    return PracticeHeader(
      title: 'Картки',
      subtitle: helperLabel ?? 'Поточний режим: $deckLabel.',
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canToggleReview ? onToggleReview : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: pillTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (canToggleReview) ...[
                    const SizedBox(width: 6),
                    Icon(
                      selectedMode == FlashcardDeckMode.needsReview
                          ? Icons.undo_rounded
                          : Icons.rule_folder_rounded,
                      size: 18,
                      color: pillTextColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({required this.hebrew, required this.transcription});

  final String hebrew;
  final String transcription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1F6F2), Color(0xFFF7F3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Спробуйте згадати переклад',
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF6C665D)),
          ),
        ],
      ),
    );
  }
}

class _AnswerRevealCard extends StatelessWidget {
  const _AnswerRevealCard({
    required this.isKnownAnswer,
    required this.translation,
    this.lastCorrect,
  });

  final bool isKnownAnswer;
  final String translation;
  final String? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final background = isKnownAnswer
        ? const Color(0xFFEAF6F2)
        : const Color(0xFFF9EFE4);
    final accent = isKnownAnswer
        ? const Color(0xFF0F766E)
        : const Color(0xFFB45309);
    final icon = isKnownAnswer
        ? Icons.check_circle_rounded
        : Icons.refresh_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 8),
              Text(
                isKnownAnswer ? 'Зараховано' : 'На повторення',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5F5A52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF163832),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKnownAnswer
                ? 'Добре. Це слово зараховано як знайоме.'
                : 'Нічого, повернемося до нього ще раз трохи пізніше.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6C665D),
              height: 1.45,
            ),
          ),
          if (lastCorrect != null) ...[
            const SizedBox(height: 10),
            Text(
              'Востаннє правильно: $lastCorrect',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C665D)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwipeHintStrip extends StatelessWidget {
  const _SwipeHintStrip({required this.onRepeatTap, required this.onKnowTap});

  final VoidCallback onRepeatTap;
  final VoidCallback onKnowTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SwipeHintCard(
            alignment: CrossAxisAlignment.start,
            icon: Icons.arrow_back_rounded,
            title: 'Р›С–РІРѕСЂСѓС‡',
            subtitle: 'Р©Рµ СЂР°Р·',
            accent: Color(0xFFB45309),
            onTap: onRepeatTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SwipeHintCard(
            alignment: CrossAxisAlignment.end,
            icon: Icons.arrow_forward_rounded,
            title: 'РџСЂР°РІРѕСЂСѓС‡',
            subtitle: 'Р—РЅР°СЋ',
            accent: Color(0xFF0F766E),
            onTap: onKnowTap,
          ),
        ),
      ],
    );
  }
}

class _SwipeHintCard extends StatelessWidget {
  const _SwipeHintCard({
    required this.alignment,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final CrossAxisAlignment alignment;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF5F5A52),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
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
  const _DeckModeSection({required this.selectedMode, required this.onChanged});

  final FlashcardDeckMode selectedMode;
  final ValueChanged<FlashcardDeckMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Режим',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DeckChoiceChip(
              label: 'РЈСЃС–',
              isSelected: selectedMode == FlashcardDeckMode.allWords,
              onTap: () => onChanged(FlashcardDeckMode.allWords),
            ),
            _DeckChoiceChip(
              label: 'РљРѕРЅС‚РµРєСЃС‚',
              isSelected: selectedMode == FlashcardDeckMode.withContexts,
              onTap: () => onChanged(FlashcardDeckMode.withContexts),
            ),
            _DeckChoiceChip(
              label: 'РџРѕРІС‚РѕСЂРµРЅРЅСЏ',
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
          'Р”Р»СЏ С†СЊРѕРіРѕ СЃР»РѕРІР° С‰Рµ РЅРµРјР°С” РїСЂРёРєР»Р°РґСѓ РІ СЂРµС‡РµРЅРЅС–.',
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
            'РљРѕРЅС‚РµРєСЃС‚',
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
          if (isAnswerRevealed &&
              this.context!.translation.trim().isNotEmpty) ...[
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
    return text.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );
  }
}

class _EmptyFlashcardsState extends StatelessWidget {
  const _EmptyFlashcardsState({required this.mode, required this.onChanged});

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
        _DeckModeSection(selectedMode: mode, onChanged: onChanged),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
        return 'РЎР»РѕРІР° С‰Рµ РЅРµ Р·Р°РІР°РЅС‚Р°Р¶РµРЅС–.';
      case FlashcardDeckMode.withContexts:
        return 'РљР°СЂС‚РѕРє С–Р· РїСЂРёРєР»Р°РґР°РјРё РїРѕРєРё РЅРµРјР°С”.';
      case FlashcardDeckMode.needsReview:
        return 'РќР° РїРѕРІС‚РѕСЂРµРЅРЅС– РїРѕРєРё РїРѕСЂРѕР¶РЅСЊРѕ.';
    }
  }

  String _emptyBody(FlashcardDeckMode mode) {
    switch (mode) {
      case FlashcardDeckMode.allWords:
        return 'Р©РѕР№РЅРѕ СЃР»РѕРІР° Р·вЂ™СЏРІР»СЏС‚СЊСЃСЏ, С‚СѓС‚ РјРѕР¶РЅР° Р±СѓРґРµ РїРѕС‡Р°С‚Рё С‚СЂРµРЅСѓРІР°РЅРЅСЏ.';
      case FlashcardDeckMode.withContexts:
        return 'РљРѕР»Рё РґР»СЏ СЃР»С–РІ Р·вЂ™СЏРІР»СЏС‚СЊСЃСЏ РїСЂРёРєР»Р°РґРё, С†РµР№ СЂРµР¶РёРј СЃС‚Р°РЅРµ РґРѕСЃС‚СѓРїРЅРёРј.';
      case FlashcardDeckMode.needsReview:
        return 'РџРѕР·РЅР°С‡Р°Р№С‚Рµ СЃР»РѕРІР° СЏРє В«Р©Рµ СЂР°Р·В», С– РІРѕРЅРё Р·вЂ™СЏРІР»СЏС‚СЊСЃСЏ С‚СѓС‚ РѕРєСЂРµРјРѕ.';
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
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Картки',
          subtitle:
              'Цю колоду вже пройдено. Можна почати ще раз або перейти далі.',
        ),
        _DeckModeSection(selectedMode: mode, onChanged: onChanged),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Р“РѕС‚РѕРІРѕ',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$wordCount РєР°СЂС‚РѕРє РїСЂРѕР№РґРµРЅРѕ',
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
                  PracticeStatPill(
                    label: 'Р—РЅР°СЋ',
                    value: correctAnswers,
                    icon: Icons.check_rounded,
                    accent: const Color(0xFF0F766E),
                  ),
                  PracticeStatPill(
                    label: 'РџРѕРІС‚РѕСЂРёС‚Рё',
                    value: repeatAnswers,
                    icon: Icons.refresh_rounded,
                    accent: const Color(0xFFB45309),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => onRestartDeck(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('РџРѕС‡Р°С‚Рё С‰Рµ СЂР°Р·'),
              ),
              if (mode != FlashcardDeckMode.needsReview &&
                  reviewWordCount > 0) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => onRestartDeck(FlashcardDeckMode.needsReview),
                  icon: const Icon(Icons.rule_rounded),
                  label: const Text('Р”Рѕ РїРѕРІС‚РѕСЂРµРЅРЅСЏ'),
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
          return 'РќР° РїРѕРІС‚РѕСЂРµРЅРЅСЏ С‡РµРєР°СЋС‚СЊ $reviewWordCount РєР°СЂС‚РѕРє.';
        }
        return 'РЈСЃС– СЃР»РѕРІР° Р· С†С–С”С— РєРѕР»РѕРґРё РІР¶Рµ РїРµСЂРµРіР»СЏРЅСѓС‚С–.';
      case FlashcardDeckMode.withContexts:
        if (reviewWordCount > 0) {
          return 'РџС–СЃР»СЏ С†СЊРѕРіРѕ РїСЂРѕС…РѕРґСѓ $reviewWordCount РєР°СЂС‚РѕРє РїРµСЂРµР№С€Р»Рё РЅР° РїРѕРІС‚РѕСЂРµРЅРЅСЏ.';
        }
        return 'РЈСЃС– РєР°СЂС‚РєРё Р· РїСЂРёРєР»Р°РґР°РјРё РІР¶Рµ РїСЂРѕР№РґРµРЅС–.';
      case FlashcardDeckMode.needsReview:
        return 'РЈ РєРѕР»РѕРґС– РїРѕРІС‚РѕСЂРµРЅРЅСЏ Р±С–Р»СЊС€Рµ РЅРµ Р»РёС€РёР»РѕСЃСЏ РєР°СЂС‚РѕРє.';
    }
  }
}
