import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

import test_support

from app_runtime import build_app_runtime


class AppRuntimeTests(unittest.TestCase):
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
            icon_file=str(self.root / "icon.png"),
        )

        Path(self.paths.words_file).write_text(
            json.dumps(
                [
                    {
                        "hebrew": "שלום",
                        "english": "peace",
                        "transcription": "shalom",
                    }
                ],
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
        Path(self.paths.guide_dir).mkdir()
        Path(self.paths.verbs_dir).mkdir()
        (Path(self.paths.reading_dir) / "beginner").mkdir(parents=True)
        (Path(self.paths.guide_dir) / "01_intro.md").write_text(
            "# Intro\n\nGuide body",
            encoding="utf-8",
        )
        (Path(self.paths.verbs_dir) / "01_walk.md").write_text(
            "# Walk\n\nVerb body",
            encoding="utf-8",
        )
        (Path(self.paths.reading_dir) / "beginner" / "01_read.md").write_text(
            "# Read\n\nReading body",
            encoding="utf-8",
        )

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_build_app_runtime_wires_paths_content_and_progress(self):
        runtime = build_app_runtime(self.paths)

        self.assertIs(runtime.paths, self.paths)
        self.assertEqual(len(runtime.app_content.words), 1)
        self.assertEqual(len(runtime.app_content.guide_sections), 1)
        self.assertEqual(len(runtime.app_content.verbs), 1)
        self.assertEqual(len(runtime.app_content.reading_sections), 1)
        self.assertIs(runtime.progress_service.repository, runtime.data_service.progress)


if __name__ == "__main__":
    unittest.main()
