import unittest

import test_support

from ui.markdown_utils import (
    parse_inline_markdown,
    parse_markdown_block,
    render_markdown_content,
)


class _FakeTextWidget:
    def __init__(self):
        self.inserts = []

    def insert(self, _index, text, tags=()):
        self.inserts.append((text, tags))


class MarkdownUtilsTests(unittest.TestCase):
    def test_render_markdown_content_dispatches_blocks_in_order(self):
        text_widget = _FakeTextWidget()
        calls = []

        render_markdown_content(
            text_widget,
            "# Title\n\n- Item\n2. Next\nParagraph",
            render_heading=lambda block: calls.append(("heading", block.kind, block.text)),
            render_unordered_list_item=lambda block: calls.append(("unordered", block.text)),
            render_ordered_list_item=lambda block: calls.append(
                ("ordered", block.ordinal, block.text)
            ),
            render_paragraph=lambda block: calls.append(("paragraph", block.text)),
        )

        self.assertEqual(
            calls,
            [
                ("heading", "heading_1", "Title"),
                ("unordered", "Item"),
                ("ordered", "2", "Next"),
                ("paragraph", "Paragraph"),
            ],
        )
        self.assertEqual(
            [text for text, _tags in text_widget.inserts],
            ["\n", "\n", "\n", "\n", "\n"],
        )

    def test_parse_markdown_block_detects_heading(self):
        block = parse_markdown_block("## Section")

        self.assertEqual(block.kind, "heading_2")
        self.assertEqual(block.text, "Section")

    def test_parse_markdown_block_detects_ordered_list_item(self):
        block = parse_markdown_block("3. Third item")

        self.assertEqual(block.kind, "ordered_list_item")
        self.assertEqual(block.ordinal, "3")
        self.assertEqual(block.text, "Third item")

    def test_parse_inline_markdown_preserves_plain_text(self):
        segments = parse_inline_markdown("Simple text.")

        self.assertEqual(
            [(segment.text, segment.tags) for segment in segments],
            [
                ("Simple text.", ()),
            ],
        )

    def test_parse_inline_markdown_splits_bold_and_italic_segments(self):
        segments = parse_inline_markdown("Start **bold** and *italic* end")

        self.assertEqual(
            [(segment.text, segment.tags) for segment in segments],
            [
                ("Start ", ()),
                ("bold", ("bold",)),
                (" and ", ()),
                ("italic", ("italic",)),
                (" end", ()),
            ],
        )


if __name__ == "__main__":
    unittest.main()
