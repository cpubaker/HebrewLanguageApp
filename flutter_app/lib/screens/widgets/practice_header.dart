import 'package:flutter/material.dart';

import 'app_page_header.dart';
import 'app_section_card.dart';

class PracticeHeader extends StatelessWidget {
  const PracticeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.child,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(title: title, subtitle: subtitle, trailing: trailing),
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}
