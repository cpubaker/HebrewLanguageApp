import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/services/markdown_lesson_body_parser.dart';

void main() {
  test('parses headings, spacers, bullets, and paragraphs', () {
    final blocks = parseMarkdownLessonBody(
      '# Main title\n'
      '\n'
      '  ## Sub title  \n'
      '  - first bullet  \n'
      'Plain paragraph  ',
    );

    expect(blocks.length, 5);
    expect(blocks[0].type, LessonBodyBlockType.heading);
    expect(blocks[0].headingLevel, 1);
    expect(blocks[0].text, 'Main title');
    expect(blocks[1].type, LessonBodyBlockType.spacer);
    expect(blocks[2].type, LessonBodyBlockType.heading);
    expect(blocks[2].headingLevel, 2);
    expect(blocks[2].text, 'Sub title');
    expect(blocks[3].type, LessonBodyBlockType.bullet);
    expect(blocks[3].text, 'first bullet');
    expect(blocks[4].type, LessonBodyBlockType.paragraph);
    expect(blocks[4].text, 'Plain paragraph');
  });

  test('treats headings without a space as plain paragraphs', () {
    final blocks = parseMarkdownLessonBody('#Not a heading');

    expect(blocks.single.type, LessonBodyBlockType.paragraph);
    expect(blocks.single.text, '#Not a heading');
  });
}
