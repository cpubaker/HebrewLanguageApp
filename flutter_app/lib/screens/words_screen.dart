import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_context.dart';
import '../models/learning_word.dart';
import '../services/audio_playback_awareness.dart';
import '../services/learning_audio_controller.dart';
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

part 'widgets/words/words_audio_buttons.dart';
part 'widgets/words/words_detail_sheet.dart';
part 'widgets/words/words_filter_shell.dart';
part 'widgets/words/words_list_items.dart';

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

    _showWordDetailsSheet(
      context: context,
      initialWord: word,
      wordFuture: wordFuture,
      audioPlayerFactory: widget.audioPlayerFactory,
      audioPlaybackAwareness: widget.audioPlaybackAwareness,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
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
                    _WordsFilterHeader(
                      searchController: _searchController,
                      searchFocusNode: _searchFocusNode,
                      query: _query,
                      selectedFilter: _selectedFilter,
                      filterSummaries: filterSummaries,
                      visibleWordCount: _visibleWords.length,
                      totalWordCount: _words.length,
                      onSearchChanged: _handleSearchChanged,
                      onClearSearch: _clearSearch,
                      onFilterSelected: _selectFilter,
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
        _WordsFloatingActions(
          showScrollToTop: _showScrollToTop,
          onScrollToTop: _scrollToTop,
          onOpenSearch: _openSearch,
        ),
      ],
    );
  }
}
