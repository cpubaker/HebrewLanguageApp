import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import '../services/verb_audio_player.dart';
import 'widgets/markdown_lesson_body.dart';

class VerbsScreen extends StatefulWidget {
  const VerbsScreen({
    super.key,
    required this.lessons,
    required this.documentLoader,
    required this.audioPlayerFactory,
  });

  final List<LessonEntry> lessons;
  final LessonDocumentLoader documentLoader;
  final CreateVerbAudioPlayer audioPlayerFactory;

  @override
  State<VerbsScreen> createState() => _VerbsScreenState();
}

class _VerbsScreenState extends State<VerbsScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;

  final Map<String, String> _lessonTitles = <String, String>{};

  String _query = '';
  bool _searchVisible = false;
  bool _showScrollToTop = false;
  bool _isLoadingLessonTitles = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode();
    unawaited(_primeLessonTitles());
  }

  @override
  void didUpdateWidget(covariant VerbsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons != widget.lessons) {
      unawaited(_primeLessonTitles());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _primeLessonTitles() async {
    if (_isLoadingLessonTitles) {
      return;
    }

    final missingLessons = widget.lessons
        .where((lesson) => !_lessonTitles.containsKey(lesson.assetPath))
        .toList(growable: false);
    if (missingLessons.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingLessonTitles = true;
    });

    const batchSize = 24;

    try {
      for (
        var startIndex = 0;
        startIndex < missingLessons.length;
        startIndex += batchSize
      ) {
        final batch = missingLessons.skip(startIndex).take(batchSize);
        final resolvedTitles = await Future.wait(
          batch.map((lesson) async {
            try {
              final document = await widget.documentLoader.load(lesson.assetPath);
              final title = document.title.trim();
              return MapEntry<String, String?>(lesson.assetPath, title);
            } catch (_) {
              return MapEntry<String, String?>(lesson.assetPath, null);
            }
          }),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          for (final entry in resolvedTitles) {
            final title = entry.value;
            if (title != null && title.isNotEmpty) {
              _lessonTitles[entry.key] = title;
            }
          }
        });

        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLessonTitles = false;
        });
      }
    }
  }

  Future<void> _ensureLessonTitlesLoaded() async {
    if (_isLoadingLessonTitles) {
      while (mounted && _isLoadingLessonTitles) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
      return;
    }

    if (_lessonTitles.length < widget.lessons.length) {
      await _primeLessonTitles();
    }
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
    if (!_searchVisible) {
      setState(() {
        _searchVisible = true;
      });
    }

    await _scrollToTop();
    if (!mounted) {
      return;
    }

    _searchFocusNode.requestFocus();
    unawaited(_ensureLessonTitlesLoaded());
  }

  void _toggleSearchVisibility() {
    if (!_searchVisible) {
      unawaited(_openSearch());
      return;
    }

    if (_query.isNotEmpty) {
      _searchController.clear();
      setState(() {
        _query = '';
      });
      return;
    }

    _searchFocusNode.unfocus();
    setState(() {
      _searchVisible = false;
    });
  }

  String _resolvedLessonTitle(LessonEntry lesson) {
    final cachedTitle = _lessonTitles[lesson.assetPath];
    if (cachedTitle != null && cachedTitle.trim().isNotEmpty) {
      return cachedTitle.trim();
    }

    return lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '');
  }

  List<LessonEntry> get _filteredLessons {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return widget.lessons;
    }

    return widget.lessons.where((lesson) {
      final title = _resolvedLessonTitle(lesson).toLowerCase();
      final displayName = lesson.displayName.toLowerCase();
      final assetName = lesson.assetPath.split('/').last.toLowerCase();

      return title.contains(normalizedQuery) ||
          displayName.contains(normalizedQuery) ||
          assetName.contains(normalizedQuery);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _filteredLessons;
    final hasResults = filteredLessons.isNotEmpty;
    final itemCount = hasResults ? filteredLessons.length + 5 : 6;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                'Дієслова',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              );
            }

            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Основні дієслова з поясненнями, вимовою та ілюстраціями.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5F5A52),
                    height: 1.4,
                  ),
                ),
              );
            }

            if (index == 2) {
              return const SizedBox(height: 18);
            }

            if (index == 3) {
              return _VerbSearchCard(
                totalCount: widget.lessons.length,
                visibleCount: filteredLessons.length,
                query: _query,
                isSearchVisible: _searchVisible,
                isLoadingLessonTitles: _isLoadingLessonTitles,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onToggleSearch: _toggleSearchVisibility,
                onQueryChanged: (value) {
                  setState(() {
                    _query = value;
                    if (value.trim().isNotEmpty) {
                      _searchVisible = true;
                    }
                  });
                },
              );
            }

            if (index == 4) {
              return const SizedBox(height: 18);
            }

            if (!hasResults) {
              return const _EmptyVerbSearchState();
            }

            final lesson = filteredLessons[index - 5];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VerbLessonCard(
                lesson: lesson,
                resolvedTitle: _resolvedLessonTitle(lesson),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VerbDetailScreen(
                        lesson: lesson,
                        documentLoader: widget.documentLoader,
                        audioPlayerFactory: widget.audioPlayerFactory,
                      ),
                    ),
                  );
                },
              ),
            );
          },
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
                        heroTag: 'verbsScrollToTop',
                        onPressed: _scrollToTop,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7C3AED),
                        child: const Icon(Icons.vertical_align_top_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton.small(
                heroTag: 'verbsSearch',
                onPressed: _openSearch,
                backgroundColor: const Color(0xFF7C3AED),
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

class VerbDetailScreen extends StatelessWidget {
  const VerbDetailScreen({
    super.key,
    required this.lesson,
    required this.documentLoader,
    required this.audioPlayerFactory,
  });

  final LessonEntry lesson;
  final LessonDocumentLoader documentLoader;
  final CreateVerbAudioPlayer audioPlayerFactory;

  @override
  Widget build(BuildContext context) {
    final media = _VerbMediaPaths.fromLesson(lesson);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<LessonDocument>(
        future: documentLoader.load(lesson.assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не вдалося відкрити цей урок.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final document = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _VerbHeroCard(
                title: document.title,
                audioAssetPath: media.audioAssetPath,
                audioPlayerFactory: audioPlayerFactory,
              ),
              const SizedBox(height: 18),
              _VerbImageCard(imageAssetPath: media.imageAssetPath),
              const SizedBox(height: 18),
              MarkdownLessonBody(
                body: document.body,
                accentColor: const Color(0xFF7C3AED),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VerbSearchCard extends StatelessWidget {
  const _VerbSearchCard({
    required this.totalCount,
    required this.visibleCount,
    required this.query,
    required this.isSearchVisible,
    required this.isLoadingLessonTitles,
    required this.searchController,
    required this.searchFocusNode,
    required this.onToggleSearch,
    required this.onQueryChanged,
  });

  final int totalCount;
  final int visibleCount;
  final String query;
  final bool isSearchVisible;
  final bool isLoadingLessonTitles;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_lesson_rounded, color: Color(0xFF7C3AED)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasQuery
                      ? 'Знайдено: $visibleCount із $totalCount'
                      : 'Уроків: $totalCount',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: isSearchVisible ? 'Сховати пошук' : 'Показати пошук',
                onPressed: onToggleSearch,
                icon: Icon(
                  isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isSearchVisible || hasQuery
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              'Швидкий пошук по назві уроку або імені файла.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F5A52),
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: 'Шукати дієслово',
                onChanged: onQueryChanged,
                onClear: hasQuery
                    ? () {
                        searchController.clear();
                        onQueryChanged('');
                      }
                    : null,
              ),
            ),
          ),
          if (isLoadingLessonTitles && (isSearchVisible || hasQuery)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Підтягуємо українські назви для точнішого пошуку.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F5A52),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
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
          borderSide: const BorderSide(color: Color(0x1F7C3AED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
    );
  }
}

class _VerbLessonCard extends StatelessWidget {
  const _VerbLessonCard({
    required this.lesson,
    required this.resolvedTitle,
    required this.onTap,
  });

  final LessonEntry lesson;
  final String resolvedTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
    final orderLabel = orderMatch?.group(1) ?? '*';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
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
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  orderLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  resolvedTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF7C3AED),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVerbSearchState extends StatelessWidget {
  const _EmptyVerbSearchState();

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
            color: Color(0xFF7C3AED),
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
            'Спробуйте інший запит: назву дієслова українською або частину імені файла.',
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

class _VerbHeroCard extends StatefulWidget {
  const _VerbHeroCard({
    required this.title,
    required this.audioAssetPath,
    required this.audioPlayerFactory,
  });

  final String title;
  final String audioAssetPath;
  final CreateVerbAudioPlayer audioPlayerFactory;

  @override
  State<_VerbHeroCard> createState() => _VerbHeroCardState();
}

class _VerbHeroCardState extends State<_VerbHeroCard> {
  late final VerbAudioPlayer _audioPlayer = widget.audioPlayerFactory();
  StreamSubscription<bool>? _playbackSubscription;
  bool _isCheckingAvailability = true;
  bool _hasAudio = false;
  bool _isPlaying = false;
  bool _isBusy = false;

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
    _checkAudioAvailability();
  }

  Future<void> _checkAudioAvailability() async {
    final hasAudio = await _audioPlayer.assetExists(widget.audioAssetPath);
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
        await _audioPlayer.playAsset(widget.audioAssetPath);
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
        const SnackBar(content: Text('Не вдалося відтворити вимову.')),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              tooltip: _isCheckingAvailability
                  ? 'Перевіряємо аудіо'
                  : _hasAudio
                  ? (_isPlaying ? 'Зупинити вимову' : 'Увімкнути вимову')
                  : 'Аудіо поки недоступне',
              onPressed: _hasAudio && !_isBusy ? _togglePlayback : null,
              icon: _isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.volume_up_rounded,
                      color: _hasAudio ? Colors.white : Colors.white70,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerbImageCard extends StatelessWidget {
  const _VerbImageCard({required this.imageAssetPath});

  final String imageAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF7F1FF),
                    Color(0xFFF3ECFF),
                    Color(0xFFF9F6ED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 5 / 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    imageAssetPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                            color: Color(0xFF7C3AED),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ілюстрацію для цього дієслова ще не додано.',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerbMediaPaths {
  const _VerbMediaPaths({
    required this.imageAssetPath,
    required this.audioAssetPath,
  });

  final String imageAssetPath;
  final String audioAssetPath;

  factory _VerbMediaPaths.fromLesson(LessonEntry lesson) {
    final filename = lesson.assetPath.split('/').last;
    final lessonStem = filename.replaceFirst(RegExp(r'\.md$'), '');
    final assetStem = lessonStem.replaceFirst(RegExp(r'^\d+[_-]*'), '');

    return _VerbMediaPaths(
      imageAssetPath: 'assets/learning/input/images/verbs/$assetStem.png',
      audioAssetPath: 'assets/learning/input/audio/verbs/$assetStem.mp3',
    );
  }
}
