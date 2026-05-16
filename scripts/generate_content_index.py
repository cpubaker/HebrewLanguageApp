from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT_ROOT = PROJECT_ROOT / "flutter_app" / "assets" / "learning" / "input"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "docs" / "content_index.json"
DEFAULT_COMPACT_OUTPUT_PATH = PROJECT_ROOT / "docs" / "content_index.compact.json"
SCHEMA_VERSION = 1


def build_content_index(input_root: Path = DEFAULT_INPUT_ROOT) -> dict[str, Any]:
    lesson_catalog = _read_json_object(input_root / "lesson_catalog.json")
    guide_metadata = _read_json_object(input_root / "guide_metadata.json")
    words = _read_json_list(input_root / "hebrew_words.json")
    context_sentences = _read_json_list(input_root / "contexts" / "sentences.json")

    guide_sections = _string_map(guide_metadata.get("sections"))
    guide_lessons = _guide_lessons(
        input_root=input_root,
        catalog_entries=_string_list(lesson_catalog.get("guide")),
        guide_metadata=guide_metadata,
        guide_sections=guide_sections,
    )
    reading_lessons = _reading_lessons(
        input_root=input_root,
        catalog_entries=_string_list(lesson_catalog.get("reading")),
    )
    verb_lessons = _verb_lessons(
        input_root=input_root,
        catalog_entries=_string_list(lesson_catalog.get("verbs")),
    )
    vocabulary = _vocabulary_entries(words)

    return {
        "schema_version": SCHEMA_VERSION,
        "source_root": "flutter_app/assets/learning/input",
        "counts": {
            "vocabulary": len(vocabulary),
            "context_sentences": len(context_sentences),
            "guide_lessons": len(guide_lessons),
            "reading_lessons": len(reading_lessons),
            "verb_lessons": len(verb_lessons),
        },
        "guide_sections": guide_sections,
        "guide_lessons": guide_lessons,
        "reading_lessons": reading_lessons,
        "verb_lessons": verb_lessons,
        "vocabulary": vocabulary,
    }


