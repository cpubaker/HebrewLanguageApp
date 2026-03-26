import unittest

import test_support

from ui.reading_window import ReadingWindow


class _FakeTextWidget:
    def __init__(self):
        self.inserts = []

    def insert(self, _index, text, tags=()):
        self.inserts.append((text, tags))


class ReadingWindowFormattingTests(unittest.TestCase):
    def test_format_bidi_text_wraps_hebrew_preview(self):
        window = ReadingWindow.__new__(ReadingWindow)

        formatted = window._format_bidi_text("יוֹסִי קָם בַּבֹּקֶר.")

        self.assertEqual(formatted, "\u202Bיוֹסִי קָם בַּבֹּקֶר.\u202C")

    def test_format_bidi_text_leaves_non_hebrew_text_unchanged(self):
        window = ReadingWindow.__new__(ReadingWindow)

        self.assertEqual(window._format_bidi_text("Simple preview text."), "Simple preview text.")

    def test_format_glossary_item_wraps_only_hebrew_term(self):
        window = ReadingWindow.__new__(ReadingWindow)

        formatted = window._format_glossary_item("בַּבֹּקֶר - вранці")

        self.assertEqual(formatted, "\u202Bבַּבֹּקֶר\u202C - вранці")

    def test_render_markdown_glossary_item_omits_extra_list_dash(self):
        window = ReadingWindow.__new__(ReadingWindow)
        window.text_widget = _FakeTextWidget()

        window._render_markdown("- בַּבֹּקֶר - вранці")

        self.assertEqual(
            window.text_widget.inserts,
            [
                ("\u202Bבַּבֹּקֶר\u202C - вранці", ("definition_item",)),
                ("\n", ()),
            ],
        )

    def test_insert_inline_markdown_wraps_rtl_runs_for_hebrew_paragraphs(self):
        window = ReadingWindow.__new__(ReadingWindow)
        window.text_widget = _FakeTextWidget()

        window._insert_inline_markdown("יוֹסִי קָם בַּבֹּקֶר.", "paragraph_rtl")

        inserted_text = [text for text, _tags in window.text_widget.inserts]
        self.assertEqual(inserted_text[0], "\u202B")
        self.assertEqual(inserted_text[-1], "\u202C")
        self.assertIn("יוֹסִי קָם בַּבֹּקֶר.", inserted_text)


if __name__ == "__main__":
    unittest.main()
