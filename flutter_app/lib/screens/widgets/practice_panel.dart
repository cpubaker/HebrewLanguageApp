import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PracticePanel extends StatelessWidget {
  const PracticePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).appTokens;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.subtleSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
