import json

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

        with open(self.paths.words_file, "w", encoding="utf-8") as file:
            json.dump(sanitized_words, file, ensure_ascii=False, indent=4)
