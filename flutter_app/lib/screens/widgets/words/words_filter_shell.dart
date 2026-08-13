part of '../../words_screen.dart';

class _WordsFilterHeader extends StatelessWidget {
  const _WordsFilterHeader({
    required this.searchController,
    required this.searchFocusNode,
    required this.query,
    required this.selectedFilter,
    required this.filterSummaries,
    required this.visibleWordCount,
    required this.totalWordCount,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterSelected,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String query;
  final WordsFilter selectedFilter;
  final Map<WordsFilter, int> filterSummaries;
  final int visibleWordCount;
  final int totalWordCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<WordsFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: localizations.wordsTitle,
            subtitle: localizations.wordsSubtitle,
          ),
          const SizedBox(height: 18),
          AppSearchField(
            controller: searchController,
            focusNode: searchFocusNode,
            hintText: localizations.wordsSearchHint,
            onChanged: onSearchChanged,
            onClear: query.isEmpty && searchController.text.isEmpty
                ? null
                : onClearSearch,
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              for (final filter in WordsFilter.values)
                _WordsFilterChip(
                  label: _labelForFilter(filter, localizations),
                  value: filterSummaries[filter] ?? 0,
                  isSelected: selectedFilter == filter,
                  onTap: () => onFilterSelected(filter),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppActionWrap(
            children: [
              AppStatChip(
                label: localizations.wordsVisible,
                value: visibleWordCount,
                accent: tokens.infoAccent,
              ),
              AppStatChip(
                label: localizations.wordsTotal,
                value: totalWordCount,
                accent: tokens.vocabularyAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordsFloatingActions extends StatelessWidget {
  const _WordsFloatingActions({
    required this.showScrollToTop,
    required this.onScrollToTop,
    required this.onOpenSearch,
  });

  final bool showScrollToTop;
  final VoidCallback onScrollToTop;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            offset: showScrollToTop ? Offset.zero : const Offset(0, 0.25),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: showScrollToTop ? 1 : 0,
              child: IgnorePointer(
                ignoring: !showScrollToTop,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton.small(
                    heroTag: 'wordsScrollToTop',
                    onPressed: onScrollToTop,
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
            tooltip: AppLocalizations.of(context).wordsSearchTooltip,
            onPressed: onOpenSearch,
            backgroundColor: tokens.vocabularyAccent,
            foregroundColor: tokens.heroText,
            child: const Icon(Icons.search_rounded),
          ),
        ],
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
    final localizations = AppLocalizations.of(context);
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
            localizations.wordsNoResultsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            filter == WordsFilter.all
                ? localizations.wordsNoResultsAll
                : localizations.wordsNoResultsFilter(
                    _labelForFilter(filter, localizations).toLowerCase(),
                  ),
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

String _labelForFilter(WordsFilter filter, AppLocalizations localizations) {
  return switch (filter) {
    WordsFilter.all => localizations.wordsFilterAll,
    WordsFilter.newWords => localizations.wordsFilterNew,
    WordsFilter.learned => localizations.wordsFilterLearned,
    WordsFilter.review => localizations.wordsFilterReview,
  };
}
