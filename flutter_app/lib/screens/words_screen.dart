import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_word.dart';
import '../services/learning_audio_player.dart';

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
  Timer? _searchDebounce;
  String _query = '';
  late List<_IndexedWord> _indexedWords;
  late List<_IndexedWord> _visibleWords;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
    super.dispose();
  }

  void _rebuildIndex() {
    final indexedWords =
        widget.words.map(_IndexedWord.fromWord).toList(growable: false)
          ..sort((left, right) => left.sortKey.compareTo(right.sortKey));

    _indexedWords = indexedWords;
    _visibleWords = _filterIndexedWords(indexedWords, _query);
  }

  List<_IndexedWord> _filterIndexedWords(
    List<_IndexedWord> indexedWords,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return indexedWords;
    }

    return indexedWords
        .where((word) => word.searchText.contains(normalizedQuery))
        .toList(growable: false);
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value;
        _visibleWords = _filterIndexedWords(_indexedWords, _query);
      });
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _visibleWords = _indexedWords;
    });
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
                if (word.hasPlannedAudio) ...[
                  _WordAudioPanel(
                    word: word,
                    audioPlayerFactory: widget.audioPlayerFactory,
                  ),
                  const SizedBox(height: 14),
                ],
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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Слова',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Пошук за українською, англійською, транскрипцією, івритом або ID.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _SearchField(
                  controller: _searchController,
                  hintText: 'Шукати слова',
                  onChanged: _handleSearchChanged,
                  onClear: _query.isEmpty && _searchController.text.isEmpty
                      ? null
                      : _clearSearch,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatPill(
                      label: 'Видимі',
                      value: _visibleWords.length,
                      accent: const Color(0xFF1D4ED8),
                    ),
                    _StatPill(
                      label: 'Усього',
                      value: widget.words.length,
                      accent: const Color(0xFF8C6A2A),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
        if (_visibleWords.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverToBoxAdapter(child: _EmptySearchState()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
                    onTap: () => _showWordDetails(word),
                  ),
                );
              },
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFF8C6A2A), width: 1.5),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word, required this.onTap});

  final LearningWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 12),
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
                        if (word.hasPlannedAudio) const _AudioPilotBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    word.hebrew,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF163832),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF8C6A2A),
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

class _WordAudioPanel extends StatefulWidget {
  const _WordAudioPanel({required this.word, required this.audioPlayerFactory});

  final LearningWord word;
  final CreateLearningAudioPlayer audioPlayerFactory;

  @override
  State<_WordAudioPanel> createState() => _WordAudioPanelState();
}

class _WordAudioPanelState extends State<_WordAudioPanel> {
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
    final theme = Theme.of(context);
    final helperText = _isCheckingAvailability
        ? 'Перевіряємо, чи тестовий mp3 вже доступний.'
        : _hasAudio
        ? 'Тестове аудіо готове. Можна прослухати слово.'
        : 'Слово вже входить у тестовий набір, але mp3 ще не згенеровано.';

    final tooltip = _isCheckingAvailability
        ? 'Перевіряємо аудіо слова'
        : _hasAudio
        ? (_isPlaying ? 'Зупинити вимову слова' : 'Увімкнути вимову слова')
        : 'Тестове аудіо ще не згенеровано';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1F8C6A2A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тестова вимова',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF163832),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  helperText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
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
          ),
        ],
      ),
    );
  }
}

class _AudioPilotBadge extends StatelessWidget {
  const _AudioPilotBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8C6A2A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.volume_up_rounded,
            size: 14,
            color: Color(0xFF8C6A2A),
          ),
          const SizedBox(width: 6),
          Text(
            'Аудіо-тест',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF8C6A2A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 32,
            color: Color(0xFF8C6A2A),
          ),
          const SizedBox(height: 12),
          Text(
            'Нічого не знайдено.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Спробуйте інший запит: слово українською чи англійською, форму івритом або ID.',
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
