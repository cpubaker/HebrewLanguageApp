from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from typing import Any


DEFAULT_MODEL = "gpt-5-nano"
OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"


class OpenAIClientError(RuntimeError):
    pass


class OpenAIResponsesClient:
    def __init__(
        self,
        *,
        api_key: str | None = None,
        model: str | None = None,
        timeout_seconds: float = 30,
    ) -> None:
        self._api_key = api_key if api_key is not None else os.getenv("OPENAI_API_KEY", "")
        self.model = model or os.getenv("OPENAI_MODEL", DEFAULT_MODEL)
        self._timeout_seconds = timeout_seconds

    def generate_word_contexts(self, request_payload: dict[str, Any]) -> dict[str, Any]:
        return self._create_structured_response(
            instructions=_word_context_instructions(request_payload),
            user_payload=request_payload,
            schema_name="word_contexts",
            schema=_word_context_schema(),
            max_output_tokens=1400,
        )

    def generate_practice_texts(self, request_payload: dict[str, Any]) -> dict[str, Any]:
        return self._create_structured_response(
            instructions=_practice_text_instructions(request_payload),
            user_payload=request_payload,
            schema_name="practice_texts",
            schema=_practice_text_schema(),
            max_output_tokens=2200,
        )

    def _create_structured_response(
        self,
        *,
        instructions: str,
        user_payload: dict[str, Any],
        schema_name: str,
        schema: dict[str, Any],
        max_output_tokens: int,
    ) -> dict[str, Any]:
        if not self._api_key:
            raise OpenAIClientError("OPENAI_API_KEY is not set.")

        payload = {
            "model": self.model,
            "instructions": instructions,
            "input": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "input_text",
                            "text": json.dumps(user_payload, ensure_ascii=False),
                        }
                    ],
                }
            ],
            "text": {
                "format": {
                    "type": "json_schema",
                    "name": schema_name,
                    "strict": True,
                    "schema": schema,
                },
                "verbosity": "low",
            },
            "max_output_tokens": max_output_tokens,
            "store": False,
        }
        request = urllib.request.Request(
            OPENAI_RESPONSES_URL,
            data=json.dumps(payload).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {self._api_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )

        try:
            with urllib.request.urlopen(
                request, timeout=self._timeout_seconds
            ) as response:
                raw_body = response.read().decode("utf-8")
        except urllib.error.HTTPError as error:
            error_body = error.read().decode("utf-8", errors="replace")
            raise OpenAIClientError(
                f"OpenAI API returned {error.code}: {error_body}"
            ) from error
        except urllib.error.URLError as error:
            raise OpenAIClientError(f"OpenAI API request failed: {error}") from error

        try:
            response_payload = json.loads(raw_body)
            output_text = _extract_output_text(response_payload)
            structured_payload = json.loads(output_text)
        except (KeyError, TypeError, json.JSONDecodeError) as error:
            raise OpenAIClientError("OpenAI API returned an invalid response.") from error

        if not isinstance(structured_payload, dict):
            raise OpenAIClientError("OpenAI API returned a non-object JSON response.")

        return structured_payload


def _extract_output_text(response_payload: dict[str, Any]) -> str:
    output_text = response_payload.get("output_text")
    if isinstance(output_text, str) and output_text.strip():
        return output_text

    for output_item in response_payload.get("output", []):
        if not isinstance(output_item, dict):
            continue
        for content_item in output_item.get("content", []):
            if (
                isinstance(content_item, dict)
                and content_item.get("type") == "output_text"
                and isinstance(content_item.get("text"), str)
            ):
                return content_item["text"]

    raise KeyError("output_text")


def _word_context_instructions(request_payload: dict[str, Any]) -> str:
    max_contexts = request_payload["max_contexts_per_word"]
    return (
        "You generate short, natural Hebrew example sentences for a Ukrainian "
        "speaker learning Hebrew. For each supplied word, create exactly "
        f"{max_contexts} sentence. Keep Hebrew simple, modern, and grammatically "
        "correct. Use the target word naturally. Return Ukrainian translations. "
        "Do not explain anything outside the JSON schema."
    )


def _practice_text_instructions(request_payload: dict[str, Any]) -> str:
    max_texts = request_payload["max_texts"]
    return (
        "You generate short Hebrew reading-practice texts for a Ukrainian "
        "speaker learning Hebrew. Use several supplied words naturally and keep "
        "the Hebrew appropriate for the requested level. Return Ukrainian "
        f"translations. Create exactly {max_texts} text item(s). Do not explain "
        "anything outside the JSON schema."
    )


def _word_context_schema() -> dict[str, Any]:
    return {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "contexts": {
                "type": "array",
                "items": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "word_id": {"type": "string"},
                        "hebrew": {"type": "string"},
                        "ukrainian": {"type": "string"},
                    },
                    "required": ["word_id", "hebrew", "ukrainian"],
                },
            }
        },
        "required": ["contexts"],
    }


def _practice_text_schema() -> dict[str, Any]:
    return {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "texts": {
                "type": "array",
                "items": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "title": {"type": "string"},
                        "hebrew": {"type": "string"},
                        "ukrainian": {"type": "string"},
                        "word_ids": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                    },
                    "required": ["title", "hebrew", "ukrainian", "word_ids"],
                },
            }
        },
        "required": ["texts"],
    }

