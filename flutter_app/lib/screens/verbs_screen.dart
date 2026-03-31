import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_bundle.dart';
import '../models/lesson_document.dart';
import '../services/lesson_document_loader.dart';
import '../services/verb_audio_player.dart';
import 'widgets/markdown_lesson_body.dart';

class VerbsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Verbs',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Core verb lessons synced from the desktop content, ready for list/detail study on mobile.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5F5A52),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.play_lesson_rounded,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 12),
              Text(
                '${lessons.length} verb lessons available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _VerbLessonCard(
              lesson: lesson,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerbDetailScreen(
                      lesson: lesson,
                      documentLoader: documentLoader,
                      audioPlayerFactory: audioPlayerFactory,
                    ),
                  ),
                );
              },
            ),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load this verb lesson.',
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

class _VerbLessonCard extends StatelessWidget {
  const _VerbLessonCard({
    required this.lesson,
    required this.onTap,
  });

  final LessonEntry lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderMatch = RegExp(r'^(\d+)').firstMatch(lesson.displayName);
    final orderLabel = orderMatch?.group(1) ?? '*';
    final titleLabel = lesson.displayName.replaceFirst(RegExp(r'^\d+\s+'), '');

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
                  titleLabel,
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
        const SnackBar(
          content: Text('Could not play this pronunciation right now.'),
        ),
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
          colors: [
            Color(0xFF5B21B6),
            Color(0xFF7C3AED),
          ],
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
                  ? 'Checking pronunciation'
                  : _hasAudio
                      ? (_isPlaying ? 'Stop audio' : 'Play audio')
                      : 'No audio available',
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
  const _VerbImageCard({
    required this.imageAssetPath,
  });

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
                            'No synced illustration for this verb yet.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
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
