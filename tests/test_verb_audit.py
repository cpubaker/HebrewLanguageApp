import tempfile
import unittest
from pathlib import Path

from scripts.verb_audit import (
    audit_templates,
    audit_transliterations,
    classify_template,
    collect_duplicates,
    iter_verb_files,
    normalize_hebrew,
)


FULL_TEMPLATE_CONTENT = """# Тестовий

## Інфінітив
- לכתוב (lichtov)

## Теперішній час
- כותב (kotev)

## Минулий час
- כתבתי (katavti)

## Майбутній час
- אכתוב (ekhtov)

## Наказовий спосіб
- כתוב (ktov)
"""

COMPACT_TEMPLATE_CONTENT = """# Тестовий

## Інфінітив
- לכתוב (lichtov)

## Часті форми
- כותב

## Короткі приклади
- אני כותב
"""

DUPLICATE_TITLE_LESSON_A = """# Писати

## Інфінітив
- לכתוב (lichtov)
"""

DUPLICATE_TITLE_LESSON_B = """# Писати

## Інфінітив
- לרשום (lirshom)
"""


class VerbLoaderTests(unittest.TestCase):
    def test_iter_verb_files_only_numbered_markdown(self):
        with tempfile.TemporaryDirectory() as raw_dir:
            tmp = Path(raw_dir)
            (tmp / "01_run.md").write_text("# Бігти", encoding="utf-8")
            (tmp / "02_walk.md").write_text("# Іти", encoding="utf-8")
            (tmp / "AGENTS.md").write_text("# rules", encoding="utf-8")
            (tmp / "notes.md").write_text("# nope", encoding="utf-8")

            files = iter_verb_files(tmp)

            self.assertEqual(
                [path.name for path in files],
                ["01_run.md", "02_walk.md"],
            )


class TemplateClassificationTests(unittest.TestCase):
    def test_full_template_is_detected(self):
        self.assertEqual(classify_template(FULL_TEMPLATE_CONTENT), "full")

    def test_compact_template_is_detected(self):
        self.assertEqual(
            classify_template(COMPACT_TEMPLATE_CONTENT), "compact"
        )

    def test_unrecognized_template_falls_back_to_other(self):
        self.assertEqual(classify_template("# Only a title"), "other")

    def test_audit_templates_buckets_files(self):
        with tempfile.TemporaryDirectory() as raw_dir:
            tmp = Path(raw_dir)
            (tmp / "01_full.md").write_text(
                FULL_TEMPLATE_CONTENT, encoding="utf-8"
            )
            (tmp / "02_compact.md").write_text(
                COMPACT_TEMPLATE_CONTENT, encoding="utf-8"
            )
            (tmp / "03_other.md").write_text("# Тільки заголовок", encoding="utf-8")
            (tmp / "04_empty.md").write_text("", encoding="utf-8")

            result = audit_templates(tmp)

            self.assertEqual(result.get("full"), ["01_full.md"])
            self.assertEqual(result.get("compact"), ["02_compact.md"])
            self.assertEqual(result.get("other"), ["03_other.md"])
            self.assertEqual(result.get("empty"), ["04_empty.md"])


class DuplicateDetectionTests(unittest.TestCase):
    def test_duplicate_titles_are_reported(self):
        with tempfile.TemporaryDirectory() as raw_dir:
            tmp = Path(raw_dir)
            (tmp / "01_a.md").write_text(
                DUPLICATE_TITLE_LESSON_A, encoding="utf-8"
            )
            (tmp / "02_b.md").write_text(
                DUPLICATE_TITLE_LESSON_B, encoding="utf-8"
            )

            title_dups, infinitive_dups = collect_duplicates(tmp)

            self.assertEqual(title_dups, {"Писати": ["01_a.md", "02_b.md"]})
            self.assertEqual(infinitive_dups, {})

    def test_normalize_hebrew_strips_parens_and_whitespace(self):
        self.assertEqual(
            normalize_hebrew("  לכתוב   (lichtov)  "), "לכתוב"
        )


class TransliterationAuditTests(unittest.TestCase):
    def test_detects_bom_and_apostrophes(self):
        with tempfile.TemporaryDirectory() as raw_dir:
            tmp = Path(raw_dir)
            (tmp / "01_bom.md").write_bytes(
                "﻿# Чисто".encode("utf-8")
            )
            (tmp / "02_apos.md").write_text(
                "## Інфінітив\n- לכתוב (li'chtov)\n",
                encoding="utf-8",
            )
            (tmp / "03_clean.md").write_text(
                "## Інфінітив\n- לכתוב (lichtov)\n",
                encoding="utf-8",
            )

            result = audit_transliterations(tmp)

            self.assertEqual(result["utf8_bom"], ["01_bom.md"])
            self.assertEqual(result["apostrophe_translits"], ["02_apos.md"])


if __name__ == "__main__":
    unittest.main()
