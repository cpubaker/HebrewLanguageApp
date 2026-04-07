import json
import os
import tempfile

from domain.models import Word


class ProgressRepository:
    PROGRESS_FIELDS = (
        "correct",
        "wrong",
        "last_correct",
        "writing_correct",
        "writing_wrong",
        "writing_last_correct",
    )
    TRANSIENT_WORD_FIELDS = {"_word_id", "_contexts"}

    def __init__(self, paths):
        self.paths = paths

    def save_words(self, words):
        serialized_progress = {}
        for word in words:
            source_word = self._serialize_word(word)
            word_id = str(source_word.get("word_id", "")).strip()
            if not word_id:
                continue

            progress_payload = self._build_progress_payload(source_word)
            if progress_payload:
                serialized_progress[word_id] = progress_payload

        target_path = self._progress_file_path()
        target_dir = os.path.dirname(target_path) or "."
        os.makedirs(target_dir, exist_ok=True)
        file_descriptor, temp_path = tempfile.mkstemp(
            dir=target_dir,
            prefix="hebrew_words_",
            suffix=".tmp",
        )

        try:
            with os.fdopen(file_descriptor, "w", encoding="utf-8") as file:
                json.dump(serialized_progress, file, ensure_ascii=False, indent=4)
                file.flush()
                os.fsync(file.fileno())

            os.replace(temp_path, target_path)
        except Exception:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            raise

    def _serialize_word(self, word):
        if isinstance(word, Word):
            return word.to_dict(strip_transient=True)

        return {
            key: value
            for key, value in word.items()
            if key not in self.TRANSIENT_WORD_FIELDS
        }

    def _progress_file_path(self):
        configured_path = getattr(self.paths, "word_progress_file", "")
        if configured_path:
            return configured_path

        words_file = getattr(self.paths, "words_file", "")
        base_dir = os.path.dirname(words_file) or "."
        return os.path.join(base_dir, "word_progress.json")

    def _build_progress_payload(self, word):
        payload = {}

        correct = self._read_non_negative_int(word.get("correct"))
        wrong = self._read_non_negative_int(word.get("wrong"))
        last_correct = self._read_optional_timestamp(word.get("last_correct"))
        writing_correct = self._read_non_negative_int(word.get("writing_correct"))
        writing_wrong = self._read_non_negative_int(word.get("writing_wrong"))
        writing_last_correct = self._read_optional_timestamp(
            word.get("writing_last_correct")
        )

        if correct > 0:
            payload["correct"] = correct
        if wrong > 0:
            payload["wrong"] = wrong
        if last_correct:
            payload["last_correct"] = last_correct
        if writing_correct > 0:
            payload["writing_correct"] = writing_correct
        if writing_wrong > 0:
            payload["writing_wrong"] = writing_wrong
        if writing_last_correct:
            payload["writing_last_correct"] = writing_last_correct

        return payload

    def _read_non_negative_int(self, value):
        if isinstance(value, bool):
            return 0
        if isinstance(value, (int, float)):
            normalized = int(value)
            return normalized if normalized >= 0 else 0
        if isinstance(value, str):
            try:
                normalized = int(value.strip())
            except ValueError:
                return 0
            return normalized if normalized >= 0 else 0
        return 0

    def _read_optional_timestamp(self, value):
        if not isinstance(value, str):
            return None

        normalized = value.strip()
        return normalized or None
