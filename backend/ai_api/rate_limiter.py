from __future__ import annotations

import threading
import time
from collections import defaultdict, deque


class RateLimiter:
    def __init__(self, *, max_requests: int, window_seconds: float) -> None:
        self._max_requests = max_requests
        self._window_seconds = window_seconds
        self._hits: defaultdict[str, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()

    @property
    def enabled(self) -> bool:
        return self._max_requests > 0

    def allow(self, client_id: str, *, now: float | None = None) -> bool:
        if not self.enabled:
            return True

        current_time = now if now is not None else time.monotonic()
        cutoff = current_time - self._window_seconds
        with self._lock:
            hits = self._hits[client_id]
            while hits and hits[0] < cutoff:
                hits.popleft()
            if len(hits) >= self._max_requests:
                return False
            hits.append(current_time)
            return True
