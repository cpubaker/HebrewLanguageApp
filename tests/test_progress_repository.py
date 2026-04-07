import json
import os
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import test_support

from infrastructure.progress_repository import ProgressRepository


class ProgressRepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.words_file = self.root / "hebrew_words.json"
        self.word_progress_file = self.root / "word_progress.json"
        self.words_file.write_text("[]", encoding="utf-8")
        self.repository = ProgressRepository(
            SimpleNamespace(
                words_file=str(self.words_file),
                word_progress_file=str(self.word_progress_file),
            )
        )

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_save_words_replaces_progress_file_atomically(self):
        words = [
            {
                "word_id": "word_peace",
                "hebrew": "Ч©ЧњЧ•Чќ",
                "english": "peace",
                "correct": 2,
                "last_correct": "2026-03-17T10:00:00",
            }
        ]

        with patch(
            "infrastructure.progress_repository.os.replace",
            wraps=os.replace,
        ) as replace_mock:
            self.repository.save_words(words)

        replace_mock.assert_called_once()
        source_path, destination_path = replace_mock.call_args.args
        self.assertNotEqual(source_path, destination_path)
        self.assertEqual(destination_path, str(self.word_progress_file))
        self.assertEqual(
            json.loads(self.word_progress_file.read_text(encoding="utf-8")),
            {
                "word_peace": {
                    "correct": 2,
                    "last_correct": "2026-03-17T10:00:00",
                }
            },
        )


if __name__ == "__main__":
    unittest.main()
