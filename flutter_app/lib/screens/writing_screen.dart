import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/flashcard_session.dart';
import '../services/learning_audio_controller.dart';
import '../services/learning_audio_player.dart';
import '../services/writing_session.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/practice_audio_button.dart';
import 'widgets/practice_feedback_card.dart';
import 'widgets/practice_header.dart';
import 'widgets/practice_session_summary.dart';
import 'widgets/practice_stats_row.dart';

enum WritingPracticeMode { typing, constructor }

class WritingScreen extends StatefulWidget {
  const WritingScreen({
    super.key,
    required this.words,
    required this.onWordProgressChanged,
    this.initialMode = WritingPracticeMode.typing,
    this.audioPlayerFactory,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
  });

  final List<LearningWord> words;
  final WordProgressCallback onWordProgressChanged;
  final WritingPracticeMode initialMode;
  final CreateLearningAudioPlayer? audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late final WritingSession _session;
  late final TextEditingController _answerController;
  late final LearningAudioController _audioController = LearningAudioController(
    audioPlayerFactory:
        widget.audioPlayerFactory ?? createAssetLearningAudioPlayer,
  )..addListener(_handleAudioStateChanged);

  late WritingPracticeMode _mode;
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
    _mode = widget.initialMode;
    _moveToNextPrompt();
  }

  @override
  void dispose() {
    _audioController
      ..removeListener(_handleAudioStateChanged)
      ..dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _moveToNextPrompt() {
    final nextPrompt = _session.nextPrompt();
    setState(() {
      _currentPrompt = nextPrompt;
      _currentAnswer = null;
      _inlineMessage = null;
      _answerController.clear();
      _resetConstructorState(_currentPrompt?.constructorPuzzle);
    });
    if (_mode == WritingPracticeMode.typing) {
      unawaited(_syncWordAudio(nextPrompt?.word));
    } else {
      unawaited(_stopWordAudio());
    }
  }

  void _submitAnswer() {
    final answer = _mode == WritingPracticeMode.typing
        ? _answerController.text
        : _buildConstructorAnswer();

    if (_mode == WritingPracticeMode.constructor &&
        _selectedBlocks.any((block) => block == null)) {
      setState(() {
        _inlineMessage = 'Заповніть усі склади, а потім перевіряйте відповідь.';
      });
      return;
    }

    final result = _session.submitAnswer(answer);
    if (result == null) {
      return;
    }

    if (result.status == WritingAnswerStatus.empty) {
      setState(() {
        _inlineMessage = _mode == WritingPracticeMode.typing
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

    if (_mode == WritingPracticeMode.constructor) {
      unawaited(_syncWordAudio(result.word));
    }
  }

  void _submitUnknownAnswer() {
    final result = _session.submitUnknown();
    if (result == null) {
      return;
    }

    setState(() {
      _currentAnswer = result;
      _inlineMessage = null;
    });

    widget.onWordProgressChanged(result.word);

    if (_mode == WritingPracticeMode.constructor) {
      unawaited(_syncWordAudio(result.word));
    }
  }

  Future<void> _stopWordAudio() async {
    await _audioController.stop(clearAvailability: true);
  }

  Future<void> _syncWordAudio(LearningWord? word) async {
    await _audioController.autoplay(word?.audioAssetPath);
  }

  Future<void> _replayCurrentWordAudio() async {
    final word = (_currentAnswer?.word ?? _currentPrompt?.word);
    final audioAssetPath = word?.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      return;
    }
    if (!_audioController.hasAudio) {
      return;
    }

    try {
      await _audioController.toggle(
        audioAssetPath,
        beforePlay: () => showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: widget.audioPlaybackAwareness,
        ),
        recheckBeforePlay: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося відтворити озвучку слова.')),
      );
    }
  }

  void _handleAudioStateChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final theme = Theme.of(context);
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tokens.practicePromptGradientStart,
                      tokens.practicePromptGradientEnd,
                    ],
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentPrompt.prompt,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (_mode == WritingPracticeMode.typing &&
                        _audioController.hasAudio) ...[
                      const SizedBox(height: 12),
                      PracticeAudioButton(
                        key: const ValueKey('writing_audio_button'),
                        isBusy: _audioController.isBusy,
                        isPlaying: _audioController.isPlaying,
                        onPressed: _audioController.isBusy
                            ? null
                            : _replayCurrentWordAudio,
                      ),
                    ],
                    if (_mode == WritingPracticeMode.typing) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Без підказок: спробуйте пригадати слово самостійно.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tokens.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_mode == WritingPracticeMode.typing)
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
                    fillColor: tokens.subtleSurface,
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
                      borderSide: BorderSide(color: tokens.outlineSoft),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: tokens.vocabularyAccent,
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
                  resultCard: hasAnswered
                      ? _buildWritingFeedbackCard(
                          isCorrect: isCorrect,
                          correctAnswer:
                              _currentAnswer?.correctAnswer ??
                              currentWord.hebrew,
                          audioButton: _audioController.hasAudio
                              ? PracticeAudioButton(
                                  key: const ValueKey(
                                    'constructor_result_audio_button',
                                  ),
                                  isBusy: _audioController.isBusy,
                                  isPlaying: _audioController.isPlaying,
                                  onPressed: _audioController.isBusy
                                      ? null
                                      : _replayCurrentWordAudio,
                                )
                              : null,
                        )
                      : null,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.warningAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (hasAnswered && _mode == WritingPracticeMode.typing) ...[
                _buildWritingFeedbackCard(
                  isCorrect: isCorrect,
                  correctAnswer:
                      _currentAnswer?.correctAnswer ?? currentWord.hebrew,
                ),
                const SizedBox(height: 18),
              ] else if (_mode == WritingPracticeMode.typing) ...[
                Text(
                  'Натисніть «Перевірити», коли будете готові.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              PracticeStatsRow(
                stats: _mode == WritingPracticeMode.constructor
                    ? [
                        PracticeStatItem(
                          label: 'Помилки',
                          value: stats.wrong,
                          accent: tokens.dangerAccent,
                        ),
                        PracticeStatItem(
                          label: 'Вірно',
                          value: stats.correct,
                          accent: tokens.successAccent,
                        ),
                      ]
                    : [
                        PracticeStatItem(
                          label: 'Вірно',
                          value: stats.correct,
                          accent: tokens.successAccent,
                        ),
                        PracticeStatItem(
                          label: 'Помилки',
                          value: stats.wrong,
                          accent: tokens.dangerAccent,
                        ),
                      ],
              ),
              const SizedBox(height: 18),
              _WritingActionButtons(
                mode: _mode,
                hasAnswered: hasAnswered,
                onSubmit: _submitAnswer,
                onUnknown: _submitUnknownAnswer,
                onNext: _moveToNextPrompt,
              ),
              if (_mode == WritingPracticeMode.typing) ...[
                const SizedBox(height: 16),
                PracticeSessionSummary(
                  title: 'Поточна сесія',
                  lines: [
                    'Перевірено відповідей: ${_session.answeredCount}',
                    '${widget.words.length} слів доступні для письма на цьому пристрої',
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWritingFeedbackCard({
    required bool isCorrect,
    required String correctAnswer,
    Widget? audioButton,
  }) {
    return PracticeFeedbackCard(
      tone: isCorrect
          ? PracticeFeedbackTone.success
          : PracticeFeedbackTone.error,
      title: isCorrect ? 'Правильно' : 'Ось правильний варіант',
      primaryText: correctAnswer,
      primaryTextDirection: TextDirection.rtl,
      extraContent: audioButton,
      message: isCorrect
          ? 'Слово записано правильно. Можна переходити далі.'
          : 'Нічого страшного. Повернемось до цього слова пізніше.',
      showMessage: !isCorrect,
    );
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

class _WritingActionButtons extends StatelessWidget {
  const _WritingActionButtons({
    required this.mode,
    required this.hasAnswered,
    required this.onSubmit,
    required this.onUnknown,
    required this.onNext,
  });

  final WritingPracticeMode mode;
  final bool hasAnswered;
  final VoidCallback onSubmit;
  final VoidCallback onUnknown;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (mode == WritingPracticeMode.constructor) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: hasAnswered ? null : onUnknown,
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text('Не знаю'),
          ),
          OutlinedButton.icon(
            onPressed: hasAnswered ? onNext : onSubmit,
            icon: Icon(
              hasAnswered ? Icons.arrow_forward_rounded : Icons.check_rounded,
            ),
            label: Text(hasAnswered ? 'Далі' : 'Перевірити'),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: hasAnswered ? null : onSubmit,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Перевірити'),
        ),
        OutlinedButton.icon(
          onPressed: hasAnswered ? onNext : null,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Далі'),
        ),
      ],
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
          title: 'Написання',
          subtitle:
              'Коли слова завантажаться, тут можна буде тренувати написання івритом або складати слова з блоків.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            'Щойно у наборі з’являться доступні слова, тут можна буде тренувати письмо окремою сесією.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: tokens.mutedText,
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
    required this.resultCard,
    required this.onBlockTap,
    required this.onSlotTap,
    required this.onBlockDroppedOnSlot,
    required this.onBlockDroppedToPool,
  });

  final bool hasAnswered;
  final List<ConstructorBlock> availableBlocks;
  final List<ConstructorBlock?> selectedBlocks;
  final Widget? resultCard;
  final ValueChanged<ConstructorBlock> onBlockTap;
  final ValueChanged<int> onSlotTap;
  final void Function(ConstructorBlock block, int slotIndex)
  onBlockDroppedOnSlot;
  final ValueChanged<ConstructorBlock> onBlockDroppedToPool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.subtleSurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Складіть слово',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Перетягніть блоки у правильному порядку. Натискання на блок теж працює.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.secondaryText,
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
        if (resultCard != null)
          resultCard!
        else
          DragTarget<ConstructorBlock>(
            onWillAcceptWithDetails: (_) => !hasAnswered,
            onAcceptWithDetails: (details) =>
                onBlockDroppedToPool(details.data),
            builder: (context, candidateData, rejectedData) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tokens.elevatedSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? tokens.vocabularyAccent
                        : tokens.outlineSoft,
                    width: candidateData.isNotEmpty ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Доступні блоки',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tokens.mutedText,
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
    final tokens = Theme.of(context).appTokens;

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
                    ? tokens.constructorActiveSurface
                    : tokens.constructorIdleSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? tokens.vocabularyAccent
                      : tokens.outlineSoft,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: isActive
                    ? tokens.vocabularyAccent
                    : tokens.constructorIdleAccent,
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
    final theme = Theme.of(context);
    final tokens = theme.appTokens;

    final chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tokens.outlineSoft),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
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
              color: theme.colorScheme.onSurface,
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
