import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import test_support

from domain.errors import MissingDataPathError
from domain.models import ContextSentence, GuideSection, ReadingSection, VerbLesson, Word
from infrastructure.content_repository import ContentRepository
from infrastructure.progress_repository import ProgressRepository


class RepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.paths = SimpleNamespace(
            words_file=str(self.root / "hebrew_words.json"),
            guide_dir=str(self.root / "guide"),
            verbs_dir=str(self.root / "verbs"),
            reading_dir=str(self.root / "reading"),
            context_sentences_file=str(self.root / "contexts" / "sentences.json"),
            word_context_links_file=str(
                self.root / "contexts" / "word_context_links.json"
            ),
            verbs_audio_dir=str(self.root / "audio" / "verbs"),
            verbs_images_dir=str(self.root / "images" / "verbs"),
        )
        self.content_repository = ContentRepository(self.paths)
        self.progress_repository = ProgressRepository(self.paths)

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

        loaded_words = self.content_repository.load_words()

        self.assertIsInstance(loaded_words[0], Word)
        self.assertEqual(loaded_words[0]["correct"], 2)
        self.assertEqual(loaded_words[0]["wrong"], 0)
        self.assertEqual(loaded_words[0]["writing_correct"], 0)
        self.assertEqual(loaded_words[0]["writing_wrong"], 0)
        self.assertFalse(loaded_words[0]["last_correct"])
        self.assertEqual(
            loaded_words[0]["writing_last_correct"], "2026-03-17T10:00:00"
        )
        self.assertEqual(loaded_words[0]["_word_id"], "word_peace")
        self.assertEqual(loaded_words[0]["_contexts"], [])
        self.assertEqual(loaded_words[1]["correct"], 0)
        self.assertEqual(loaded_words[1]["wrong"], 0)
        self.assertEqual(loaded_words[1]["writing_correct"], 0)
        self.assertEqual(loaded_words[1]["writing_wrong"], 0)
        self.assertFalse(loaded_words[1]["last_correct"])
        self.assertFalse(loaded_words[1]["writing_last_correct"])
        self.assertEqual(loaded_words[1]["_word_id"], "word_house")
        self.assertEqual(loaded_words[1]["_contexts"], [])

    def test_load_words_resolves_shared_contexts_without_duplication(self):
        words = [
            {
                "hebrew": "כלב",
                "english": "dog",
                "transcription": "kelev",
            },
            {
                "hebrew": "פארק",
                "english": "park",
                "transcription": "park",
            },
        ]
        contexts_dir = self.root / "contexts"
        contexts_dir.mkdir()

        Path(self.paths.words_file).write_text(
            json.dumps(words, ensure_ascii=False),
            encoding="utf-8",
        )
        Path(self.paths.context_sentences_file).write_text(
            json.dumps(
                [
                    {
                        "id": "ctx_dog_park_01",
                        "hebrew": "הכלב רץ בפארק.",
                        "translation": "The dog is running in the park.",
                    }
                ],
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        Path(self.paths.word_context_links_file).write_text(
            json.dumps(
                {
                    "word_dog": ["ctx_dog_park_01"],
                    "word_park": ["ctx_dog_park_01"],
                },
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )

        loaded_words = self.content_repository.load_words()

        self.assertIsInstance(loaded_words[0]["_contexts"][0], ContextSentence)
        self.assertEqual(loaded_words[0]["_contexts"][0]["id"], "ctx_dog_park_01")
        self.assertEqual(loaded_words[1]["_contexts"][0]["id"], "ctx_dog_park_01")

    def test_save_words_omits_transient_context_fields(self):
        words = [
            {
                "hebrew": "כלב",
                "english": "dog",
                "transcription": "kelev",
                "_word_id": "word_dog",
                "_contexts": [{"id": "ctx_dog_park_01"}],
            }
        ]

        self.progress_repository.save_words(words)

        saved_words = json.loads(Path(self.paths.words_file).read_text(encoding="utf-8"))
        self.assertNotIn("_word_id", saved_words[0])
        self.assertNotIn("_contexts", saved_words[0])

    def test_load_text_sections_uses_title_and_skips_empty_or_non_lesson_files(self):
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

        sections = self.content_repository.load_text_sections(
            self.paths.guide_dir,
            resource_label="guide folder",
        )

        self.assertEqual(len(sections), 2)
        self.assertIsInstance(sections[0], GuideSection)
        self.assertEqual(sections[0]["title"], "Alphabet")
        self.assertEqual(sections[0]["body"], "Lesson body")
        self.assertEqual(sections[0]["filename"], "01_heading.md")
        self.assertEqual(sections[1]["title"], "Greetings")
        self.assertEqual(sections[1]["body"], "Useful phrases")
        self.assertEqual(sections[1]["filename"], "02_plain.txt")

    def test_is_text_section_file_accepts_numbered_lessons_only(self):
        self.assertTrue(self.content_repository._is_text_section_file("01_intro.md"))
        self.assertTrue(self.content_repository._is_text_section_file("02_intro.txt"))
        self.assertFalse(self.content_repository._is_text_section_file("AGENTS.md"))
        self.assertFalse(self.content_repository._is_text_section_file("notes.md"))
        self.assertFalse(self.content_repository._is_text_section_file("01_intro.json"))

    def test_load_text_sections_missing_directory_raises_missing_data_error(self):
        missing_dir = self.root / "missing"

        with self.assertRaises(MissingDataPathError) as error_context:
            self.content_repository.load_text_sections(
                str(missing_dir),
                resource_label="guide folder",
            )

        self.assertEqual(error_context.exception.path, str(missing_dir))
        self.assertEqual(error_context.exception.resource_label, "guide folder")

    @patch("infrastructure.content_repository.READING_LEVELS", ["beginner", "advanced"])
    def test_load_reading_sections_collects_sections_with_metadata(self):
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

        sections = self.content_repository.load_reading_sections()

        self.assertEqual(len(sections), 2)
        self.assertIsInstance(sections[0], ReadingSection)
        self.assertEqual(sections[0]["title"], "Intro")
        self.assertEqual(sections[0]["body"], "Easy text")
        self.assertEqual(sections[0]["level"], "beginner")
        self.assertEqual(sections[0]["filename"], "01_intro.md")
        self.assertEqual(sections[1]["title"], "Daily Life")
        self.assertEqual(sections[1]["body"], "Short passage")
        self.assertEqual(sections[1]["level"], "beginner")
        self.assertEqual(sections[1]["filename"], "02_plain.txt")

    def test_load_verbs_collects_image_and_audio_paths_from_matching_assets(self):
        verbs_dir = Path(self.paths.verbs_dir)
        verbs_images_dir = Path(self.paths.verbs_images_dir)
        verbs_audio_dir = Path(self.paths.verbs_audio_dir)
        verbs_dir.mkdir()
        verbs_images_dir.mkdir(parents=True)
        verbs_audio_dir.mkdir(parents=True)

        (verbs_dir / "01_walk.md").write_text(
            "# Walk\n\nVerb notes",
            encoding="utf-8",
        )
        (verbs_dir / "02_give.md").write_text(
            "# Give\n\nUsage examples",
            encoding="utf-8",
        )
        (verbs_images_dir / "walk.png").write_bytes(b"png")
        (verbs_audio_dir / "walk.mp3").write_bytes(b"mp3")

        sections = self.content_repository.load_verbs()

        self.assertEqual(len(sections), 2)
        self.assertIsInstance(sections[0], VerbLesson)
        self.assertEqual(sections[0]["title"], "Walk")
        self.assertEqual(sections[0]["body"], "Verb notes")
        self.assertEqual(sections[0]["filename"], "01_walk.md")
        self.assertEqual(sections[0]["image_path"], str(verbs_images_dir / "walk.png"))
        self.assertEqual(sections[0]["audio_path"], str(verbs_audio_dir / "walk.mp3"))
        self.assertEqual(sections[1]["title"], "Give")
        self.assertEqual(sections[1]["body"], "Usage examples")
        self.assertEqual(sections[1]["filename"], "02_give.md")
        self.assertIsNone(sections[1]["image_path"])
        self.assertIsNone(sections[1]["audio_path"])


if __name__ == "__main__":
    unittest.main()
