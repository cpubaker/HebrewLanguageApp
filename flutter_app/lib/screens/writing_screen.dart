import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/flashcard_session.dart';
import '../services/writing_session.dart';
import '../theme/app_theme.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_session_summary.dart';
import 'widgets/practice_stat_pill.dart';

enum _WritingPracticeMode { typing, constructor }

class WritingScreen extends StatefulWidget {
  const WritingScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late final WritingSession _session;
  late final TextEditingController _answerController;

  _WritingPracticeMode _mode = _WritingPracticeMode.typing;
  WritingPrompt? _currentPrompt;
  WritingAnswerResult? _currentAnswer;
  String? _inlineMessage;
  List<ConstructorBlock> _availableBlocks = const <ConstructorBlock>[];
  List<ConstructorBlock?> _selectedBlocks = const <ConstructorBlock?>[];
  Map<String, int> _constructorBlockOrder = const <String, int>{};

  @override
  void initState() {
    super.initState();
    _session = WritingSession(widget.words);
    _answerController = TextEditingController();
    _moveToNextPrompt();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _moveToNextPrompt() {
    setState(() {
      _currentPrompt = _session.nextPrompt();
      _currentAnswer = null;
      _inlineMessage = null;
      _answerController.clear();
      _resetConstructorState(_currentPrompt?.constructorPuzzle);
    });
  }

  void _submitAnswer() {
    final answer = _mode == _WritingPracticeMode.typing
        ? _answerController.text
        : _buildConstructorAnswer();

    if (_mode == _WritingPracticeMode.constructor &&
        _selectedBlocks.any((block) => block == null)) {
      setState(() {
        _inlineMessage =
            'Заповніть усі склади, а потім перевіряйте відповідь.';
      });
      return;
    }

    final result = _session.submitAnswer(answer);
    if (result == null) {
      return;
    }

    if (result.status == WritingAnswerStatus.empty) {
      setState(() {
        _inlineMessage = _mode == _WritingPracticeMode.typing
            ? 'Введіть слово івритом, щоб перевірити відповідь.'
            : 'Складіть слово з блоків, щоб перевірити відповідь.';
      });
      return;
    }

    setState(() {
      _currentAnswer = result;
      _inlineMessage = null;
    });

    widget.onWordProgressChanged(result.word);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final currentPrompt = _currentPrompt;
    if (currentPrompt == null) {
      return const _EmptyWritingState();
    }

    final currentWord = _currentAnswer?.word ?? currentPrompt.word;
    final hasAnswered = _currentAnswer != null;
    final isCorrect = _currentAnswer?.isCorrect == true;
    final stats = _session.currentWordStats();

    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Писання',
          subtitle:
              'Бачите переклад українською, а далі або пишете слово самі, або складаєте його з готових блоків.',
        ),
        const SizedBox(height: 18),
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
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    key: const ValueKey('writing_mode_typing'),
                    label: const Text('Писання'),
                    selected: _mode == _WritingPracticeMode.typing,
                    onSelected: (_) {
                      setState(() {
                        _mode = _WritingPracticeMode.typing;
                        _inlineMessage = null;
                      });
                    },
                  ),
                  ChoiceChip(
                    key: const ValueKey('writing_mode_constructor'),
                    label: const Text('Конструктор'),
                    selected: _mode == _WritingPracticeMode.constructor,
                    onSelected: (_) {
                      setState(() {
                        _mode = _WritingPracticeMode.constructor;
                        _inlineMessage = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
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
                      'Слово для перекладу',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF5F5A52),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentPrompt.prompt,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF163832),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mode == _WritingPracticeMode.typing
                          ? 'Підказку не показуємо: тут працюємо саме на пригадування.'
                          : 'Складіть слово з блоків. Частина блоків може бути зайвою.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C665D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_mode == _WritingPracticeMode.typing)
                TextField(
                  controller: _answerController,
                  enabled: !hasAnswered,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitAnswer(),
                  decoration: InputDecoration(
                    hintText: 'Введіть слово івритом',
                    prefixIcon: const Icon(Icons.edit_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF9F5EC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0x1F8C6A2A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF8C6A2A),
                        width: 1.5,
                      ),
                    ),
                  ),
                )
              else
                _ConstructorComposer(
                  hasAnswered: hasAnswered,
                  availableBlocks: _availableBlocks,
                  selectedBlocks: _selectedBlocks,
                  onBlockTap: _placeBlockInNextSlot,
                  onSlotTap: _returnBlockToPool,
                  onBlockDroppedOnSlot: _placeBlockInSlot,
                  onBlockDroppedToPool: _returnDroppedBlockToPool,
                ),
              if (_inlineMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _inlineMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (hasAnswered)
                _WritingResultCard(
                  isCorrect: isCorrect,
                  correctAnswer:
                      _currentAnswer?.correctAnswer ?? currentWord.hebrew,
                  lastCorrect: stats.lastCorrect == null
                      ? null
                      : _formatTimestamp(stats.lastCorrect!),
                )
              else
                Text(
                  _mode == _WritingPracticeMode.typing
                      ? 'Натисніть «Перевірити», коли будете готові.'
                      : 'Перетягніть або натисніть блоки, щоб зібрати слово, а потім перевірте відповідь.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6C665D),
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: PracticeStatPill(
                      label: 'Правильно',
                      value: stats.correct,
                      accent: const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PracticeStatPill(
                      label: 'Помилки',
                      value: stats.wrong,
                      accent: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: hasAnswered ? null : _submitAnswer,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Перевірити'),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasAnswered ? _moveToNextPrompt : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Далі'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PracticeSessionSummary(
                title: 'Поточна сесія',
                lines: [
                  'Перевірено відповідей: ${_session.answeredCount}',
                  '${widget.words.length} слів доступні для письма на цьому пристрої',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String value) {
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

  void _resetConstructorState(ConstructorPuzzle? puzzle) {
    if (puzzle == null) {
      _availableBlocks = const <ConstructorBlock>[];
      _selectedBlocks = const <ConstructorBlock?>[];
      _constructorBlockOrder = const <String, int>{};
      return;
    }

    _availableBlocks = List<ConstructorBlock>.from(puzzle.availableBlocks);
    _selectedBlocks = List<ConstructorBlock?>.filled(
      puzzle.solution.length,
      null,
      growable: false,
    );
    _constructorBlockOrder = <String, int>{
      for (var index = 0; index < puzzle.availableBlocks.length; index += 1)
        puzzle.availableBlocks[index].id: index,
    };
  }

  String _buildConstructorAnswer() {
    return _selectedBlocks
        .whereType<ConstructorBlock>()
        .map((block) => block.text)
        .join();
  }

  void _placeBlockInNextSlot(ConstructorBlock block) {
    if (_currentAnswer != null) {
      return;
    }

    final emptySlotIndex = _selectedBlocks.indexWhere((slot) => slot == null);
    if (emptySlotIndex == -1) {
      return;
    }

    _placeBlockInSlot(block, emptySlotIndex);
  }

  void _placeBlockInSlot(ConstructorBlock block, int slotIndex) {
    if (_currentAnswer != null) {
      return;
    }

    if (_selectedBlocks[slotIndex]?.id == block.id) {
      return;
    }

    setState(() {
      final displaced = _selectedBlocks[slotIndex];
      _detachBlock(block);
      if (displaced != null) {
        _availableBlocks.add(displaced);
      }
      _selectedBlocks[slotIndex] = block;
      _sortAvailableBlocks();
      _inlineMessage = null;
    });
  }

  void _returnBlockToPool(int slotIndex) {
    if (_currentAnswer != null) {
      return;
    }

    final block = _selectedBlocks[slotIndex];
    if (block == null) {
      return;
    }

    setState(() {
      _selectedBlocks[slotIndex] = null;
      _availableBlocks.add(block);
      _sortAvailableBlocks();
      _inlineMessage = null;
    });
  }

  void _returnDroppedBlockToPool(ConstructorBlock block) {
    if (_currentAnswer != null) {
      return;
    }

    setState(() {
      _detachBlock(block);
      _availableBlocks.add(block);
      _sortAvailableBlocks();
      _inlineMessage = null;
    });
  }

  void _detachBlock(ConstructorBlock block) {
    _availableBlocks.removeWhere((candidate) => candidate.id == block.id);

    for (var index = 0; index < _selectedBlocks.length; index += 1) {
      if (_selectedBlocks[index]?.id == block.id) {
        _selectedBlocks[index] = null;
      }
    }
  }

  void _sortAvailableBlocks() {
    _availableBlocks.sort((left, right) {
      final leftOrder = _constructorBlockOrder[left.id] ?? 0;
      final rightOrder = _constructorBlockOrder[right.id] ?? 0;
      return leftOrder.compareTo(rightOrder);
    });
  }
}

class _WritingResultCard extends StatelessWidget {
  const _WritingResultCard({
    required this.isCorrect,
    required this.correctAnswer,
    this.lastCorrect,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect
        ? const Color(0xFF0F766E)
        : const Color(0xFFB91C1C);
    final background = isCorrect
        ? const Color(0xFFEAF5EE)
        : const Color(0xFFF8ECE8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: accent,
                size: 22,
              ),
              Text(
                isCorrect ? 'Правильно' : 'Потрібно ще раз',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5F5A52),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            correctAnswer,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF163832),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? 'Слово записано правильно. Можна переходити далі.'
                : 'Звірте форму і напишіть наступне слово з пам’яті.',
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

class _EmptyWritingState extends StatelessWidget {
  const _EmptyWritingState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return ListView(
      padding: tokens.pagePadding.copyWith(bottom: 32),
      children: [
        const PracticeHeader(
          title: 'Писання',
          subtitle:
              'Коли слова завантажаться, тут можна буде тренувати написання івритом або складати слова з блоків.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            'Щойно у наборі з’являться доступні слова, тут можна буде тренувати письмо окремою сесією.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5F5A52),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConstructorComposer extends StatelessWidget {
  const _ConstructorComposer({
    required this.hasAnswered,
    required this.availableBlocks,
    required this.selectedBlocks,
    required this.onBlockTap,
    required this.onSlotTap,
    required this.onBlockDroppedOnSlot,
    required this.onBlockDroppedToPool,
  });

  final bool hasAnswered;
  final List<ConstructorBlock> availableBlocks;
  final List<ConstructorBlock?> selectedBlocks;
  final ValueChanged<ConstructorBlock> onBlockTap;
  final ValueChanged<int> onSlotTap;
  final void Function(ConstructorBlock block, int slotIndex)
  onBlockDroppedOnSlot;
  final ValueChanged<ConstructorBlock> onBlockDroppedToPool;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F5EC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Складіть слово',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF163832),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Перетягніть блоки у правильному порядку. Натискання на блок теж працює.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (
                      var index = 0;
                      index < selectedBlocks.length;
                      index += 1
                    )
                      _ConstructorSlot(
                        key: ValueKey('constructor_slot_$index'),
                        block: selectedBlocks[index],
                        enabled: !hasAnswered,
                        onTap: () => onSlotTap(index),
                        onAccept: (block) => onBlockDroppedOnSlot(block, index),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        DragTarget<ConstructorBlock>(
          onWillAcceptWithDetails: (_) => !hasAnswered,
          onAcceptWithDetails: (details) => onBlockDroppedToPool(details.data),
          builder: (context, candidateData, rejectedData) {
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? const Color(0xFF8C6A2A)
                      : const Color(0x1F8C6A2A),
                  width: candidateData.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Доступні блоки',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5F5A52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final block in availableBlocks)
                          _ConstructorBlockChip(
                            key: ValueKey('constructor_block_${block.id}'),
                            block: block,
                            enabled: !hasAnswered,
                            onTap: () => onBlockTap(block),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ConstructorSlot extends StatelessWidget {
  const _ConstructorSlot({
    super.key,
    required this.block,
    required this.enabled,
    required this.onTap,
    required this.onAccept,
  });

  final ConstructorBlock? block;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<ConstructorBlock> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ConstructorBlock>(
      onWillAcceptWithDetails: (_) => enabled,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        if (block == null) {
          return InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 78,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEEDDBA)
                    : const Color(0xFFFFFBF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF8C6A2A)
                      : const Color(0x338C6A2A),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: isActive
                    ? const Color(0xFF8C6A2A)
                    : const Color(0xFFBCA67B),
              ),
            ),
          );
        }

        return _ConstructorBlockChip(
          block: block!,
          enabled: enabled,
          onTap: onTap,
        );
      },
    );
  }
}

class _ConstructorBlockChip extends StatelessWidget {
  const _ConstructorBlockChip({
    super.key,
    required this.block,
    required this.enabled,
    required this.onTap,
  });

  final ConstructorBlock block;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1F8C6A2A)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            block.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF163832),
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      return chip;
    }

    return Draggable<ConstructorBlock>(
      data: block,
      feedback: Opacity(opacity: 0.92, child: chip),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }
}
