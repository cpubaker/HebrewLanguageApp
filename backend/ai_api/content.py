from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Any

MAX_CONTEXT_WORDS = 25
MAX_TEXT_WORDS = 20
MAX_CONTEXTS_PER_WORD = 1
MAX_TEXTS = 3


class RequestValidationError(ValueError):
    pass


def normalize_word_context_request(payload: dict[str, Any]) -> dict[str, Any]:
    words = _normalize_words(payload.get("words"), limit=MAX_CONTEXT_WORDS)
    if not words:
        raise RequestValidationError("words must contain at least one valid word.")

    max_contexts = _bounded_int(
        payload.get("max_contexts_per_word"),
        default=MAX_CONTEXTS_PER_WORD,
        minimum=1,
        maximum=MAX_CONTEXTS_PER_WORD,
    )

    return {
        "prompt_version": _clean_text(
            payload.get("prompt_version"), default="word-contexts-v1", limit=80
        ),
        "target_language": _clean_text(
            payload.get("target_language"), default="uk", limit=12
        ),
        "max_contexts_per_word": max_contexts,
        "words": words,
    }


def normalize_practice_text_request(payload: dict[str, Any]) -> dict[str, Any]:
    words = _normalize_words(payload.get("words"), limit=MAX_TEXT_WORDS)
    if not words:
        raise RequestValidationError("words must contain at least one valid word.")

    return {
        "prompt_version": _clean_text(
            payload.get("prompt_version"), default="practice-texts-v1", limit=80
        ),
        "target_language": _clean_text(
            payload.get("target_language"), default="uk", limit=12
        ),
        "level": _clean_text(payload.get("level"), default="adaptive", limit=40),
        "mode": _clean_text(
            payload.get("mode"), default="reading_practice", limit=60
        ),
        "max_texts": _bounded_int(
            payload.get("max_texts"), default=1, minimum=1, maximum=MAX_TEXTS
        ),
        "words": words,
    }


def cache_key(payload: dict[str, Any]) -> str:
    stable_payload = json.dumps(payload, ensure_ascii=False, sort_keys=True)
    return hashlib.sha256(stable_payload.encode("utf-8")).hexdigest()


def build_context_response(
    request_payload: dict[str, Any],
    generated_payload: dict[str, Any],
    *,
    model: str,
) -> dict[str, Any]:
    word_ids = {word["word_id"] for word in request_payload["words"]}
    created_at = _utc_now()
    contexts: list[dict[str, Any]] = []
    for index, item in enumerate(generated_payload.get("contexts", [])):
        if not isinstance(item, dict):
            continue

        word_id = _clean_text(item.get("word_id"), limit=120)
        hebrew = _clean_text(item.get("hebrew"), limit=220)
        ukrainian = _clean_text(
            item.get("ukrainian") or item.get("translation"), limit=260
        )
        if word_id not in word_ids or not _looks_like_hebrew(hebrew) or not ukrainian:
            continue

        contexts.append(
            {
                "id": _stable_id("ai_ctx", word_id, hebrew, request_payload),
                "word_id": word_id,
                "hebrew": hebrew,
                "ukrainian": ukrainian,
                "source": "ai",
                "is_new": True,
                "created_at": created_at,
                "model": model,
                "prompt_version": request_payload["prompt_version"],
                "index": index,
            }
        )

    return {"contexts": contexts, "model": model}


def build_practice_text_response(
    request_payload: dict[str, Any],
    generated_payload: dict[str, Any],
    *,
    model: str,
) -> dict[str, Any]:
    requested_word_ids = {word["word_id"] for word in request_payload["words"]}
    created_at = _utc_now()
    texts: list[dict[str, Any]] = []
    for index, item in enumerate(generated_payload.get("texts", [])):
        if not isinstance(item, dict):
            continue

        title = _clean_text(item.get("title"), limit=100)
        hebrew = _clean_text(item.get("hebrew"), limit=900)
        ukrainian = _clean_text(
            item.get("ukrainian") or item.get("translation"), limit=1000
        )
        word_ids = [
            word_id
            for word_id in item.get("word_ids", [])
            if isinstance(word_id, str) and word_id in requested_word_ids
        ]
        if not _looks_like_hebrew(hebrew) or not ukrainian:
            continue

        texts.append(
            {
                "id": _stable_id("ai_text", ",".join(word_ids), hebrew, request_payload),
                "title": title or "Текст для практики",
                "hebrew": hebrew,
                "ukrainian": ukrainian,
                "word_ids": word_ids,
                "source": "ai",
                "is_new": True,
                "created_at": created_at,
                "model": model,
                "prompt_version": request_payload["prompt_version"],
                "index": index,
            }
        )

    return {"texts": texts, "model": model}


def _normalize_words(raw_words: Any, *, limit: int) -> list[dict[str, str]]:
    if not isinstance(raw_words, list):
        raise RequestValidationError("words must be a list.")

    words: list[dict[str, str]] = []
    seen_word_ids: set[str] = set()
    for raw_word in raw_words:
        if not isinstance(raw_word, dict):
            continue

        word_id = _clean_text(raw_word.get("word_id"), limit=120)
        hebrew = _clean_text(raw_word.get("hebrew"), limit=120)
        translation = _clean_text(raw_word.get("translation"), limit=160)
        english = _clean_text(raw_word.get("english"), limit=160)
        transcription = _clean_text(raw_word.get("transcription"), limit=120)
        if not word_id or not hebrew or word_id in seen_word_ids:
            continue

        words.append(
            {
                "word_id": word_id,
                "hebrew": hebrew,
                "translation": translation,
                "english": english,
                "transcription": transcription,
            }
        )
        seen_word_ids.add(word_id)
        if len(words) >= limit:
            break

    return words


def _clean_text(value: Any, *, default: str = "", limit: int) -> str:
    if not isinstance(value, str):
        return default

    return " ".join(value.strip().split())[:limit]


def _bounded_int(value: Any, *, default: int, minimum: int, maximum: int) -> int:
    if isinstance(value, bool):
        return default
    if isinstance(value, int):
        return max(minimum, min(maximum, value))
    return default


def _looks_like_hebrew(value: str) -> bool:
    return any("\u0590" <= character <= "\u05ff" for character in value)


def _stable_id(prefix: str, subject: str, text: str, request_payload: dict[str, Any]) -> str:
    digest = hashlib.sha1(
        json.dumps(
            {
                "subject": subject,
                "text": text,
                "prompt_version": request_payload["prompt_version"],
            },
            ensure_ascii=False,
            sort_keys=True,
        ).encode("utf-8")
    ).hexdigest()[:16]
    return f"{prefix}_{digest}"


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

