from __future__ import annotations

import argparse
import json
import os
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from openai import OpenAI


DEFAULT_MODEL = "tts-1"
DEFAULT_VOICE = "alloy"
DEFAULT_TIMEOUT_SECONDS = 120


@dataclass(frozen=True)
class WordAudioJob:
    word_id: str
    hebrew: str
    transcription: str
    output_path: Path


def build_parser() -> argparse.ArgumentParser:
    repo_root = Path(__file__).resolve().parents[1]

    parser = argparse.ArgumentParser(
        description=(
            "Generate Hebrew word pronunciation audio with the OpenAI Text-to-Speech API. "
            "By default, the script reads data/input/hebrew_words.json and generates "
            "MP3 files for entries that define audio_file."
        )
    )
    parser.add_argument(
        "--words-file",
        type=Path,
        default=repo_root / "data" / "input" / "hebrew_words.json",
        help="Path to the shared vocabulary JSON file.",
    )
    parser.add_argument(
        "--api-key",
        default=os.environ.get("OPENAI_API_KEY", ""),
        help="OpenAI API key. Defaults to OPENAI_API_KEY.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"OpenAI speech model. Defaults to {DEFAULT_MODEL}.",
    )
    parser.add_argument(
        "--voice",
        default=DEFAULT_VOICE,
        help=f"OpenAI voice. Defaults to {DEFAULT_VOICE}.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Optional max number of files to generate in this run.",
    )
    parser.add_argument(
        "--only-word-id",
        action="append",
        default=[],
        help="Only generate audio for a specific word_id, for example: --only-word-id word_man",
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
        help=f"Request timeout in seconds. Defaults to {DEFAULT_TIMEOUT_SECONDS}.",
    )
    return parser


def main() -> int:
    configure_console_streams()

    parser = build_parser()
    args = parser.parse_args()

    words_file = args.words_file.resolve()
    if not words_file.exists():
        print(f"Words file not found: {words_file}", file=sys.stderr)
        return 1

    only_word_ids = {
        word_id.strip().lower()
        for word_id in args.only_word_id
        if word_id.strip()
    }

    jobs, skipped_existing, skipped_without_audio = collect_jobs(
        words_file=words_file,
        only_word_ids=only_word_ids,
        force=args.force,
    )

    if args.limit and args.limit > 0:
        jobs = jobs[: args.limit]

    print(
        "Planned word audio jobs: "
        f"{len(jobs)} | skipped existing: {skipped_existing} | "
        f"without audio_file: {skipped_without_audio}"
    )

    for job in jobs:
        print(f"- {job.word_id}: {job.hebrew} ({job.transcription}) -> {job.output_path}")

    if not jobs:
        return 0

    if args.dry_run:
        return 0

    if not args.api_key:
        print(
            "Missing OpenAI API key. Set OPENAI_API_KEY or pass --api-key.",
            file=sys.stderr,
        )
        return 1

    client = OpenAI(api_key=args.api_key, timeout=args.timeout_seconds)

    success_count = 0
    error_count = 0
    exhausted_quota = False

    for index, job in enumerate(jobs, start=1):
        print(f"[{index}/{len(jobs)}] Generating {job.output_path.name}")
        try:
            job.output_path.parent.mkdir(parents=True, exist_ok=True)
            response = client.audio.speech.create(
                model=args.model,
                voice=args.voice,
                input=job.hebrew,
                response_format="mp3",
            )
            response.write_to_file(job.output_path)
            success_count += 1
        except Exception as error:  # noqa: BLE001
            error_count += 1
            error_message = str(error)
            print(f"Failed to generate {job.word_id}: {error_message}", file=sys.stderr)
            if "insufficient_quota" in error_message:
                exhausted_quota = True
                print(
                    "Stopping early because the API reported insufficient quota.",
                    file=sys.stderr,
                )
                break

        if args.pause_seconds > 0 and index < len(jobs):
            time.sleep(args.pause_seconds)

    print(f"Finished. Success: {success_count} | Failed: {error_count}")
    if exhausted_quota:
        print(
            "Top up the API quota or switch to another provider, then rerun the script.",
            file=sys.stderr,
        )
    return 0 if error_count == 0 else 1


def collect_jobs(
    *,
    words_file: Path,
    only_word_ids: set[str],
    force: bool,
) -> tuple[list[WordAudioJob], int, int]:
    words = json.loads(words_file.read_text(encoding="utf-8"))

    jobs: list[WordAudioJob] = []
    skipped_existing = 0
    skipped_without_audio = 0
    repo_root = words_file.parents[2]

    for entry in words:
        if not isinstance(entry, dict):
            continue

        word_id = str(entry.get("word_id", "")).strip()
        if not word_id:
            continue

        if only_word_ids and word_id.lower() not in only_word_ids:
            continue

        audio_file = str(entry.get("audio_file", "")).strip()
        if not audio_file:
            skipped_without_audio += 1
            continue

        hebrew = str(entry.get("hebrew", "")).strip()
        if not hebrew:
            continue

        output_path = repo_root / "data" / "input" / "audio" / Path(audio_file)
        if output_path.exists() and not force:
            skipped_existing += 1
            continue

        jobs.append(
            WordAudioJob(
                word_id=word_id,
                hebrew=hebrew,
                transcription=str(entry.get("transcription", "")).strip(),
                output_path=output_path,
            )
        )

    return jobs, skipped_existing, skipped_without_audio


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
