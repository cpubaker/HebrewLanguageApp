import json
import re
import unittest
from pathlib import Path

from scripts.generate_content_index import build_content_index


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_ROOT = PROJECT_ROOT / "flutter_app" / "assets" / "learning" / "input"
CONTENT_INDEX_PATH = PROJECT_ROOT / "docs" / "content_index.json"
READING_LEVELS = {
    "beginner",
    "pre-intermediate",
    "intermediate",
    "upper-intermediate",
    "advanced",
    "proficient",
}
RUNTIME_PROGRESS_FIELDS = {
    "correct",
    "wrong",
    "last_correct",
    "last_reviewed_at",
    "last_review_correct",
    "writing_correct",
    "writing_wrong",
    "writing_last_correct",
}


class ContentIntegrityTests(unittest.TestCase):
    def test_words_json_contains_required_fields(self):
        words = _load_json(INPUT_ROOT / "hebrew_words.json")

        self.assertIsInstance(words, list)
        self.assertGreater(len(words), 0)

        seen_word_ids = set()
        for index, word in enumerate(words):
            self.assertIn("word_id", word, f"Missing word_id in item {index}")
            self.assertIn("hebrew", word, f"Missing hebrew in item {index}")
            self.assertIn("english", word, f"Missing english in item {index}")
            self.assertIn("ukrainian", word, f"Missing ukrainian in item {index}")
            self.assertIn("transcription", word, f"Missing transcription in item {index}")
            word_id = str(word["word_id"]).strip()
            self.assertTrue(word_id, f"Empty word_id in item {index}")
            self.assertNotIn(word_id, seen_word_ids, f"Duplicate word_id {word_id}")
            seen_word_ids.add(word_id)
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

    def test_words_json_does_not_embed_runtime_progress(self):
        words = _load_json(INPUT_ROOT / "hebrew_words.json")

        for index, word in enumerate(words):
            word_id = str(word.get("word_id", f"item {index}")).strip()
            leaked_fields = sorted(RUNTIME_PROGRESS_FIELDS.intersection(word))
            self.assertEqual(
                leaked_fields,
                [],
                f"Runtime progress fields in source word {word_id}: {leaked_fields}",
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

    def test_context_links_reference_existing_words_and_sentences(self):
        words = _load_json(INPUT_ROOT / "hebrew_words.json")
        sentences = _load_json(INPUT_ROOT / "contexts" / "sentences.json")
        word_context_links = _load_json(
            INPUT_ROOT / "contexts" / "word_context_links.json"
        )

        word_ids = {str(word.get("word_id", "")).strip() for word in words}
        sentence_ids = {
            str(sentence.get("id", "")).strip()
            for sentence in sentences
            if str(sentence.get("id", "")).strip()
        }

        self.assertGreater(len(sentence_ids), 0)
        self.assertIsInstance(word_context_links, dict)

        for word_id, context_ids in word_context_links.items():
            self.assertIn(word_id, word_ids, f"Unknown word_id in context links: {word_id}")
            self.assertIsInstance(context_ids, list, f"Context links for {word_id} must be a list")
            for context_id in context_ids:
                self.assertIn(
                    context_id,
                    sentence_ids,
                    f"Unknown context id {context_id} linked from {word_id}",
                )

    def test_content_index_is_current(self):
        content_index = _load_json(CONTENT_INDEX_PATH)

        self.assertEqual(content_index, build_content_index(INPUT_ROOT))


def _load_json(path):
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


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
