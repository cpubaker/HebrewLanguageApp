import json
import unittest
from pathlib import Path

import test_support

from app_paths import AppPaths
from data_service import HebrewDataService
from reading_levels import READING_LEVELS


PROJECT_ROOT = Path(__file__).resolve().parents[1]


class DummyMaster:
    def destroy(self):
        raise AssertionError("Real content integrity checks should not destroy the UI")


class ContentIntegrityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.paths = AppPaths.from_src_file(str(PROJECT_ROOT / "src" / "main.py"))
        cls.service = HebrewDataService(DummyMaster(), cls.paths)

    def test_words_json_contains_required_fields(self):
        words_path = Path(self.paths.words_file)

        with words_path.open("r", encoding="utf-8") as file:
            words = json.load(file)

        self.assertIsInstance(words, list)
        self.assertGreater(len(words), 0)

        for index, word in enumerate(words):
            self.assertIn("hebrew", word, f"Missing hebrew in item {index}")
            self.assertIn("english", word, f"Missing english in item {index}")
            self.assertIn("transcription", word, f"Missing transcription in item {index}")
            self.assertTrue(str(word["hebrew"]).strip(), f"Empty hebrew in item {index}")
            self.assertTrue(
                str(word["english"]).strip(), f"Empty english in item {index}"
            )
            self.assertTrue(
                str(word["transcription"]).strip(),
                f"Empty transcription in item {index}",
            )

    def test_guide_and_verb_lessons_have_extractable_titles(self):
        for relative_dir in ("guide", "verbs"):
            lesson_dir = PROJECT_ROOT / "data" / "input" / relative_dir
            lesson_files = sorted(lesson_dir.glob("*"))
            self.assertGreater(len(lesson_files), 0, f"No files found in {lesson_dir}")

            for lesson_file in lesson_files:
                if lesson_file.suffix.lower() not in {".md", ".txt"}:
                    continue

                content = lesson_file.read_text(encoding="utf-8").strip()
                if not content:
                    continue

                title, _ = self.service._split_markdown_section(content)
                self.assertTrue(title, f"Could not extract title from {lesson_file.name}")

    def test_reading_sections_load_with_known_levels(self):
        sections = self.service.load_reading_sections()

        self.assertGreater(len(sections), 0)

        for section in sections:
            self.assertIn(section["level"], READING_LEVELS)
            self.assertTrue(section["title"].strip())
            self.assertTrue(section["filename"].endswith((".md", ".txt")))


if __name__ == "__main__":
    unittest.main()
