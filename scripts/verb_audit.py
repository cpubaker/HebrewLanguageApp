"""Audit verb lesson content under flutter_app/assets/learning/input/verbs.

Subcommands:
  templates         classify lessons by template (full/compact/other/empty)
  duplicates        find duplicate titles and infinitives
  transliterations  find UTF-8 BOM and suspicious apostrophe usage
  all               run all three audits in sequence

Each subcommand supports --strict to return a non-zero exit code on findings.
"""

from __future__ import annotations

import argparse
import re
import unicodedata
from collections import defaultdict
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
VERBS_DIR = (
    PROJECT_ROOT / "flutter_app" / "assets" / "learning" / "input" / "verbs"
)

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

TRANSLIT_PARENS_RE = re.compile(r"\(([^\n()]+)\)")
SUSPICIOUS_APOSTROPHE_RE = re.compile(r"(^|[ -]).'[^ ]")


def iter_verb_files(verbs_dir: Path = VERBS_DIR) -> list[Path]:
    return sorted(
        path for path in verbs_dir.glob("*.md") if path.stem[:1].isdigit()
    )


# ---------- templates ----------


def classify_template(content: str) -> str:
    if all(heading in content for heading in FULL_TEMPLATE_HEADINGS):
        return "full"
    if all(heading in content for heading in COMPACT_TEMPLATE_HEADINGS):
        return "compact"
    return "other"


def audit_templates(verbs_dir: Path = VERBS_DIR) -> dict[str, list[str]]:
    files_by_template: dict[str, list[str]] = defaultdict(list)
    for path in iter_verb_files(verbs_dir):
        content = path.read_text(encoding="utf-8").strip()
        if not content:
            files_by_template["empty"].append(path.name)
            continue
        files_by_template[classify_template(content)].append(path.name)
    return dict(files_by_template)


def run_templates(args: argparse.Namespace) -> int:
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


# ---------- duplicates ----------


def normalize_hebrew(text: str) -> str:
    text = text.split("(")[0].strip()
    text = text.replace("‏", "")
    text = re.sub(r"\s+", " ", text)
    return unicodedata.normalize("NFC", text)


def _extract_title(lines: list[str]) -> str:
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def _extract_infinitive(lines: list[str]) -> str:
    for index, line in enumerate(lines):
        if line.strip() != "## Інфінітив":
            continue
        for next_line in lines[index + 1 : index + 6]:
            if next_line.startswith("- "):
                return next_line[2:].strip()
        break
    return ""


def collect_duplicates(
    verbs_dir: Path = VERBS_DIR,
) -> tuple[dict[str, list[str]], dict[str, list[str]]]:
    titles: dict[str, list[str]] = defaultdict(list)
    infinitives: dict[str, list[str]] = defaultdict(list)

    for path in iter_verb_files(verbs_dir):
        lines = path.read_text(encoding="utf-8").splitlines()
        title = _extract_title(lines)
        infinitive = _extract_infinitive(lines)
        if title:
            titles[title].append(path.name)
        if infinitive:
            infinitives[normalize_hebrew(infinitive)].append(path.name)

    title_dups = {
        title: files for title, files in titles.items() if len(files) > 1
    }
    infinitive_dups = {
        infinitive: files
        for infinitive, files in infinitives.items()
        if len(files) > 1
    }
    return title_dups, infinitive_dups


def run_duplicates(args: argparse.Namespace) -> int:
    title_dups, infinitive_dups = collect_duplicates(VERBS_DIR)
    total = len(iter_verb_files(VERBS_DIR))

    print(f"Audited {total} verb files in {VERBS_DIR}")
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


# ---------- transliterations ----------


def audit_transliterations(
    verbs_dir: Path = VERBS_DIR,
) -> dict[str, list[str]]:
    bom_files: list[str] = []
    apostrophe_files: list[str] = []
    suspicious_files: list[str] = []

    for path in iter_verb_files(verbs_dir):
        raw = path.read_bytes()
        text = raw.decode("utf-8-sig")
        translits = TRANSLIT_PARENS_RE.findall(text)

        if raw.startswith(b"\xef\xbb\xbf"):
            bom_files.append(path.name)
        if any("'" in candidate for candidate in translits):
            apostrophe_files.append(path.name)
        if any(
            SUSPICIOUS_APOSTROPHE_RE.search(candidate)
            for candidate in translits
        ):
            suspicious_files.append(path.name)

    return {
        "utf8_bom": bom_files,
        "apostrophe_translits": apostrophe_files,
        "suspicious_apostrophe_cases": suspicious_files,
    }


def run_transliterations(args: argparse.Namespace) -> int:
    result = audit_transliterations(VERBS_DIR)
    total = len(iter_verb_files(VERBS_DIR))

    print(f"Audited {total} verb files in {VERBS_DIR}")
    for label in (
        "utf8_bom",
        "apostrophe_translits",
        "suspicious_apostrophe_cases",
    ):
        print(f"- {label}: {len(result[label])}")

    if args.show_files:
        if result["utf8_bom"]:
            print()
            print("UTF-8 BOM:")
            for name in result["utf8_bom"]:
                print(f"- {name}")
        if result["suspicious_apostrophe_cases"]:
            print()
            print("Suspicious apostrophe cases:")
            for name in result["suspicious_apostrophe_cases"]:
                print(f"- {name}")

    if args.strict and (
        result["utf8_bom"] or result["suspicious_apostrophe_cases"]
    ):
        return 1
    return 0


# ---------- all ----------


def run_all(args: argparse.Namespace) -> int:
    inner = argparse.Namespace(strict=args.strict, show_files=args.show_files)
    exit_codes: list[int] = []

    print("=== Templates ===")
    exit_codes.append(run_templates(inner))
    print()
    print("=== Duplicates ===")
    exit_codes.append(run_duplicates(inner))
    print()
    print("=== Transliterations ===")
    exit_codes.append(run_transliterations(inner))

    return max(exit_codes) if args.strict else 0


# ---------- CLI ----------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Audit verb lesson content (templates, duplicates, "
            "transliterations) under flutter_app/assets/learning/input/verbs."
        ),
    )
    subparsers = parser.add_subparsers(dest="check", required=True)

    templates_parser = subparsers.add_parser(
        "templates", help="Classify lessons by template (full/compact/other)."
    )
    templates_parser.add_argument("--strict", action="store_true")
    templates_parser.add_argument("--show-files", action="store_true")
    templates_parser.set_defaults(func=run_templates)

    duplicates_parser = subparsers.add_parser(
        "duplicates", help="Find duplicate titles and infinitives."
    )
    duplicates_parser.add_argument("--strict", action="store_true")
    duplicates_parser.add_argument("--show-files", action="store_true")
    duplicates_parser.set_defaults(func=run_duplicates)

    translits_parser = subparsers.add_parser(
        "transliterations",
        help="Find UTF-8 BOM and suspicious apostrophe usage.",
    )
    translits_parser.add_argument("--strict", action="store_true")
    translits_parser.add_argument("--show-files", action="store_true")
    translits_parser.set_defaults(func=run_transliterations)

    all_parser = subparsers.add_parser(
        "all", help="Run templates, duplicates, and transliterations in sequence."
    )
    all_parser.add_argument("--strict", action="store_true")
    all_parser.add_argument("--show-files", action="store_true")
    all_parser.set_defaults(func=run_all)

    return parser


def main() -> int:
    args = build_parser().parse_args()
    if not VERBS_DIR.exists():
        print(f"Verbs directory not found: {VERBS_DIR}")
        return 1
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
