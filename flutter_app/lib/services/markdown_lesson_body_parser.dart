enum LessonBodyBlockType { spacer, heading, bullet, paragraph }

class LessonBodyBlock {
  const LessonBodyBlock._({
    required this.type,
    this.text = '',
    this.headingLevel = 0,
  });

  const LessonBodyBlock.spacer() : this._(type: LessonBodyBlockType.spacer);

  const LessonBodyBlock.heading({required int level, required String text})
    : this._(
        type: LessonBodyBlockType.heading,
        text: text,
        headingLevel: level,
      );

  const LessonBodyBlock.bullet(String text)
    : this._(type: LessonBodyBlockType.bullet, text: text);

  const LessonBodyBlock.paragraph(String text)
    : this._(type: LessonBodyBlockType.paragraph, text: text);

  final LessonBodyBlockType type;
  final String text;
  final int headingLevel;
}

List<LessonBodyBlock> parseMarkdownLessonBody(String body) {
  final blocks = <LessonBodyBlock>[];

  for (final rawLine in body.split('\n')) {
    final line = rawLine.trimRight();
    if (line.trim().isEmpty) {
      blocks.add(const LessonBodyBlock.spacer());
      continue;
    }

    final headingMatch = _headingPattern.firstMatch(line.trim());
    if (headingMatch != null) {
      blocks.add(
        LessonBodyBlock.heading(
          level: headingMatch.group(1)!.length,
          text: headingMatch.group(2)!.trim(),
        ),
      );
      continue;
    }

    final leftTrimmedLine = line.trimLeft();
    if (leftTrimmedLine.startsWith('- ')) {
      blocks.add(LessonBodyBlock.bullet(leftTrimmedLine.substring(2).trim()));
      continue;
    }

    blocks.add(LessonBodyBlock.paragraph(line.trim()));
  }

  return blocks;
}

final RegExp _headingPattern = RegExp(r'^(#{1,6})\s+(.*)$');
