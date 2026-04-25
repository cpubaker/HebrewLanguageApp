from __future__ import annotations

import json
import threading
from pathlib import Path
from typing import Any


class JsonDiskCache:
    def __init__(self, path: Path) -> None:
        self._path = path
        self._lock = threading.Lock()

    def get(self, namespace: str, key: str) -> Any | None:
        with self._lock:
            payload = self._load()
            return payload.get(namespace, {}).get(key)

    def set(self, namespace: str, key: str, value: Any) -> None:
        with self._lock:
            payload = self._load()
            namespace_payload = payload.setdefault(namespace, {})
            namespace_payload[key] = value
            self._save(payload)

    def _load(self) -> dict[str, Any]:
        if not self._path.exists():
            return {}

        try:
            with self._path.open("r", encoding="utf-8") as file:
                payload = json.load(file)
        except (OSError, json.JSONDecodeError):
            return {}

        return payload if isinstance(payload, dict) else {}

    def _save(self, payload: dict[str, Any]) -> None:
        self._path.parent.mkdir(parents=True, exist_ok=True)
        temp_path = self._path.with_suffix(f"{self._path.suffix}.tmp")
        with temp_path.open("w", encoding="utf-8") as file:
            json.dump(payload, file, ensure_ascii=False, indent=2, sort_keys=True)
        temp_path.replace(self._path)

