import 'package:flutter/material.dart';

class MarkdownLessonBody extends StatelessWidget {
  const MarkdownLessonBody({
    super.key,
    required this.body,
    required this.accentColor,
  });

  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final lines = body.split('\n');
    final children = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 12));
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line.trim());
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final title = headingMatch.group(2)!.trim();
        final textDirection = _resolveTextDirection(title);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                title,
                style: _headingStyleForLevel(context, level),
                textAlign: textDirection == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
                textDirection: textDirection,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.trimLeft().startsWith('- ')) {
        final bulletText = line.trimLeft().substring(2).trim();
        final textDirection = _resolveTextDirection(bulletText);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: textDirection,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(Icons.circle, size: 8, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    bulletText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.55),
                    textAlign: textDirection == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    textDirection: textDirection,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      final text = line.trim();
      final textDirection = _resolveTextDirection(text);
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: SelectableText(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
              textAlign: textDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
              textDirection: textDirection,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  TextStyle? _headingStyleForLevel(BuildContext context, int level) {
    if (level <= 2) {
      return Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    }

    return Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
  }

  TextDirection _resolveTextDirection(String text) {
    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      if (RegExp(r'[\u0590-\u05FF]').hasMatch(character)) {
        return TextDirection.rtl;
      }

      if (RegExp(r'[A-Za-z\u0400-\u04FF]').hasMatch(character)) {
        return TextDirection.ltr;
      }
    }

    return TextDirection.ltr;
  }
}
