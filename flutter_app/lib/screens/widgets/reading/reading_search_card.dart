import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ReadingSearchCard extends StatelessWidget {
  const ReadingSearchCard({
    super.key,
    required this.totalCount,
    required this.visibleCount,
    required this.completedLabel,
    required this.query,
    required this.hasLevelFilter,
    required this.isSearchVisible,
    required this.isLoadingLessonTitles,
    required this.searchController,
    required this.searchFocusNode,
    required this.onToggleSearch,
    required this.onQueryChanged,
  });

  final int totalCount;
  final int visibleCount;
  final String completedLabel;
  final String query;
  final bool hasLevelFilter;
  final bool isSearchVisible;
  final bool isLoadingLessonTitles;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final hasQuery = query.trim().isNotEmpty;
    final hasAnyFilter = hasQuery || hasLevelFilter;
    final title = hasAnyFilter
        ? 'Знайдено: $visibleCount із $totalCount'
        : 'Уроків: $totalCount';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: tokens.accentSoftBorder(tokens.readingAccent),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accentMutedSurface(tokens.readingAccent),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: tokens.readingAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      completedLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isSearchVisible ? 'Сховати пошук' : 'Показати пошук',
                onPressed: onToggleSearch,
                icon: Icon(
                  isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                  color: tokens.readingAccent,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isSearchVisible || hasQuery
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _ReadingSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: 'Шукати урок за назвою',
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
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tokens.readingAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Підтягуємо заголовки уроків для точнішого пошуку.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
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

class _ReadingSearchField extends StatelessWidget {
  const _ReadingSearchField({
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
    final tokens = Theme.of(context).appTokens;

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
        fillColor: tokens.elevatedSurface,
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
          borderSide: BorderSide(
            color: tokens.accentSoftBorder(tokens.readingAccent),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: tokens.readingAccent, width: 1.5),
        ),
      ),
    );
  }
}
