from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
VERBS_DIR = ROOT / "data" / "input" / "verbs"
TRANSLIT_RE = re.compile(r"\(([^\n()]+)\)")
SUSPICIOUS_APOSTROPHE_RE = re.compile(r"(^|[ -]).'[^ ]")


def iter_verb_files() -> list[Path]:
    return sorted(
        path for path in VERBS_DIR.glob("*.md")
        if path.stem[:1].isdigit()
    )


def main() -> int:
    files = iter_verb_files()
    bom_files: list[str] = []
    apostrophe_files: list[str] = []
    suspicious_files: list[str] = []

    for path in files:
        raw = path.read_bytes()
        text = raw.decode("utf-8-sig")
        translits = TRANSLIT_RE.findall(text)

        if raw.startswith(b"\xef\xbb\xbf"):
            bom_files.append(path.name)
        if any("'" in t for t in translits):
            apostrophe_files.append(path.name)
        if any(SUSPICIOUS_APOSTROPHE_RE.search(t) for t in translits):
            suspicious_files.append(path.name)

    print(f"Audited {len(files)} verb files in {VERBS_DIR}")
    print(f"- utf8_bom: {len(bom_files)}")
    print(f"- apostrophe_translits: {len(apostrophe_files)}")
    print(f"- suspicious_apostrophe_cases: {len(suspicious_files)}")

    if "--show-files" in sys.argv:
        if bom_files:
            print()
            print("UTF-8 BOM:")
            for name in bom_files:
                print(f"- {name}")
        if suspicious_files:
            print()
            print("Suspicious apostrophe cases:")
            for name in suspicious_files:
                print(f"- {name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())