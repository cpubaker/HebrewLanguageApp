from __future__ import annotations

import argparse
import json
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Callable

from .cache import JsonDiskCache
from .content import (
    RequestValidationError,
    build_context_response,
    build_practice_text_response,
    cache_key,
    normalize_practice_text_request,
    normalize_word_context_request,
)
from .openai_client import DEFAULT_MODEL, OpenAIClientError, OpenAIResponsesClient

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CACHE_PATH = PROJECT_ROOT / ".cache" / "ai_api_cache.json"


class AiApiApplication:
    def __init__(
        self,
        *,
        cache: JsonDiskCache,
        openai_client: OpenAIResponsesClient,
    ) -> None:
        self._cache = cache
        self._openai_client = openai_client

    def handle_word_contexts(self, payload: dict[str, Any]) -> dict[str, Any]:
        request_payload = normalize_word_context_request(payload)
        request_key = cache_key(request_payload)
        cached = self._cache.get("word_contexts", request_key)
        if isinstance(cached, dict):
            return cached

        generated_payload = self._openai_client.generate_word_contexts(
            request_payload
        )
        response_payload = build_context_response(
            request_payload,
            generated_payload,
            model=self._openai_client.model,
        )
        self._cache.set("word_contexts", request_key, response_payload)
        return response_payload

    def handle_practice_texts(self, payload: dict[str, Any]) -> dict[str, Any]:
        request_payload = normalize_practice_text_request(payload)
        request_key = cache_key(request_payload)
        cached = self._cache.get("practice_texts", request_key)
        if isinstance(cached, dict):
            return cached

        generated_payload = self._openai_client.generate_practice_texts(
            request_payload
        )
        response_payload = build_practice_text_response(
            request_payload,
            generated_payload,
            model=self._openai_client.model,
        )
        self._cache.set("practice_texts", request_key, response_payload)
        return response_payload


def create_handler(application: AiApiApplication) -> type[BaseHTTPRequestHandler]:
    class AiApiRequestHandler(BaseHTTPRequestHandler):
        routes: dict[str, Callable[[dict[str, Any]], dict[str, Any]]] = {
            "/ai/word-contexts": application.handle_word_contexts,
            "/ai/practice-texts": application.handle_practice_texts,
        }

        def do_OPTIONS(self) -> None:
            self._send_empty(HTTPStatus.NO_CONTENT)

        def do_GET(self) -> None:
            if self.path == "/health":
                self._send_json({"status": "ok"})
                return

            self._send_error(HTTPStatus.NOT_FOUND, "Unknown endpoint.")

        def do_POST(self) -> None:
            route = self.routes.get(self.path)
            if route is None:
                self._send_error(HTTPStatus.NOT_FOUND, "Unknown endpoint.")
                return

            try:
                payload = self._read_json_body()
                response_payload = route(payload)
            except RequestValidationError as error:
                self._send_error(HTTPStatus.BAD_REQUEST, str(error))
                return
            except OpenAIClientError as error:
                self._send_error(HTTPStatus.BAD_GATEWAY, str(error))
                return
            except ValueError as error:
                self._send_error(HTTPStatus.BAD_REQUEST, str(error))
                return

            self._send_json(response_payload)

        def log_message(self, format: str, *args: Any) -> None:
            if os.getenv("AI_API_QUIET_LOGS") == "1":
                return
            super().log_message(format, *args)

        def _read_json_body(self) -> dict[str, Any]:
            content_length = int(self.headers.get("Content-Length", "0"))
            if content_length <= 0:
                raise ValueError("Request body must be JSON.")
            if content_length > 64 * 1024:
                raise ValueError("Request body is too large.")

            raw_body = self.rfile.read(content_length).decode("utf-8")
            payload = json.loads(raw_body)
            if not isinstance(payload, dict):
                raise ValueError("Request body must be a JSON object.")
            return payload

        def _send_json(
            self,
            payload: dict[str, Any],
            status: HTTPStatus = HTTPStatus.OK,
        ) -> None:
            raw_body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self._send_common_headers()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(raw_body)))
            self.end_headers()
            self.wfile.write(raw_body)

        def _send_empty(self, status: HTTPStatus) -> None:
            self.send_response(status)
            self._send_common_headers()
            self.send_header("Content-Length", "0")
            self.end_headers()

        def _send_error(self, status: HTTPStatus, message: str) -> None:
            self._send_json({"error": message}, status=status)

        def _send_common_headers(self) -> None:
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.send_header("Cache-Control", "no-store")

    return AiApiRequestHandler


def build_application(
    *,
    cache_path: Path | None = None,
    model: str | None = None,
) -> AiApiApplication:
    return AiApiApplication(
        cache=JsonDiskCache(cache_path or DEFAULT_CACHE_PATH),
        openai_client=OpenAIResponsesClient(model=model or DEFAULT_MODEL),
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run the Hebrew learning AI content API."
    )
    parser.add_argument("--host", default=os.getenv("AI_API_HOST", "127.0.0.1"))
    parser.add_argument(
        "--port", type=int, default=int(os.getenv("AI_API_PORT", "8787"))
    )
    parser.add_argument(
        "--cache-path",
        type=Path,
        default=Path(os.getenv("AI_API_CACHE_PATH", DEFAULT_CACHE_PATH)),
    )
    parser.add_argument("--model", default=os.getenv("OPENAI_MODEL", DEFAULT_MODEL))
    args = parser.parse_args()

    application = build_application(cache_path=args.cache_path, model=args.model)
    handler = create_handler(application)
    server = ThreadingHTTPServer((args.host, args.port), handler)
    print(f"AI API listening on http://{args.host}:{args.port}")
    print(f"Cache: {args.cache_path}")
    print(f"Model: {args.model}")
    server.serve_forever()


if __name__ == "__main__":
    main()

