import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/learning_audio_player.dart';
import '../services/progress_snapshot.dart';
import '../theme/app_theme.dart';
import 'widgets/app_action_wrap.dart';
import 'widgets/app_page_header.dart';
import 'widgets/app_search_field.dart';
import 'widgets/app_section_card.dart';
import 'widgets/app_stat_chip.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({
    super.key,
    required this.words,
    required this.audioPlayerFactory,
  });

  final List<LearningWord> words;
  final CreateLearningAudioPlayer audioPlayerFactory;

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
  late List<_IndexedWord> _indexedWords;
  late List<_IndexedWord> _visibleWords;
  _WordsFilter _selectedFilter = _WordsFilter.all;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode();
    _rebuildIndex();
  }

  @override
  void didUpdateWidget(covariant WordsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.words, widget.words)) {
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
    final indexedWords =
        widget.words.map(_IndexedWord.fromWord).toList(growable: false)
          ..sort((left, right) => left.sortKey.compareTo(right.sortKey));

    _indexedWords = indexedWords;
    _visibleWords = _filterIndexedWords(indexedWords, _query, _selectedFilter);
  }

  List<_IndexedWord> _filterIndexedWords(
    List<_IndexedWord> indexedWords,
    String query,
    _WordsFilter filter,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    return indexedWords
        .where((word) => _matchesFilter(word.word, filter))
        .where(
          (word) =>
              normalizedQuery.isEmpty ||
              word.searchText.contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  bool _matchesFilter(LearningWord word, _WordsFilter filter) {
    final learningState = classifyWordLearningState(word);

    switch (filter) {
      case _WordsFilter.all:
        return true;
      case _WordsFilter.newWords:
        return learningState == WordLearningState.unseen;
      case _WordsFilter.learned:
        return learningState == WordLearningState.known;
      case _WordsFilter.review:
        return learningState == WordLearningState.needsReview;
    }
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value;
        _visibleWords = _filterIndexedWords(
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
      _visibleWords = _filterIndexedWords(
        _indexedWords,
        _query,
        _selectedFilter,
      );
    });
  }

  void _selectFilter(_WordsFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _visibleWords = _filterIndexedWords(
        _indexedWords,
        _query,
        _selectedFilter,
      );
    });
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
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF9F5EC),
      builder: (context) {
        final theme = Theme.of(context);
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
                            word.hebrew,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF163832),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            word.translation,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.transcription,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF5F5A52),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (word.hasPlannedAudio) ...[
                      const SizedBox(width: 16),
                      _WordDetailsAudioButton(
                        word: word,
                        audioPlayerFactory: widget.audioPlayerFactory,
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
                        value: word.correct,
                        accent: const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatPill(
                        label: 'Помилки',
                        value: word.wrong,
                        accent: const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'ID: ${word.wordId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6C665D),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final progress = StudyProgressSnapshot.fromWords(widget.words);
    final filterSummaries = <_WordsFilter, int>{
      _WordsFilter.all: progress.total,
      _WordsFilter.newWords: progress.unseen,
      _WordsFilter.learned: progress.known,
      _WordsFilter.review: progress.needsReview,
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
                child: AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppPageHeader(
                        title: 'Слова',
                        subtitle:
                            'Пошук за українською, англійською, транскрипцією, івритом або ID.',
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
                          for (final filter in _WordsFilter.values)
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
                            accent: const Color(0xFF1D4ED8),
                          ),
                          AppStatChip(
                            label: 'Усього',
                            value: widget.words.length,
                            accent: const Color(0xFF8C6A2A),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  child: _EmptySearchState(
                    filter: _selectedFilter,
                  ),
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
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8C6A2A),
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
                backgroundColor: const Color(0xFF8C6A2A),
                foregroundColor: Colors.white,
                child: const Icon(Icons.search_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndexedWord {
  const _IndexedWord({
    required this.word,
    required this.sortKey,
    required this.searchText,
  });

  factory _IndexedWord.fromWord(LearningWord word) {
    final normalizedTranslation = word.translation.trim().toLowerCase();
    final normalizedEnglish = word.english.trim().toLowerCase();
    final normalizedTranscription = word.transcription.trim().toLowerCase();
    final normalizedHebrew = word.hebrew.trim();
    final normalizedWordId = word.wordId.trim().toLowerCase();
    final strippedHebrew = _stripHebrewDiacritics(normalizedHebrew);

    return _IndexedWord(
      word: word,
      sortKey: normalizedTranslation,
      searchText: [
        normalizedTranslation,
        normalizedEnglish,
        normalizedTranscription,
        normalizedHebrew,
        strippedHebrew,
        normalizedWordId,
      ].where((part) => part.isNotEmpty).join('\n'),
    );
  }

  static final RegExp _hebrewDiacritics = RegExp(r'[\u0591-\u05C7]');

  final LearningWord word;
  final String sortKey;
  final String searchText;

  static String _stripHebrewDiacritics(String value) {
    return value.replaceAll(_hebrewDiacritics, '');
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.audioPlayerFactory,
    required this.onOpenDetails,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpenDetails,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
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
                        color: const Color(0xFF5F5A52),
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
                          accent: const Color(0xFF0F766E),
                        ),
                        _MiniProgress(
                          label: 'Н',
                          value: word.wrong,
                          accent: const Color(0xFFB91C1C),
                        ),
                        if (word.hasPlannedAudio)
                          _InlineWordAudioButton(
                            word: word,
                            audioPlayerFactory: audioPlayerFactory,
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
                      color: const Color(0xFF163832),
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
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Color(0xFF8C6A2A),
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

class _InlineWordAudioButton extends StatefulWidget {
  const _InlineWordAudioButton({
    required this.word,
    required this.audioPlayerFactory,
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;

  @override
  State<_InlineWordAudioButton> createState() => _InlineWordAudioButtonState();
}

class _InlineWordAudioButtonState extends State<_InlineWordAudioButton> {
  late final LearningAudioPlayer _audioPlayer = widget.audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  String get _audioAssetPath => widget.word.audioAssetPath ?? '';

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
    final audioAssetPath = widget.word.audioAssetPath;
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

    final hasAudio = await _audioPlayer.assetExists(audioAssetPath);
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
        await _audioPlayer.playAsset(_audioAssetPath);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasAudio = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _hasAudio && !_isBusy;
    final tooltip = _isCheckingAvailability
        ? 'Перевіряємо аудіо слова'
        : _hasAudio
        ? (_isPlaying ? 'Зупинити вимову слова' : 'Увімкнути вимову слова')
        : 'Аудіо для слова ще недоступне';

    return Material(
      color: const Color(0xFF8C6A2A).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: isEnabled ? _togglePlayback : null,
        borderRadius: BorderRadius.circular(999),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isBusy)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8C6A2A),
                    ),
                  )
                else
                  Icon(
                    _isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                    size: 14,
                    color: _hasAudio
                        ? const Color(0xFF8C6A2A)
                        : const Color(0xFFB8AA93),
                  ),
                const SizedBox(width: 6),
                Text(
                  'Аудіо',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _hasAudio
                        ? const Color(0xFF8C6A2A)
                        : const Color(0xFF9A907D),
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
  });

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;

  @override
  State<_WordDetailsAudioButton> createState() =>
      _WordDetailsAudioButtonState();
}

class _WordDetailsAudioButtonState extends State<_WordDetailsAudioButton> {
  late final LearningAudioPlayer _audioPlayer = widget.audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

  String get _audioAssetPath => widget.word.audioAssetPath ?? '';

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
    final audioAssetPath = widget.word.audioAssetPath;
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
    if (hasAudio) {
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
        await _audioPlayer.playAsset(_audioAssetPath);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (wasPlaying) {
          _isPlaying = false;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося відтворити вимову слова.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playbackSubscription?.cancel());
    unawaited(_audioPlayer.stop());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _isCheckingAvailability
        ? 'Перевіряємо аудіо слова'
        : _hasAudio
        ? (_isPlaying ? 'Зупинити вимову слова' : 'Увімкнути вимову слова')
        : 'Аудіо для слова ще недоступне';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8C6A2A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: _hasAudio && !_isBusy ? _togglePlayback : null,
        icon: _isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8C6A2A),
                ),
              )
            : Icon(
                _isPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_rounded,
                color: _hasAudio
                    ? const Color(0xFF8C6A2A)
                    : const Color(0xFFB8AA93),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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

enum _WordsFilter {
  all('Усі'),
  newWords('Нові'),
  learned('Вивчені'),
  review('Повторити');

  const _WordsFilter(this.label);

  final String label;
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF163832) : const Color(0xFFF7F3E8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF163832)
                  : const Color(0xFF163832).withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            '$label · $value',
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

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.filter});

  final _WordsFilter filter;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 32,
            color: Color(0xFF8C6A2A),
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
            filter == _WordsFilter.all
                ? 'Спробуйте інший запит: слово українською чи англійською, форму івритом або ID.'
                : 'У поточному зрізі «${filter.label.toLowerCase()}» поки немає результатів. Спробуйте інший фільтр або запит.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F5A52)),
          ),
        ],
      ),
    );
  }
}
