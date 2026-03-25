import json
import os
import tempfile

from domain.models import Word


class ProgressRepository:
    TRANSIENT_WORD_FIELDS = {"_word_id", "_contexts"}

    def __init__(self, paths):
        self.paths = paths

    def save_words(self, words):
        sanitized_words = []
        for word in words:
            if isinstance(word, Word):
                sanitized_words.append(word.to_dict(strip_transient=True))
                continue

            sanitized_words.append(
                {
                    key: value
                    for key, value in word.items()
                    if key not in self.TRANSIENT_WORD_FIELDS
                }
            )

        target_dir = os.path.dirname(self.paths.words_file) or "."
        file_descriptor, temp_path = tempfile.mkstemp(
            dir=target_dir,
            prefix="hebrew_words_",
            suffix=".tmp",
        )

        try:
            with os.fdopen(file_descriptor, "w", encoding="utf-8") as file:
                json.dump(sanitized_words, file, ensure_ascii=False, indent=4)
                file.flush()
                os.fsync(file.fileno())

            os.replace(temp_path, self.paths.words_file)
        except Exception:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            raise
