import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import test_support

from data_service import HebrewDataService


class DummyMaster:
    def __init__(self):
        self.destroy_called = False

    def destroy(self):
        self.destroy_called = True


class HebrewDataServiceTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.master = DummyMaster()
        self.paths = SimpleNamespace(
            words_file=str(self.root / "hebrew_words.json"),
            guide_dir=str(self.root / "guide"),
            verbs_dir=str(self.root / "verbs"),
            reading_dir=str(self.root / "reading"),
            verbs_images_dir=str(self.root / "images" / "verbs"),
        )
        self.service = HebrewDataService(self.master, self.paths)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_load_words_applies_defaults_and_normalizes_boolean_timestamps(self):
        words = [
            {
                "hebrew": "שלום",
                "english": "peace",
                "transcription": "shalom",
                "correct": 2,
                "last_correct": True,
                "writing_last_correct": "2026-03-17T10:00:00",
            },
            {
                "hebrew": "בית",
                "english": "house",
                "transcription": "bayit",
            },
        ]
        Path(self.paths.words_file).write_text(
            json.dumps(words, ensure_ascii=False),
            encoding="utf-8",
        )

        loaded_words = self.service.load_words()

        self.assertEqual(loaded_words[0]["correct"], 2)
        self.assertEqual(loaded_words[0]["wrong"], 0)
        self.assertEqual(loaded_words[0]["writing_correct"], 0)
        self.assertEqual(loaded_words[0]["writing_wrong"], 0)
        self.assertFalse(loaded_words[0]["last_correct"])
        self.assertEqual(
            loaded_words[0]["writing_last_correct"], "2026-03-17T10:00:00"
        )
        self.assertEqual(loaded_words[1]["correct"], 0)
        self.assertEqual(loaded_words[1]["wrong"], 0)
        self.assertEqual(loaded_words[1]["writing_correct"], 0)
        self.assertEqual(loaded_words[1]["writing_wrong"], 0)
        self.assertFalse(loaded_words[1]["last_correct"])
        self.assertFalse(loaded_words[1]["writing_last_correct"])

    @patch("data_service.messagebox")
    def test_load_text_sections_uses_title_and_skips_empty_or_non_lesson_files(
        self, messagebox_mock
    ):
        guide_dir = Path(self.paths.guide_dir)
        guide_dir.mkdir()
        (guide_dir / "01_heading.md").write_text(
            "# Alphabet\n\nLesson body",
            encoding="utf-8",
        )
        (guide_dir / "02_plain.txt").write_text(
            "Greetings\n\nUseful phrases",
            encoding="utf-8",
        )
        (guide_dir / "03_empty.md").write_text("   \n", encoding="utf-8")
        (guide_dir / "AGENTS.md").write_text(
            "# Local instructions\n\nDo not load this as a lesson.",
            encoding="utf-8",
        )
        (guide_dir / "notes.md").write_text(
            "# Scratchpad\n\nThis should stay out of the app.",
            encoding="utf-8",
        )
        (guide_dir / "notes.json").write_text("{}", encoding="utf-8")

        sections = self.service.load_text_sections(
            self.paths.guide_dir,
            missing_title="Missing",
            missing_message="Missing guide",
            empty_title="Empty",
            empty_message="Empty guide",
        )

        self.assertEqual(
            sections,
            {
                "Alphabet": "Lesson body",
                "Greetings": "Useful phrases",
            },
        )
        messagebox_mock.showwarning.assert_not_called()

    def test_is_text_section_file_accepts_numbered_lessons_only(self):
        self.assertTrue(self.service._is_text_section_file("01_intro.md"))
        self.assertTrue(self.service._is_text_section_file("02_intro.txt"))
        self.assertFalse(self.service._is_text_section_file("AGENTS.md"))
        self.assertFalse(self.service._is_text_section_file("notes.md"))
        self.assertFalse(self.service._is_text_section_file("01_intro.json"))

    @patch("data_service.messagebox")
    def test_load_text_sections_missing_directory_raises_and_destroys_master(
        self, messagebox_mock
    ):
        missing_dir = self.root / "missing"

        with self.assertRaises(FileNotFoundError):
            self.service.load_text_sections(
                str(missing_dir),
                missing_title="Missing folder",
                missing_message="Folder missing",
                empty_title="Empty",
                empty_message="No files",
            )

        self.assertTrue(self.master.destroy_called)
        messagebox_mock.showerror.assert_called_once_with(
            "Missing folder", "Folder missing"
        )

    @patch("data_service.messagebox")
    @patch("data_service.READING_LEVELS", ["beginner", "advanced"])
    def test_load_reading_sections_collects_sections_with_metadata(
        self, messagebox_mock
    ):
        reading_dir = Path(self.paths.reading_dir)
        beginner_dir = reading_dir / "beginner"
        advanced_dir = reading_dir / "advanced"
        beginner_dir.mkdir(parents=True)
        advanced_dir.mkdir(parents=True)

        (beginner_dir / "01_intro.md").write_text(
            "# Intro\n\nEasy text",
            encoding="utf-8",
        )
        (beginner_dir / "02_plain.txt").write_text(
            "Daily Life\n\nShort passage",
            encoding="utf-8",
        )
        (advanced_dir / "ignore.md").write_text("   ", encoding="utf-8")
        (advanced_dir / "notes.json").write_text("{}", encoding="utf-8")

        sections = self.service.load_reading_sections()

        self.assertEqual(
            sections,
            [
                {
                    "title": "Intro",
                    "body": "Easy text",
                    "level": "beginner",
                    "filename": "01_intro.md",
                },
                {
                    "title": "Daily Life",
                    "body": "Short passage",
                    "level": "beginner",
                    "filename": "02_plain.txt",
                },
            ],
        )
        messagebox_mock.showwarning.assert_not_called()

    @patch("data_service.messagebox")
    def test_load_verbs_collects_image_paths_from_matching_png_files(
        self, messagebox_mock
    ):
        verbs_dir = Path(self.paths.verbs_dir)
        verbs_images_dir = Path(self.paths.verbs_images_dir)
        verbs_dir.mkdir()
        verbs_images_dir.mkdir(parents=True)

        (verbs_dir / "01_walk.md").write_text(
            "# Walk\n\nVerb notes",
            encoding="utf-8",
        )
        (verbs_dir / "02_give.md").write_text(
            "# Give\n\nUsage examples",
            encoding="utf-8",
        )
        (verbs_images_dir / "walk.png").write_bytes(b"png")

        sections = self.service.load_verbs()

        self.assertEqual(
            sections,
            [
                {
                    "title": "Walk",
                    "body": "Verb notes",
                    "filename": "01_walk.md",
                    "image_path": str(verbs_images_dir / "walk.png"),
                },
                {
                    "title": "Give",
                    "body": "Usage examples",
                    "filename": "02_give.md",
                    "image_path": None,
                },
            ],
        )
        messagebox_mock.showwarning.assert_not_called()


if __name__ == "__main__":
    unittest.main()
