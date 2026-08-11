import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../app_section_card.dart';

class ReadingEmptySearchState extends StatelessWidget {
  const ReadingEmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return AppSectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 32, color: tokens.readingAccent),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).catalogNothingFound,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).catalogReadingEmpty,
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
