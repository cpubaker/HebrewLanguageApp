import 'package:flutter/material.dart';

import '../models/learning_word.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key, required this.words});

  final List<LearningWord> words;

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LearningWord> get _filteredWords {
    final normalizedQuery = _query.trim().toLowerCase();
    final sortedWords = [...widget.words]
      ..sort((left, right) => left.english.compareTo(right.english));

    if (normalizedQuery.isEmpty) {
      return sortedWords;
    }

    return sortedWords
        .where((word) {
          return word.english.toLowerCase().contains(normalizedQuery) ||
              word.transcription.toLowerCase().contains(normalizedQuery) ||
              word.hebrew.toLowerCase().contains(normalizedQuery) ||
              word.wordId.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
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
                word.english,
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
              Text(
                'ID: ${word.wordId}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C665D),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _filteredWords;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          'Слова',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Пошук за англійською, транскрипцією, івритом або ID.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5F5A52),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        _SearchField(
          controller: _searchController,
          hintText: 'Шукати слова',
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          onClear: _query.isEmpty
              ? null
              : () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                  });
                },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatPill(
              label: 'Видимі',
              value: filteredWords.length,
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
        if (filteredWords.isEmpty)
          const _EmptySearchState()
        else
          ...filteredWords.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WordCard(word: word, onTap: () => _showWordDetails(word)),
            ),
          ),
      ],
    );
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
                      word.english,
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
                    Row(
                      children: [
                        _MiniProgress(
                          label: 'П',
                          value: word.correct,
                          accent: const Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 8),
                        _MiniProgress(
                          label: 'Н',
                          value: word.wrong,
                          accent: const Color(0xFFB91C1C),
                        ),
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
            'Спробуйте інший запит: слово англійською, форму івритом або ID.',
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
