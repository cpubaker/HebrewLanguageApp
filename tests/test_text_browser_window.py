import unittest

import test_support

from domain.models import GuideSection
from ui.text_browser_window import TextBrowserWindow


class TextBrowserWindowAdapterTests(unittest.TestCase):
    def test_get_section_helpers_support_section_models(self):
        window = TextBrowserWindow.__new__(TextBrowserWindow)
        section = GuideSection.from_values(
            title="Intro",
            body="Body text",
            filename="01_intro.md",
        )

        self.assertEqual(window._get_section_list_label(section), "Intro")
        self.assertEqual(window._get_section_title(section), "Intro")
        self.assertEqual(window._get_section_body(section), "Body text")


if __name__ == "__main__":
    unittest.main()
