import unittest

import test_support

from ui.text_browser_window import TextBrowserWindow


class TextBrowserWindowAdapterTests(unittest.TestCase):
    def test_get_section_helpers_support_mapping_list(self):
        window = TextBrowserWindow.__new__(TextBrowserWindow)
        section = {"title": "Intro", "body": "Body text"}

        self.assertEqual(window._get_section_list_label(section), "Intro")
        self.assertEqual(window._get_section_title(section), "Intro")
        self.assertEqual(window._get_section_body(section), "Body text")


if __name__ == "__main__":
    unittest.main()
