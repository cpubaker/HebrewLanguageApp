import json
import re
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_ROOT = PROJECT_ROOT / "data" / "input"
READING_LEVELS = {
    "beginner",
    "pre-intermediate",
    "intermediate",
    "upper-intermediate",
    "advanced",
    "proficient",
}


class ContentIntegrityTests(unittest.TestCase):
    def test_words_json_contains_required_fields(self):
        words_path = INPUT_ROOT / "hebrew_words.json"

        with words_path.open("r", encoding="utf-8") as file:
            words = json.load(file)

        self.assertIsInstance(words, list)
        self.assertGreater(len(words), 0)

        for index, word in enumerate(words):
            self.assertIn("hebrew", word, f"Missing hebrew in item {index}")
            self.assertIn("english", word, f"Missing english in item {index}")
            self.assertIn("ukrainian", word, f"Missing ukrainian in item {index}")
            self.assertIn("transcription", word, f"Missing transcription in item {index}")
            self.assertTrue(str(word["hebrew"]).strip(), f"Empty hebrew in item {index}")
            self.assertTrue(
                str(word["english"]).strip(), f"Empty english in item {index}"
            )
            self.assertTrue(
                str(word["ukrainian"]).strip(), f"Empty ukrainian in item {index}"
            )
            self.assertTrue(
                str(word["transcription"]).strip(),
                f"Empty transcription in item {index}",
            )

    def test_guide_and_verb_lessons_have_extractable_titles(self):
        for relative_dir in ("guide", "verbs"):
            lesson_dir = INPUT_ROOT / relative_dir
            lesson_files = sorted(lesson_dir.glob("*"))
            self.assertGreater(len(lesson_files), 0, f"No files found in {lesson_dir}")

            for lesson_file in lesson_files:
                if not _is_text_section_file(lesson_file):
                    continue

                content = lesson_file.read_text(encoding="utf-8").strip()
                if not content:
                    continue

                title = _extract_markdown_title(content)
                self.assertTrue(title, f"Could not extract title from {lesson_file.name}")

    def test_reading_sections_load_with_known_levels(self):
        reading_dir = INPUT_ROOT / "reading"
        sections = []

        for level_dir in sorted(path for path in reading_dir.iterdir() if path.is_dir()):
            self.assertIn(level_dir.name, READING_LEVELS)

            for lesson_file in sorted(level_dir.iterdir()):
                if not _is_text_section_file(lesson_file):
                    continue

                content = lesson_file.read_text(encoding="utf-8").strip()
                if not content:
                    continue

                sections.append(
                    {
                        "level": level_dir.name,
                        "title": _extract_markdown_title(content),
                        "filename": lesson_file.name,
                    }
                )

        self.assertGreater(len(sections), 0)

        for section in sections:
            self.assertTrue(section["title"].strip())
            self.assertTrue(section["filename"].endswith((".md", ".txt")))


def _is_text_section_file(path):
    if path.suffix not in {".md", ".txt"}:
        return False

    return re.match(r"^\d+", path.stem) is not None


def _extract_markdown_title(content):
    for line in content.lstrip("\ufeff").splitlines():
        stripped_line = line.strip().lstrip("\ufeff")
        if not stripped_line:
            continue

        heading_match = re.match(r"^#{1,6}\s+(.*)$", stripped_line)
        if heading_match:
            return heading_match.group(1).strip()

        return stripped_line

    return ""


if __name__ == "__main__":
    unittest.main()
