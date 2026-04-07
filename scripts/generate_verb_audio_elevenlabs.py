from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path


DEFAULT_MODEL = "eleven_v3"
DEFAULT_LANGUAGE_CODE = "he"
DEFAULT_OUTPUT_FORMAT = "mp3_44100_128"
DEFAULT_TIMEOUT_SECONDS = 90


@dataclass(frozen=True)
class VerbAudioJob:
    source_path: Path
    stem: str
    text: str
    output_path: Path


def build_parser() -> argparse.ArgumentParser:
    repo_root = Path(__file__).resolve().parents[1]

    parser = argparse.ArgumentParser(
        description=(
            "Generate verb pronunciation audio with the ElevenLabs Text-to-Speech API. "
            "By default, the script extracts the infinitive from each verb lesson and "
            "writes matching MP3 files into data/input/audio/verbs."
        )
    )
    parser.add_argument(
        "--verbs-dir",
        type=Path,
        default=repo_root / "data" / "input" / "verbs",
        help="Directory with numbered verb lesson markdown files.",
    )
    parser.add_argument(
        "--audio-dir",
        type=Path,
        default=repo_root / "data" / "input" / "audio" / "verbs",
        help="Directory where generated MP3 files will be written.",
    )
    parser.add_argument(
        "--api-key",
        default=os.environ.get("ELEVENLABS_API_KEY", ""),
        help="ElevenLabs API key. Defaults to ELEVENLABS_API_KEY.",
    )
    parser.add_argument(
        "--voice-id",
        default=os.environ.get("ELEVENLABS_VOICE_ID", ""),
        help="ElevenLabs voice ID. Defaults to ELEVENLABS_VOICE_ID.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"ElevenLabs model ID. Defaults to {DEFAULT_MODEL}.",
    )
    parser.add_argument(
        "--language-code",
        default=DEFAULT_LANGUAGE_CODE,
        help=f"Language code sent to the API. Defaults to {DEFAULT_LANGUAGE_CODE}.",
    )
    parser.add_argument(
        "--output-format",
        default=DEFAULT_OUTPUT_FORMAT,
        help=f"ElevenLabs output format. Defaults to {DEFAULT_OUTPUT_FORMAT}.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Optional max number of files to generate in this run.",
    )
    parser.add_argument(
        "--only-stem",
        action="append",
        default=[],
        help="Only generate audio for a specific lesson stem, for example: --only-stem want",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Regenerate files even when the target MP3 already exists.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the planned work without calling the API.",
    )
    parser.add_argument(
        "--pause-seconds",
        type=float,
        default=0.0,
        help="Optional delay between requests.",
    )
    parser.add_argument(
        "--timeout-seconds",
        type=int,
        default=DEFAULT_TIMEOUT_SECONDS,
        help=f"HTTP timeout in seconds. Defaults to {DEFAULT_TIMEOUT_SECONDS}.",
    )
    return parser


def main() -> int:
    configure_console_streams()

    parser = build_parser()
    args = parser.parse_args()

    verbs_dir = args.verbs_dir.resolve()
    audio_dir = args.audio_dir.resolve()
    only_stems = {stem.strip().lower() for stem in args.only_stem if stem.strip()}

    if not verbs_dir.exists():
        print(f"Verb directory not found: {verbs_dir}", file=sys.stderr)
        return 1

    jobs, skipped_existing, parse_failures = collect_jobs(
        verbs_dir=verbs_dir,
        audio_dir=audio_dir,
        only_stems=only_stems,
        force=args.force,
    )

    if args.limit and args.limit > 0:
        jobs = jobs[: args.limit]

    print(
        "Planned verb audio jobs: "
        f"{len(jobs)} | skipped existing: {skipped_existing} | parse failures: {len(parse_failures)}"
    )

    for failure in parse_failures:
        print(f"Could not extract infinitive from {failure}", file=sys.stderr)

    if not jobs:
        return 0 if not parse_failures else 1

    for job in jobs:
        print(f"- {job.stem}: {job.text} -> {job.output_path}")

    if args.dry_run:
        return 0 if not parse_failures else 1

    if not args.api_key:
        print(
            "Missing ElevenLabs API key. Set ELEVENLABS_API_KEY or pass --api-key.",
            file=sys.stderr,
        )
        return 1

    if not args.voice_id:
        print(
            "Missing ElevenLabs voice ID. Set ELEVENLABS_VOICE_ID or pass --voice-id.",
            file=sys.stderr,
        )
        return 1

    audio_dir.mkdir(parents=True, exist_ok=True)

    success_count = 0
    error_count = 0

    for index, job in enumerate(jobs, start=1):
        print(f"[{index}/{len(jobs)}] Generating {job.output_path.name}")
        try:
            audio_bytes = synthesize_speech(
                api_key=args.api_key,
                voice_id=args.voice_id,
                text=job.text,
                model=args.model,
                language_code=args.language_code,
                output_format=args.output_format,
                timeout_seconds=args.timeout_seconds,
            )
            job.output_path.write_bytes(audio_bytes)
            success_count += 1
        except RuntimeError as error:
            error_count += 1
            print(f"Failed to generate {job.stem}: {error}", file=sys.stderr)

        if args.pause_seconds > 0 and index < len(jobs):
            time.sleep(args.pause_seconds)

    print(f"Finished. Success: {success_count} | Failed: {error_count}")
    return 0 if error_count == 0 and not parse_failures else 1


