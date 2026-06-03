"""Diff verb candidates against the verb module under flutter_app/.../verbs/.

Reads:
  - flutter_app/assets/learning/input/verbs/*.md  (existing verb lessons)
  - docs/vocabulary_expansion/top_frequency_candidates.json  (proposed words)

Writes:
  - docs/vocabulary_expansion/verbs_to_add.md  (missing verb infinitives)
  - docs/vocabulary_expansion/verbs_to_add.json  (machine-readable)

Each existing verb lesson exposes its infinitive as the first bullet under
the `## Інфінітив` heading. We compare nikud-stripped infinitive forms.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERB_DIR = ROOT / "flutter_app" / "assets" / "learning" / "input" / "verbs"
CANDIDATES_PATH = ROOT / "docs" / "vocabulary_expansion" / "top_frequency_candidates.json"
OUT_DIR = ROOT / "docs" / "vocabulary_expansion"

NIKUD_RE = re.compile(r"[֑-ׇ]")
INFINITIVE_RE = re.compile(r"## Інфінітив\s*\r?\n+\s*-\s*([^\s\(]+)", re.UNICODE)


def strip_nikud(text: str) -> str:
    return NIKUD_RE.sub("", text).strip()


def normalize_consonants(text: str) -> str:
    """Aggressive normalization for matching ktiv-male vs ktiv-haser spellings.

    Strips nikud, then removes vav (ו) anywhere except the first letter. Yud (י)
    is preserved because it carries more semantic weight in short words.
    This is a heuristic — it can create false matches for rare pairs, but it
    collapses the common ktiv-male/haser distinction for verb infinitives.
    """
    s = strip_nikud(text)
    if len(s) <= 2:
        return s
    return s[0] + s[1:].replace("ו", "")


def load_existing_infinitives(verb_dir: Path) -> tuple[set[str], int]:
    """Return (lookup_set, file_count). Lookup set has both plain-stripped and ktiv-collapsed forms."""
    found: set[str] = set()
    file_count = 0
    for md in verb_dir.glob("*.md"):
        if md.name == "AGENTS.md":
            continue
        text = md.read_text(encoding="utf-8")
        m = INFINITIVE_RE.search(text)
        if m:
            file_count += 1
            raw = m.group(1)
            found.add(strip_nikud(raw))
            found.add(normalize_consonants(raw))
    return found, file_count


def main() -> int:
    if not CANDIDATES_PATH.exists():
        print(f"Candidates file not found: {CANDIDATES_PATH}", file=sys.stderr)
        return 1

    existing, file_count = load_existing_infinitives(VERB_DIR)
    candidates = json.loads(CANDIDATES_PATH.read_text(encoding="utf-8"))
    verb_candidates = [c for c in candidates if c.get("category") == "verbs"]

    missing: list[dict] = []
    present: list[dict] = []
    for c in verb_candidates:
        plain = strip_nikud(c["hebrew"])
        normalized = normalize_consonants(c["hebrew"])
        if plain in existing or normalized in existing:
            present.append(c)
        else:
            missing.append(c)

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    md_lines = [
        "# Verb candidates vs. verb module",
        "",
        f"Verb lessons on disk: {file_count}. Verb candidates checked: {len(verb_candidates)}. Already covered: {len(present)}. Missing: {len(missing)}.",
        "",
        "## Missing infinitives",
        "",
        "If these are worth adding, create new files under `flutter_app/assets/learning/input/verbs/` following the format in `01_walk.md`.",
        "",
        "| Hebrew | Transcription | English | Ukrainian |",
        "|---|---|---|---|",
    ]
    for m in missing:
        md_lines.append(
            f"| {m['hebrew']} | {m['transcription']} | {m['english']} | {m['ukrainian']} |"
        )
    (OUT_DIR / "verbs_to_add.md").write_text("\n".join(md_lines), encoding="utf-8")

    (OUT_DIR / "verbs_to_add.json").write_text(
        json.dumps(missing, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print(f"Verb lessons on disk: {file_count}")
    print(f"Verb candidates: {len(verb_candidates)}")
    print(f"Already covered: {len(present)}")
    print(f"Missing: {len(missing)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
