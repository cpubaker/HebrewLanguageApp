import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/lesson_glossary_matcher.dart';
import '../../services/lesson_text_direction.dart';
import '../../services/markdown_lesson_body_parser.dart';
import '../../theme/app_theme.dart';

class MarkdownLessonBody extends StatefulWidget {
  const MarkdownLessonBody({
    super.key,
    required this.body,
    required this.accentColor,
    this.inlineGlossary = const <String, String>{},
  });

  final String body;
  final Color accentColor;
  final Map<String, String> inlineGlossary;

  @override
  State<MarkdownLessonBody> createState() => _MarkdownLessonBodyState();
}

class _MarkdownLessonBodyState extends State<MarkdownLessonBody> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final tokens = Theme.of(context).appTokens;

    final children = <Widget>[];

    for (final block in parseMarkdownLessonBody(widget.body)) {
      children.add(_buildBlock(context, block));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBlock(BuildContext context, LessonBodyBlock block) {
    switch (block.type) {
      case LessonBodyBlockType.spacer:
        return const SizedBox(height: 12);
      case LessonBodyBlockType.heading:
        return _buildHeading(context, block.text, block.headingLevel);
      case LessonBodyBlockType.bullet:
        return _buildBullet(context, block.text);
      case LessonBodyBlockType.paragraph:
        return _buildParagraphBlock(context, block.text);
    }
  }

  Widget _buildHeading(BuildContext context, String title, int level) {
    final textDirection = resolveLessonTextDirection(title);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: _headingStyleForLevel(context, level),
          textAlign: _textAlignForDirection(textDirection),
          textDirection: textDirection,
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String bulletText) {
    final displayText = prepareBidirectionalLessonText(bulletText);
    final textDirection = preferredLessonTextDirectionForDisplay(bulletText);
    final bulletRowDirection =
        textDirection == TextDirection.rtl &&
            !hasMixedLessonScriptContent(bulletText)
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Directionality(
        textDirection: bulletRowDirection,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(Icons.circle, size: 8, color: widget.accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SelectableText(
                displayText,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.55),
                textAlign: _textAlignForDirection(textDirection),
                textDirection: textDirection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphBlock(BuildContext context, String text) {
    final textDirection = preferredLessonTextDirectionForDisplay(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: _buildParagraph(
          context,
          prepareBidirectionalLessonText(text),
          textDirection,
        ),
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

  Widget _buildParagraph(
    BuildContext context,
    String text,
    TextDirection textDirection,
  ) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6);
    if (widget.inlineGlossary.isEmpty || !containsHebrewText(text)) {
      return SelectableText(
        text,
        style: style,
        textAlign: _textAlignForDirection(textDirection),
        textDirection: textDirection,
      );
    }

    final interactiveSpans = _buildInteractiveSpans(context, text, style);
    if (interactiveSpans == null) {
      return SelectableText(
        text,
        style: style,
        textAlign: _textAlignForDirection(textDirection),
        textDirection: textDirection,
      );
    }

    return RichText(
      textAlign: _textAlignForDirection(textDirection),
      textDirection: textDirection,
      text: TextSpan(style: style, children: interactiveSpans),
    );
  }

  List<InlineSpan>? _buildInteractiveSpans(
    BuildContext context,
    String text,
    TextStyle? baseStyle,
  ) {
    final segments = matchLessonGlossaryText(text, widget.inlineGlossary);
    if (segments == null) {
      return null;
    }

    final tappableStyle = baseStyle?.copyWith(
      color: widget.accentColor,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(
        context,
      ).appTokens.accentDecoration(widget.accentColor),
    );

    final spans = <InlineSpan>[];
    for (final segment in segments) {
      final match = segment.match;
      if (match == null) {
        spans.add(TextSpan(text: segment.text, style: baseStyle));
        continue;
      }

      spans.add(
        TextSpan(
          text: segment.text,
          style: tappableStyle,
          recognizer: _createTapRecognizer(() {
            _showGlossarySheet(
              context,
              source: match.source,
              translation: match.translation,
            );
          }),
        ),
      );
    }

    return spans;
  }

  TapGestureRecognizer _createTapRecognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(recognizer);
    return recognizer;
  }

  Future<void> _showGlossarySheet(
    BuildContext context, {
    required String source,
    required String translation,
  }) {
    final sourceDirection = resolveLessonTextDirection(source);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                  textDirection: sourceDirection,
                  textAlign: _textAlignForDirection(sourceDirection),
                ),
                const SizedBox(height: 10),
                Text(
                  translation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextAlign _textAlignForDirection(TextDirection textDirection) {
    return textDirection == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}
