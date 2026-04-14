import 'package:flutter/material.dart';

class AppActionWrap extends StatelessWidget {
  const AppActionWrap({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: children,
    );
  }
}
