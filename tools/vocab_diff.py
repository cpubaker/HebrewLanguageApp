"""Diff a candidate frequency list against the current hebrew_words.json.

Reads:
  - flutter_app/assets/learning/input/hebrew_words.json  (existing vocabulary)
  - docs/vocabulary_expansion/top_frequency_candidates.json  (proposed words)

Writes:
  - docs/vocabulary_expansion/words_to_add.md  (missing entries, grouped by category)
  - docs/vocabulary_expansion/words_to_add.json  (machine-readable missing list)
  - docs/vocabulary_expansion/diff_summary.txt  (counts per category)

Nikud (Hebrew diacritics) and surrounding whitespace are stripped before comparison.

Verbs live in their own module (`flutter_app/assets/learning/input/verbs/`)
and must not be added to `hebrew_words.json`. Candidates with category="verbs"
are excluded from the words_to_add output. Use `tools/verb_diff.py` to diff
against the verb module.
"""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXISTING_PATH = ROOT / "flutter_app" / "assets" / "learning" / "input" / "hebrew_words.json"
CANDIDATES_PATH = ROOT / "docs" / "vocabulary_expansion" / "top_frequency_candidates.json"
OUT_DIR = ROOT / "docs" / "vocabulary_expansion"

EXCLUDED_CATEGORIES = {"verbs"}

NIKUD_RE = re.compile(r"[֑-ׇ]")


def strip_nikud(text: str) -> str:
    return NIKUD_RE.sub("", text).strip()


def split_variants(hebrew: str) -> list[str]:
    parts = re.split(r"[/|]", hebrew)
    return [strip_nikud(p) for p in parts if strip_nikud(p)]


def load_existing_keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    keys: set[str] = set()
    for entry in data:
        for variant in split_variants(entry["hebrew"]):
            keys.add(variant)
    return keys


def main() -> int:
    if not CANDIDATES_PATH.exists():
        print(f"Candidates file not found: {CANDIDATES_PATH}", file=sys.stderr)
        return 1

    existing = load_existing_keys(EXISTING_PATH)
    candidates = json.loads(CANDIDATES_PATH.read_text(encoding="utf-8"))

    missing: list[dict] = []
    present: list[dict] = []
    excluded: list[dict] = []
    for c in candidates:
        if c.get("category") in EXCLUDED_CATEGORIES:
            excluded.append(c)
            continue
        plain_variants = split_variants(c["hebrew"])
        if any(v in existing for v in plain_variants):
            present.append(c)
        else:
            missing.append(c)

    by_cat: dict[str, list[dict]] = defaultdict(list)
    for m in missing:
        by_cat[m.get("category", "other")].append(m)

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    summary_lines = [
        f"Existing entries: {len(existing)} unique stripped Hebrew forms",
        f"Candidates evaluated: {len(candidates)}",
        f"Excluded (in separate modules, e.g. verbs): {len(excluded)}",
        f"Already present: {len(present)}",
        f"Missing (to add): {len(missing)}",
        "",
        "Missing per category:",
    ]
    for cat in sorted(by_cat):
        summary_lines.append(f"  {cat}: {len(by_cat[cat])}")
    (OUT_DIR / "diff_summary.txt").write_text("\n".join(summary_lines), encoding="utf-8")

    md_lines = [
        "# Words to add (frequency-driven)",
        "",
        f"Generated from `tools/vocab_diff.py`. Existing: {len(existing)}. Candidates checked: {len(candidates)}. Missing: {len(missing)}.",
        "",
    ]
    for cat in sorted(by_cat):
        md_lines.append(f"## {cat} ({len(by_cat[cat])})")
        md_lines.append("")
        md_lines.append("| Hebrew | Transcription | English | Ukrainian | Note |")
        md_lines.append("|---|---|---|---|---|")
        for m in by_cat[cat]:
            note = m.get("note", "")
            md_lines.append(
                f"| {m['hebrew']} | {m['transcription']} | {m['english']} | {m['ukrainian']} | {note} |"
            )
        md_lines.append("")
    (OUT_DIR / "words_to_add.md").write_text("\n".join(md_lines), encoding="utf-8")

    (OUT_DIR / "words_to_add.json").write_text(
        json.dumps(missing, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print("\n".join(summary_lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
