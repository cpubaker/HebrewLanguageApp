import unittest
from pathlib import Path

import test_support

from app_paths import AppPaths


PROJECT_ROOT = Path(__file__).resolve().parents[1]


class AppPathsTests(unittest.TestCase):
    def test_from_src_file_resolves_paths_for_main_module(self):
        src_file = PROJECT_ROOT / "src" / "main.py"

        paths = AppPaths.from_src_file(str(src_file))

        self.assertEqual(paths.project_root, str(PROJECT_ROOT))
        self.assertEqual(
            paths.words_file,
            str(PROJECT_ROOT / "data" / "input" / "hebrew_words.json"),
        )
        self.assertEqual(paths.guide_dir, str(PROJECT_ROOT / "data" / "input" / "guide"))
        self.assertEqual(paths.verbs_dir, str(PROJECT_ROOT / "data" / "input" / "verbs"))
        self.assertEqual(
            paths.reading_dir, str(PROJECT_ROOT / "data" / "input" / "reading")
        )
        self.assertEqual(
            paths.images_dir, str(PROJECT_ROOT / "data" / "input" / "images")
        )
        self.assertEqual(
            paths.verbs_images_dir,
            str(PROJECT_ROOT / "data" / "input" / "images" / "verbs"),
        )
        self.assertEqual(
            paths.words_images_dir,
            str(PROJECT_ROOT / "data" / "input" / "images" / "words"),
        )
        self.assertEqual(
            paths.reading_images_dir,
            str(PROJECT_ROOT / "data" / "input" / "images" / "reading"),
        )
        self.assertEqual(
            paths.icon_file, str(PROJECT_ROOT / "src" / "ui" / "app_icon.png")
        )

    def test_from_src_file_walks_up_from_ui_module(self):
        src_file = PROJECT_ROOT / "src" / "ui" / "main_window.py"

        paths = AppPaths.from_src_file(str(src_file))

        self.assertEqual(paths.project_root, str(PROJECT_ROOT))


if __name__ == "__main__":
    unittest.main()
