import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(tokens.sectionRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: tokens.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