def collect_jobs(
    *,
    verbs_dir: Path,
    audio_dir: Path,
    only_stems: set[str],
    force: bool,
) -> tuple[list[VerbAudioJob], int, list[Path]]:
    jobs: list[VerbAudioJob] = []
    skipped_existing = 0
    parse_failures: list[Path] = []

    for source_path in iter_verb_files(verbs_dir):
        stem = lesson_stem(source_path)
        if not stem:
            continue

        if only_stems and stem.lower() not in only_stems:
            continue

        output_path = audio_dir / f"{stem}.mp3"
        if output_path.exists() and not force:
            skipped_existing += 1
            continue

        text = extract_infinitive_text(source_path.read_text(encoding="utf-8"))
        if not text:
            parse_failures.append(source_path)
            continue

        jobs.append(
            VerbAudioJob(
                source_path=source_path,
                stem=stem,
                text=text,
                output_path=output_path,
            )
        )

    return jobs, skipped_existing, parse_failures


def iter_verb_files(verbs_dir: Path):
    return sorted(
        (
            path
            for path in verbs_dir.iterdir()
            if path.is_file() and path.suffix.lower() == ".md" and re.match(r"^\d+", path.stem)
        ),
        key=lesson_sort_key,
    )


def lesson_sort_key(path: Path):
    match = re.match(r"^(\d+)", path.stem)
    if match:
        return (0, int(match.group(1)), path.stem.lower())
    return (1, path.stem.lower())


def lesson_stem(path: Path) -> str:
    return re.sub(r"^\d+[_-]*", "", path.stem).strip()


def extract_infinitive_text(content: str) -> str:
    lines = content.lstrip("\ufeff").splitlines()
    in_first_h2_section = False
    entered_first_h2 = False

    for raw_line in lines:
        line = raw_line.strip().lstrip("\ufeff")
        if not line:
            continue

        if line.startswith("## "):
            if entered_first_h2:
                break
            entered_first_h2 = True
            in_first_h2_section = True
            continue

        if not in_first_h2_section:
            continue

        if not line.startswith("- "):
            continue

        candidate = line[2:].strip()
        candidate = candidate.split("(", 1)[0].strip()
        candidate = candidate.rstrip(".,;:")
        return candidate

    return ""


def synthesize_speech(
    *,
    api_key: str,
    voice_id: str,
    text: str,
    model: str,
    language_code: str,
    output_format: str,
    timeout_seconds: int,
) -> bytes:
    url = (
        "https://api.elevenlabs.io/v1/text-to-speech/"
        f"{urllib.parse.quote(voice_id)}?output_format={urllib.parse.quote(output_format)}"
    )
    payload = {
        "text": text,
        "model_id": model,
    }
    if language_code:
        payload["language_code"] = language_code

    request = urllib.request.Request(
        url=url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Accept": "audio/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": api_key,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=timeout_seconds) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        error_body = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {error.code}: {error_body}") from error
    except urllib.error.URLError as error:
        raise RuntimeError(str(error.reason)) from error


def configure_console_streams() -> None:
    for stream_name in ("stdout", "stderr"):
        stream = getattr(sys, stream_name, None)
        if stream is None or not hasattr(stream, "reconfigure"):
            continue

        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except ValueError:
            continue


if __name__ == "__main__":
    raise SystemExit(main())
