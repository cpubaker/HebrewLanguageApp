from __future__ import annotations

import argparse
from collections import defaultdict
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
VERBS_DIR = PROJECT_ROOT / "data" / "input" / "verbs"

FULL_TEMPLATE_HEADINGS = (
    "## Інфінітив",
    "## Теперішній час",
    "## Минулий час",
    "## Майбутній час",
    "## Наказовий спосіб",
)

COMPACT_TEMPLATE_HEADINGS = (
    "## Інфінітив",
    "## Часті форми",
    "## Короткі приклади",
)


def classify_template(content: str) -> str:
    if all(heading in content for heading in FULL_TEMPLATE_HEADINGS):
        return "full"

    if all(heading in content for heading in COMPACT_TEMPLATE_HEADINGS):
        return "compact"

    return "other"


def audit_templates(verbs_dir: Path) -> dict[str, list[str]]:
    files_by_template: dict[str, list[str]] = defaultdict(list)

    for lesson_file in sorted(verbs_dir.glob("*.md")):
        content = lesson_file.read_text(encoding="utf-8").strip()
        if not content:
            files_by_template["empty"].append(lesson_file.name)
            continue

        files_by_template[classify_template(content)].append(lesson_file.name)

    return dict(files_by_template)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Audit verb lesson templates under data/input/verbs.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return a non-zero exit code when any file is not in the full template.",
    )
    parser.add_argument(
        "--show-files",
        action="store_true",
        help="Print filenames for each detected template group.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if not VERBS_DIR.exists():
        parser.error(f"Verbs directory not found: {VERBS_DIR}")

    files_by_template = audit_templates(VERBS_DIR)
    total = sum(len(files) for files in files_by_template.values())

    print(f"Audited {total} verb files in {VERBS_DIR}")
    for template_name in ("full", "compact", "other", "empty"):
        files = files_by_template.get(template_name, [])
        if files:
            print(f"- {template_name}: {len(files)}")

    if args.show_files:
        for template_name in ("full", "compact", "other", "empty"):
            files = files_by_template.get(template_name, [])
            if not files:
                continue

            print(f"\n[{template_name}]")
            for filename in files:
                print(filename)

    non_full_count = total - len(files_by_template.get("full", []))
    if args.strict and non_full_count:
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
