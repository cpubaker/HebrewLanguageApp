import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/learning_audio_player.dart';
import '../services/progress_snapshot.dart';
import '../services/word_learning_status_update.dart';
import '../services/word_list_filter.dart';
import '../theme/app_theme.dart';
import 'audio_playback_feedback.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_search_field.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';
import 'widgets/context_source_badge.dart';

typedef ResolveWordContexts = Future<LearningWord> Function(LearningWord word);

class WordsScreen extends StatefulWidget {
  const WordsScreen({
    super.key,
    required this.words,
    required this.audioPlayerFactory,
    this.audioPlaybackAwareness = const NoopAudioPlaybackAwareness(),
    this.resolveWordContexts,
    this.onWordProgressChanged,
    this.topContent,
  });

  final List<LearningWord> words;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;
  final ResolveWordContexts? resolveWordContexts;
  final ValueChanged<LearningWord>? onWordProgressChanged;
  final Widget? topContent;

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  static const Duration _searchDebounceDelay = Duration(milliseconds: 180);

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;
  Timer? _searchDebounce;
  String _query = '';
  late List<LearningWord> _words;
  late List<IndexedWord> _indexedWords;
  late List<IndexedWord> _visibleWords;
  WordsFilter _selectedFilter = WordsFilter.all;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode();
    _words = List<LearningWord>.from(widget.words);
    _rebuildIndex();
  }

  @override
  void didUpdateWidget(covariant WordsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.words, widget.words)) {
      _words = List<LearningWord>.from(widget.words);
      _rebuildIndex();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _rebuildIndex() {
    final indexedWords = buildWordSearchIndex(_words);

    _indexedWords = indexedWords;
    _visibleWords = filterIndexedWords(indexedWords, _query, _selectedFilter);
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value;
        _visibleWords = filterIndexedWords(
          _indexedWords,
          _query,
          _selectedFilter,
        );
      });
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _visibleWords = filterIndexedWords(
        _indexedWords,
        _query,
        _selectedFilter,
      );
    });
  }

  void _selectFilter(WordsFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _visibleWords = filterIndexedWords(
        _indexedWords,
        _query,
        _selectedFilter,
      );
    });
  }

  void _cycleWordStatus(LearningWord word) {
    final currentState = classifyWordLearningState(_currentWordFor(word));
    final nextState = nextWordLearningState(currentState);
    _updateWordStatus(word, nextState);
  }

  void _updateWordStatus(LearningWord word, WordLearningState targetState) {
    final currentWord = _currentWordFor(word);
    final updatedWord = applyWordLearningState(currentWord, targetState);

    setState(() {
      _replaceWord(updatedWord);
      _rebuildIndex();
    });
    widget.onWordProgressChanged?.call(updatedWord);
  }

  LearningWord _currentWordFor(LearningWord word) {
    for (final currentWord in _words) {
      if (currentWord.wordId == word.wordId) {
        return currentWord;
      }
    }

    return word;
  }

  void _replaceWord(LearningWord updatedWord) {
    final wordIndex = _words.indexWhere(
      (word) => word.wordId == updatedWord.wordId,
    );
    if (wordIndex < 0) {
      return;
    }

    final updatedWords = List<LearningWord>.from(_words);
    updatedWords[wordIndex] = updatedWord;
    _words = updatedWords;
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final shouldShow = _scrollController.offset > 240;
    if (shouldShow == _showScrollToTop) {
      return;
    }

    setState(() {
      _showScrollToTop = shouldShow;
    });
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openSearch() async {
    await _scrollToTop();
    if (!mounted) {
      return;
    }

    _searchFocusNode.requestFocus();
  }

  void _showWordDetails(LearningWord word) {
    final wordFuture =
        widget.resolveWordContexts?.call(word) ??
        Future<LearningWord>.value(word);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).appTokens.elevatedSurface,
      builder: (context) {
        final theme = Theme.of(context);
        final tokens = theme.appTokens;
        return FutureBuilder<LearningWord>(
          future: wordFuture,
          initialData: word,
          builder: (context, snapshot) {
            final detailWord = snapshot.data ?? word;
            final isLoadingContexts =
                snapshot.connectionState != ConnectionState.done;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detailWord.hebrew,
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                detailWord.translation,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                detailWord.transcription,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (detailWord.hasPlannedAudio) ...[
                          const SizedBox(width: 16),
                          _WordDetailsAudioButton(
                            word: detailWord,
                            audioPlayerFactory: widget.audioPlayerFactory,
                            audioPlaybackAwareness:
                                widget.audioPlaybackAwareness,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatPill(
                            label: 'Правильно',
                            value: detailWord.correct,
                            accent: tokens.successAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatPill(
                            label: 'Помилки',
                            value: detailWord.wrong,
                            accent: tokens.dangerAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ID: ${detailWord.wordId}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _WordContextsSection(
                      contexts: detailWord.contexts,
                      isLoading: isLoadingContexts,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final accentForeground = tokens.heroText;
    final progress = StudyProgressSnapshot.fromWords(_words);
    final filterSummaries = <WordsFilter, int>{
      WordsFilter.all: progress.total,
      WordsFilter.newWords: progress.unseen,
      WordsFilter.learned: progress.known,
      WordsFilter.review: progress.needsReview,
    };

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                tokens.pagePadding.left,
                tokens.pagePadding.top,
                tokens.pagePadding.right,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.topContent != null) ...[
                      widget.topContent!,
                      const SizedBox(height: 18),
                    ],
                    AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppPageHeader(
                            title: 'Слова',
                            subtitle:
                                'Шукайте українською, англійською, івритом або за транскрипцією.',
                          ),
                          const SizedBox(height: 18),
                          AppSearchField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            hintText: 'Шукати слова',
                            onChanged: _handleSearchChanged,
                            onClear:
                                _query.isEmpty && _searchController.text.isEmpty
                                ? null
                                : _clearSearch,
                          ),
                          const SizedBox(height: 16),
                          AppActionWrap(
                            children: [
                              for (final filter in WordsFilter.values)
                                _WordsFilterChip(
                                  label: filter.label,
                                  value: filterSummaries[filter] ?? 0,
                                  isSelected: _selectedFilter == filter,
                                  onTap: () => _selectFilter(filter),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppActionWrap(
                            children: [
                              AppStatChip(
                                label: 'Видимі',
                                value: _visibleWords.length,
                                accent: tokens.infoAccent,
                              ),
                              AppStatChip(
                                label: 'Усього',
                                value: _words.length,
                                accent: tokens.vocabularyAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_visibleWords.isEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  tokens.pagePadding.left,
                  16,
                  tokens.pagePadding.right,
                  32,
                ),
                sliver: SliverToBoxAdapter(
                  child: _EmptySearchState(filter: _selectedFilter),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  tokens.pagePadding.left,
                  16,
                  tokens.pagePadding.right,
                  32,
                ),
                sliver: SliverList.builder(
                  itemCount: _visibleWords.length,
                  itemBuilder: (context, index) {
                    final word = _visibleWords[index].word;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _visibleWords.length - 1 ? 0 : 12,
                      ),
                      child: _WordCard(
                        word: word,
                        audioPlayerFactory: widget.audioPlayerFactory,
                        audioPlaybackAwareness: widget.audioPlaybackAwareness,
                        onCycleStatus: () => _cycleWordStatus(word),
                        onOpenDetails: () => _showWordDetails(word),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                offset: _showScrollToTop ? Offset.zero : const Offset(0, 0.25),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showScrollToTop ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showScrollToTop,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton.small(
                        heroTag: 'wordsScrollToTop',
                        onPressed: _scrollToTop,
                        backgroundColor: tokens.elevatedSurface,
                        foregroundColor: tokens.vocabularyAccent,
                        child: const Icon(Icons.vertical_align_top_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton.small(
                heroTag: 'wordsSearch',
                tooltip: 'Пошук по словнику',
                onPressed: _openSearch,
                backgroundColor: tokens.vocabularyAccent,
                foregroundColor: accentForeground,
                child: const Icon(Icons.search_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WordContextsSection extends StatelessWidget {
  const _WordContextsSection({required this.contexts, required this.isLoading});

  final List<LearningContext> contexts;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final visibleContexts = contexts
        .where(
          (entry) =>
              entry.hebrew.trim().isNotEmpty ||
              entry.translation.trim().isNotEmpty,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Контексти',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.mutedText,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (visibleContexts.isEmpty)
          Text(
            isLoading
                ? 'Шукаємо новий контекст...'
                : 'Для цього слова ще немає контексту.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.secondaryText,
              height: 1.45,
            ),
          )
        else
          for (final entry in visibleContexts) ...[
            _WordContextTile(contextEntry: entry),
            if (entry != visibleContexts.last) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _WordContextTile extends StatelessWidget {
  const _WordContextTile({required this.contextEntry});

  final LearningContext contextEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final hasHebrew = contextEntry.hebrew.runes.any(
      (codePoint) => codePoint >= 0x0590 && codePoint <= 0x05FF,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.subtleSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (contextEntry.isAiGenerated) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: ContextSourceBadge(context: contextEntry),
            ),
            const SizedBox(height: 8),
          ],
          if (contextEntry.hebrew.trim().isNotEmpty)
            Text(
              contextEntry.hebrew,
              textDirection: hasHebrew ? TextDirection.rtl : TextDirection.ltr,
              textAlign: hasHebrew ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          if (contextEntry.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              contextEntry.translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
    required this.onCycleStatus,
    required this.onOpenDetails,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;
  final VoidCallback onCycleStatus;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final learningState = classifyWordLearningState(word);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpenDetails,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.elevatedSurface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.transcription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniProgress(
                          label: 'П',
                          value: word.correct,
                          accent: tokens.successAccent,
                        ),
                        _MiniProgress(
                          label: 'Н',
                          value: word.wrong,
                          accent: tokens.dangerAccent,
                        ),
                        if (word.hasPlannedAudio)
                          _InlineWordAudioButton(
                            word: word,
                            audioPlayerFactory: audioPlayerFactory,
                            audioPlaybackAwareness: audioPlaybackAwareness,
                          ),
                        _WordStatusActionButton(
                          state: learningState,
                          onTap: onCycleStatus,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    word.hebrew,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    tooltip: 'Відкрити слово',
                    onPressed: onOpenDetails,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: tokens.vocabularyAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordStatusActionButton extends StatelessWidget {
  const _WordStatusActionButton({required this.state, required this.onTap});

  final WordLearningState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final presentation = _WordStatusPresentation.fromState(state, tokens);
    final foreground = presentation.accent;
    return Material(
      color: presentation.accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Tooltip(
          message: 'Змінити статус слова',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: presentation.accent.withValues(alpha: 0.24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(presentation.icon, size: 14, color: foreground),
                const SizedBox(width: 6),
                Text(
                  presentation.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
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

class _WordStatusPresentation {
  const _WordStatusPresentation({
    required this.label,
    required this.icon,
    required this.accent,
  });

  factory _WordStatusPresentation.fromState(
    WordLearningState state,
    AppThemeTokens tokens,
  ) {
    return switch (state) {
      WordLearningState.unseen => _WordStatusPresentation(
        label: 'Не знаю',
        icon: Icons.help_outline_rounded,
        accent: tokens.vocabularyAccent,
      ),
      WordLearningState.needsReview => _WordStatusPresentation(
        label: 'Вчу',
        icon: Icons.school_rounded,
        accent: tokens.vocabularyAccent,
      ),
      WordLearningState.known => _WordStatusPresentation(
        label: 'Знаю',
        icon: Icons.check_rounded,
        accent: tokens.successAccent,
      ),
    };
  }

  final String label;
  final IconData icon;
  final Color accent;
}

abstract class _WordAudioButtonState<T extends StatefulWidget>
    extends State<T> {
  late final LearningAudioPlayer _audioPlayer = audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  AudioPlaybackAwareness get audioPlaybackAwareness;

  CreateLearningAudioPlayer get audioPlayerFactory;

  LearningWord get word;

  bool get clearPlayingAfterStop => false;

  bool get prepareAudioBeforeEnable => false;

  bool get _isAudioEnabled => _hasAudio && !_isBusy;

  String get _audioAssetPath => word.audioAssetPath ?? '';

  String get _audioTooltip {
    if (_isCheckingAvailability) {
      return 'Перевіряємо аудіо слова';
    }

    if (!_hasAudio) {
      return 'Аудіо для слова ще недоступне';
    }

    return _isPlaying ? 'Зупинити вимову слова' : 'Увімкнути вимову слова';
  }

  @override
  void initState() {
    super.initState();
    _playbackSubscription = _audioPlayer.isPlayingStream.listen((isPlaying) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlaying = isPlaying;
      });
    });
    unawaited(_checkAudioAvailability());
  }

  Future<void> _checkAudioAvailability() async {
    final audioAssetPath = word.audioAssetPath;
    if (audioAssetPath == null || audioAssetPath.trim().isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasAudio = false;
        _isCheckingAvailability = false;
      });
      return;
    }

    var hasAudio = await _audioPlayer.assetExists(audioAssetPath);
    if (hasAudio && prepareAudioBeforeEnable) {
      try {
        hasAudio = await _audioPlayer.prepareAsset(audioAssetPath);
      } catch (_) {
        hasAudio = false;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasAudio = hasAudio;
      _isCheckingAvailability = false;
    });
  }

  Future<void> _togglePlayback() async {
    final wasPlaying = _isPlaying;

    setState(() {
      _isBusy = true;
    });

    try {
      if (wasPlaying) {
        await _audioPlayer.stop();
      } else {
        await showAudioPlaybackHintIfNeeded(
          context: context,
          awareness: audioPlaybackAwareness,
        );
        await _audioPlayer.playAsset(_audioAssetPath);
      }

      if (!mounted) {
        return;
      }

      if (wasPlaying && clearPlayingAfterStop) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        updatePlaybackErrorState(error);
      });
      showPlaybackErrorFeedback(error);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void updatePlaybackErrorState(Object error) {}

  void showPlaybackErrorFeedback(Object error) {}

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }
}

class _InlineWordAudioButton extends StatefulWidget {
  const _InlineWordAudioButton({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_InlineWordAudioButton> createState() => _InlineWordAudioButtonState();
}

class _InlineWordAudioButtonState
    extends _WordAudioButtonState<_InlineWordAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  CreateLearningAudioPlayer get audioPlayerFactory => widget.audioPlayerFactory;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    _hasAudio = false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Material(
      color: tokens.vocabularyAccent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: _isAudioEnabled ? _togglePlayback : null,
        borderRadius: BorderRadius.circular(999),
        child: Tooltip(
          message: _audioTooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isBusy)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.vocabularyAccent,
                    ),
                  )
                else
                  Icon(
                    _isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                    size: 14,
                    color: _hasAudio
                        ? tokens.vocabularyAccent
                        : tokens.secondaryText,
                  ),
                const SizedBox(width: 6),
                Text(
                  'Аудіо',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _hasAudio
                        ? tokens.vocabularyAccent
                        : tokens.secondaryText,
                    fontWeight: FontWeight.w700,
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

class _WordDetailsAudioButton extends StatefulWidget {
  const _WordDetailsAudioButton({
    required this.word,
    required this.audioPlayerFactory,
    required this.audioPlaybackAwareness,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final AudioPlaybackAwareness audioPlaybackAwareness;

  @override
  State<_WordDetailsAudioButton> createState() =>
      _WordDetailsAudioButtonState();
}

class _WordDetailsAudioButtonState
    extends _WordAudioButtonState<_WordDetailsAudioButton> {
  @override
  AudioPlaybackAwareness get audioPlaybackAwareness =>
      widget.audioPlaybackAwareness;

  @override
  CreateLearningAudioPlayer get audioPlayerFactory => widget.audioPlayerFactory;

  @override
  bool get clearPlayingAfterStop => true;

  @override
  bool get prepareAudioBeforeEnable => true;

  @override
  LearningWord get word => widget.word;

  @override
  void updatePlaybackErrorState(Object error) {
    _isPlaying = false;
  }

  @override
  void showPlaybackErrorFeedback(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не вдалося відтворити вимову слова.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.vocabularyAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        tooltip: _audioTooltip,
        onPressed: _isAudioEnabled ? _togglePlayback : null,
        icon: _isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.vocabularyAccent,
                ),
              )
            : Icon(
                _isPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                color: _hasAudio
                    ? tokens.vocabularyAccent
                    : tokens.secondaryText,
              ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
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
            Text(
              '$label: $value',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordsFilterChip extends StatelessWidget {
  const _WordsFilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : tokens.subtleSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : tokens.outlineSoft,
            ),
          ),
          child: Text(
            '$label · $value',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.filter});

  final WordsFilter filter;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return AppSectionCard(
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: tokens.vocabularyAccent,
          ),
          const SizedBox(height: 12),
          Text(
            'Нічого не знайдено',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            filter == WordsFilter.all
                ? 'Спробуйте інший запит: слово українською чи англійською, форму івритом або транскрипцію.'
                : 'У поточному зрізі «${filter.label.toLowerCase()}» поки немає результатів. Спробуйте інший фільтр або запит.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );
  }
}