def write_content_index(
    *,
    input_root: Path = DEFAULT_INPUT_ROOT,
    output_path: Path = DEFAULT_OUTPUT_PATH,
    compact_output_path: Path | None = DEFAULT_COMPACT_OUTPUT_PATH,
) -> None:
    content_index = build_content_index(input_root)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(content_index, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    if compact_output_path is not None:
        compact_output_path.parent.mkdir(parents=True, exist_ok=True)
        compact_output_path.write_text(
            _serialize_compact(build_compact_content_index(content_index)),
            encoding="utf-8",
        )


def build_compact_content_index(content_index: dict[str, Any]) -> dict[str, Any]:
    return {
        "schema_version": content_index.get("schema_version", SCHEMA_VERSION),
        "source_root": content_index.get("source_root", ""),
        "counts": content_index.get("counts", {}),
        "guide_sections": content_index.get("guide_sections", {}),
        "guide_lessons": [
            _compact_guide_lesson(lesson)
            for lesson in content_index.get("guide_lessons", [])
        ],
        "reading_lessons": [
            _compact_reading_lesson(lesson)
            for lesson in content_index.get("reading_lessons", [])
        ],
        "verb_lessons": [
            _compact_verb_lesson(lesson)
            for lesson in content_index.get("verb_lessons", [])
        ],
    }


def _compact_guide_lesson(lesson: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": lesson.get("id", ""),
        "path": lesson.get("path", ""),
        "title": lesson.get("title", ""),
        "section": lesson.get("section", ""),
    }


def _compact_reading_lesson(lesson: dict[str, Any]) -> dict[str, Any]:
    return {
        "path": lesson.get("path", ""),
        "level": lesson.get("level", ""),
        "title": lesson.get("title", ""),
    }


def _compact_verb_lesson(lesson: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": lesson.get("id", ""),
        "path": lesson.get("path", ""),
        "title": lesson.get("title", ""),
        "infinitive": lesson.get("infinitive", ""),
    }


def _serialize_compact(payload: dict[str, Any]) -> str:
    lines: list[str] = ["{"]
    items = list(payload.items())
    for index, (key, value) in enumerate(items):
        trailing = "," if index < len(items) - 1 else ""
        key_repr = json.dumps(key, ensure_ascii=False)
        if isinstance(value, list) and value and isinstance(value[0], dict):
            lines.append(f"  {key_repr}: [")
            for item_index, item in enumerate(value):
                item_trailing = "," if item_index < len(value) - 1 else ""
                item_repr = json.dumps(
                    item, ensure_ascii=False, separators=(",", ":")
                )
                lines.append(f"    {item_repr}{item_trailing}")
            lines.append(f"  ]{trailing}")
        else:
            value_repr = json.dumps(
                value, ensure_ascii=False, separators=(",", ":")
            )
            lines.append(f"  {key_repr}: {value_repr}{trailing}")
    lines.append("}")
    return "\n".join(lines) + "\n"


def _guide_lessons(
    *,
    input_root: Path,
    catalog_entries: list[str],
    guide_metadata: dict[str, Any],
    guide_sections: dict[str, str],
) -> list[dict[str, Any]]:
    lessons_metadata = guide_metadata.get("lessons")
    if not isinstance(lessons_metadata, dict):
        lessons_metadata = {}

    lessons: list[dict[str, Any]] = []
    for relative_path in catalog_entries:
        path = input_root / "guide" / relative_path
        metadata = lessons_metadata.get(Path(relative_path).name)
        if not isinstance(metadata, dict):
            metadata = {}
        section_id = _clean_optional_string(metadata.get("section"))
        lesson = {
            "path": f"guide/{relative_path}",
            "id": _clean_optional_string(metadata.get("id"))
            or _lesson_id_from_path(relative_path),
            "title": _clean_optional_string(metadata.get("title"))
            or _extract_markdown_title(path),
            "section": section_id,
            "section_label": guide_sections.get(section_id, ""),
            "order": metadata.get("order") if isinstance(metadata.get("order"), int) else None,
            "aliases": _string_list(metadata.get("aliases")),
            "related_ids": _string_list(metadata.get("related_ids")),
        }
        lessons.append(lesson)
    return lessons


def _reading_lessons(
    *,
    input_root: Path,
    catalog_entries: list[str],
) -> list[dict[str, Any]]:
    lessons: list[dict[str, Any]] = []
    for relative_path in catalog_entries:
        level = relative_path.split("/", 1)[0] if "/" in relative_path else ""
        lessons.append(
            {
                "path": f"reading/{relative_path}",
                "level": level,
                "title": _extract_markdown_title(input_root / "reading" / relative_path),
            }
        )
    return lessons


def _verb_lessons(
    *,
    input_root: Path,
    catalog_entries: list[str],
) -> list[dict[str, Any]]:
    lessons: list[dict[str, Any]] = []
    for relative_path in catalog_entries:
        path = input_root / "verbs" / relative_path
        infinitive = _extract_verb_infinitive(path)
        lessons.append(
            {
                "path": f"verbs/{relative_path}",
                "id": _lesson_id_from_path(relative_path),
                "title": _extract_markdown_title(path),
                "infinitive": infinitive["hebrew"],
                "transcription": infinitive["transcription"],
            }
        )
    return lessons


def _vocabulary_entries(words: list[Any]) -> list[dict[str, str]]:
    entries: list[dict[str, str]] = []
    for raw_word in words:
        if not isinstance(raw_word, dict):
            continue
        entries.append(
            {
                "word_id": _clean_optional_string(raw_word.get("word_id")),
                "hebrew": _clean_optional_string(raw_word.get("hebrew")),
                "ukrainian": _clean_optional_string(raw_word.get("ukrainian")),
                "transcription": _clean_optional_string(raw_word.get("transcription")),
            }
        )
    return entries


def _extract_markdown_title(path: Path) -> str:
    content = path.read_text(encoding="utf-8-sig")
    for line in content.splitlines():
        stripped = line.strip().lstrip("\ufeff")
        if not stripped:
            continue
        heading_match = re.match(r"^#{1,6}\s+(.*)$", stripped)
        if heading_match:
            return heading_match.group(1).strip()
        return stripped
    return ""


def _extract_verb_infinitive(path: Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8-sig").splitlines()
    for index, line in enumerate(lines):
        if line.strip() != "## Інфінітив":
            continue
        for candidate in lines[index + 1 : index + 8]:
            stripped = candidate.strip()
            if stripped.startswith("## "):
                break
            if not stripped.startswith("- "):
                continue
            raw_value = stripped[2:].strip()
            transliteration_match = re.search(r"\(([^()]*)\)", raw_value)
            transliteration = (
                transliteration_match.group(1).strip()
                if transliteration_match is not None
                else ""
            )
            hebrew = re.sub(r"\([^()]*\)", "", raw_value)
            hebrew = re.split(r"\s+[—-]\s+", hebrew, maxsplit=1)[0].strip()
            return {"hebrew": hebrew, "transcription": transliteration}
        break
    return {"hebrew": "", "transcription": ""}


def _lesson_id_from_path(relative_path: str) -> str:
    stem = Path(relative_path).stem
    return re.sub(r"^\d+[_-]*", "", stem)


def _read_json_object(path: Path) -> dict[str, Any]:
    decoded = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(decoded, dict):
        raise ValueError(f"Expected JSON object: {path}")
    return decoded


def _read_json_list(path: Path) -> list[Any]:
    decoded = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(decoded, list):
        raise ValueError(f"Expected JSON list: {path}")
    return decoded


def _string_map(value: Any) -> dict[str, str]:
    if not isinstance(value, dict):
        return {}
    return {
        str(key): str(item)
        for key, item in value.items()
        if str(key).strip() and str(item).strip()
    }


def _string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [item.strip() for item in value if isinstance(item, str) and item.strip()]


def _clean_optional_string(value: Any) -> str:
    return value.strip() if isinstance(value, str) else ""


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a compact AI/search index for canonical learning content.",
    )
    parser.add_argument(
        "--input-root",
        type=Path,
        default=DEFAULT_INPUT_ROOT,
        help="Canonical learning input root.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_PATH,
        help="Output JSON path.",
    )
    parser.add_argument(
        "--compact-output",
        type=Path,
        default=DEFAULT_COMPACT_OUTPUT_PATH,
        help="Compact lookup JSON path (cheap to read for AI agents).",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    write_content_index(
        input_root=args.input_root,
        output_path=args.output,
        compact_output_path=args.compact_output,
    )
    print(f"Generated content index at {args.output}")
    print(f"Generated compact index at {args.compact_output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
