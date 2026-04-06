from __future__ import annotations

import argparse
import re
import unicodedata
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VERBS_DIR = ROOT / "data" / "input" / "verbs"


def iter_verb_files() -> list[Path]:
    return sorted(
        path
        for path in VERBS_DIR.glob("*.md")
        if path.stem[:1].isdigit()
    )


def normalize_hebrew(text: str) -> str:
    text = text.split("(")[0].strip()
    text = text.replace("\u200f", "")
    text = re.sub(r"\s+", " ", text)
    return unicodedata.normalize("NFC", text)


def extract_title(lines: list[str]) -> str:
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def extract_infinitive(lines: list[str]) -> str:
    for index, line in enumerate(lines):
        if line.strip() != "## Інфінітив":
            continue
        for next_line in lines[index + 1:index + 6]:
            if next_line.startswith("- "):
                return next_line[2:].strip()
        break
    return ""


def collect_duplicates() -> tuple[dict[str, list[str]], dict[str, list[str]]]:
    titles: dict[str, list[str]] = defaultdict(list)
    infinitives: dict[str, list[str]] = defaultdict(list)

    for path in iter_verb_files():
        lines = path.read_text(encoding="utf-8").splitlines()
        title = extract_title(lines)
        infinitive = extract_infinitive(lines)

        if title:
            titles[title].append(path.name)
        if infinitive:
            infinitives[normalize_hebrew(infinitive)].append(path.name)

    title_dups = {
        title: files
        for title, files in titles.items()
        if len(files) > 1
    }
    infinitive_dups = {
        infinitive: files
        for infinitive, files in infinitives.items()
        if len(files) > 1
    }
    return title_dups, infinitive_dups


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Audit duplicate verb titles and infinitives under data/input/verbs.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return a non-zero exit code when any duplicates are found.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    title_dups, infinitive_dups = collect_duplicates()

    print(f"Audited {len(iter_verb_files())} verb files in {VERBS_DIR}")
    print(f"- duplicate_titles: {len(title_dups)}")
    print(f"- duplicate_infinitives: {len(infinitive_dups)}")

    if title_dups:
        print("\n[duplicate titles]")
        for title, files in sorted(title_dups.items()):
            print(f"- {title}: {', '.join(files)}")

    if infinitive_dups:
        print("\n[duplicate infinitives]")
        for infinitive, files in sorted(infinitive_dups.items()):
            print(f"- {infinitive}: {', '.join(files)}")

    if args.strict and (title_dups or infinitive_dups):
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
