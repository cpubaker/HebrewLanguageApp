from __future__ import annotations

import argparse
import json
import os
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
class WordAudioJob:
    word_id: str
    text: str
    transcription: str
    output_path: Path


def build_parser() -> argparse.ArgumentParser:
    repo_root = Path(__file__).resolve().parents[1]

    parser = argparse.ArgumentParser(
        description=(
            "Generate word pronunciation audio with the ElevenLabs Text-to-Speech API. "
            "By default, the script reads data/input/hebrew_words.json and writes "
            "matching MP3 files into data/input/audio/words for entries that define audio_file."
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
        "--only-word-id",
        action="append",
        default=[],
        help="Only generate audio for a specific word ID, for example: --only-word-id word_book",
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

    if not jobs:
        return 0

    for job in jobs:
        print(f"- {job.word_id}: {job.text} ({job.transcription}) -> {job.output_path}")

    if args.dry_run:
        return 0

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

    success_count = 0
    error_count = 0
    exhausted_quota = False

    for index, job in enumerate(jobs, start=1):
        print(f"[{index}/{len(jobs)}] Generating {job.output_path.name}")
        try:
            job.output_path.parent.mkdir(parents=True, exist_ok=True)
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
            error_message = str(error)
            print(f"Failed to generate {job.word_id}: {error_message}", file=sys.stderr)
            if "quota_exceeded" in error_message:
                exhausted_quota = True
                print(
                    "Stopping early because ElevenLabs reported quota_exceeded.",
                    file=sys.stderr,
                )
                break

        if args.pause_seconds > 0 and index < len(jobs):
            time.sleep(args.pause_seconds)

    print(f"Finished. Success: {success_count} | Failed: {error_count}")
    if exhausted_quota:
        print(
            "Top up the ElevenLabs quota, then rerun the same command.",
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

        text = str(entry.get("hebrew", "")).strip()
        if not text:
            continue

        output_path = repo_root / "data" / "input" / "audio" / Path(audio_file)
        if output_path.exists() and not force:
            skipped_existing += 1
            continue

        jobs.append(
            WordAudioJob(
                word_id=word_id,
                text=text,
                transcription=str(entry.get("transcription", "")).strip(),
                output_path=output_path,
            )
        )

    return jobs, skipped_existing, skipped_without_audio


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
