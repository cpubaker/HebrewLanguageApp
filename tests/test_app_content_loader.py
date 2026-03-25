import unittest

import test_support

from application.app_content_loader import AppContentLoader


class FakeContentRepository:
    def load_words(self):
        return ["words"]

    def load_guide_sections(self):
        return ["guide"]

    def load_verbs(self):
        return ["verbs"]

    def load_reading_sections(self):
        return ["reading"]


class AppContentLoaderTests(unittest.TestCase):
    def test_load_returns_full_app_content_bundle(self):
        loader = AppContentLoader(FakeContentRepository())

        content = loader.load()

        self.assertEqual(content.words, ["words"])
        self.assertEqual(content.guide_sections, ["guide"])
        self.assertEqual(content.verbs, ["verbs"])
        self.assertEqual(content.reading_sections, ["reading"])


if __name__ == "__main__":
    unittest.main()
