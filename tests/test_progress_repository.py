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
        self.words_file.write_text("[]", encoding="utf-8")
        self.repository = ProgressRepository(
            SimpleNamespace(words_file=str(self.words_file))
        )

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_save_words_replaces_target_file_atomically(self):
        words = [{"hebrew": "שלום", "english": "peace"}]

        with patch(
            "infrastructure.progress_repository.os.replace",
            wraps=os.replace,
        ) as replace_mock:
            self.repository.save_words(words)

        replace_mock.assert_called_once()
        source_path, destination_path = replace_mock.call_args.args
        self.assertNotEqual(source_path, destination_path)
        self.assertEqual(destination_path, str(self.words_file))
        self.assertEqual(
            json.loads(self.words_file.read_text(encoding="utf-8")),
            words,
        )


if __name__ == "__main__":
    unittest.main()
