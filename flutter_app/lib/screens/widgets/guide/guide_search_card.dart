import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';

class GuideSearchCard extends StatelessWidget {
  const GuideSearchCard({
    super.key,
    required this.totalCount,
    required this.completedLabel,
    required this.visibleCount,
    required this.query,
    required this.selectedSectionLabels,
    required this.isSearchVisible,
    required this.isLoadingLessonDocuments,
    required this.searchController,
    required this.searchFocusNode,
    required this.onToggleSearch,
    required this.onOpenSectionPicker,
    required this.onQueryChanged,
  });

  final int totalCount;
  final String completedLabel;
  final int visibleCount;
  final String query;
  final List<String> selectedSectionLabels;
  final bool isSearchVisible;
  final bool isLoadingLessonDocuments;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onToggleSearch;
  final VoidCallback? onOpenSectionPicker;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    final localizations = AppLocalizations.of(context);
    final hasQuery = query.trim().isNotEmpty;
    final hasSectionFilter = selectedSectionLabels.isNotEmpty;
    final title = hasQuery || hasSectionFilter
        ? localizations.catalogFound(totalCount, visibleCount)
        : localizations.catalogGuideCount(totalCount);
    final readCount =
        int.tryParse(
          RegExp(r'\d+').firstMatch(completedLabel)?.group(0) ?? '',
        ) ??
        0;
    final subtitle = !hasSectionFilter
        ? localizations.catalogReadCount(readCount, totalCount)
        : selectedSectionLabels.length == 1
        ? localizations.catalogSection(readCount, selectedSectionLabels.first, totalCount)
        : localizations.catalogSections(selectedSectionLabels.length, readCount, totalCount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.guideBorder),
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
                  color: tokens.guideIconSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.menu_book_rounded, color: tokens.guideAccent),
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
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onOpenSectionPicker != null)
                    IconButton(
                      tooltip: !hasSectionFilter
                          ? localizations.catalogOpenSectionFilter
                          : localizations.catalogChangeSectionFilter,
                      onPressed: onOpenSectionPicker,
                      icon: Icon(
                        !hasSectionFilter
                            ? Icons.tune_rounded
                            : Icons.filter_alt_rounded,
                        color: tokens.guideAccent,
                      ),
                    ),
                  IconButton(
                    tooltip: isSearchVisible
                        ? localizations.catalogHideSearch
                        : localizations.catalogShowSearch,
                    onPressed: onToggleSearch,
                    icon: Icon(
                      isSearchVisible
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      color: tokens.guideAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasSectionFilter) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSectionLabels
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.guideChipBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.guideSecondaryAccent,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isSearchVisible || hasQuery
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _GuideSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hintText: localizations.catalogGuideSearchHint,
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
          if (isLoadingLessonDocuments && (isSearchVisible || hasQuery)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tokens.guideAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    localizations.catalogLoadingGuideTitles,
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

class _GuideSearchField extends StatelessWidget {
  const _GuideSearchField({
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
          borderSide: BorderSide(color: tokens.guideBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: tokens.guideAccent, width: 1.5),
        ),
      ),
    );
  }
}

class GuideSectionOptionTile extends StatelessWidget {
  const GuideSectionOptionTile({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? tokens.guideSelectedSurface
                : tokens.subtleSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? tokens.guideSelectedBorder : tokens.outlineSoft,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).catalogTopicsCount(count),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? tokens.guideAccent : tokens.disabledAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
