import random
import unicodedata
from datetime import datetime


class WritingSession:
    def __init__(self, words, rng=None):
        self.words = words
        self.rng = rng or random.Random()
        self.current_word = None
        self.answered = False

    def next_prompt(self):
        if not self.words:
            self.current_word = None
            self.answered = False
            return None

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = self.rng.choice(candidates)
        self.answered = False

        prompt = self.current_word.get("ukrainian") or self.current_word.get(
            "english", ""
        )
        return {
            "word": self.current_word,
            "prompt": prompt,
        }

    def submit_answer(self, user_answer):
        if self.answered or not self.current_word:
            return None

        normalized_answer = self._normalize_hebrew(user_answer)
        correct_answer = self._normalize_hebrew(self.current_word.get("hebrew", ""))

        if not normalized_answer:
            return {
                "status": "empty",
                "word": self.current_word,
            }

        self.answered = True
        is_correct = normalized_answer == correct_answer

        if is_correct:
            if hasattr(self.current_word, "register_writing_correct"):
                self.current_word.register_writing_correct(now=datetime.now())
            else:
                self.current_word["writing_correct"] = (
                    self.current_word.get("writing_correct", 0) + 1
                )
                self.current_word["writing_last_correct"] = datetime.now().isoformat(
                    timespec="seconds"
                )
        else:
            if hasattr(self.current_word, "register_writing_wrong"):
                self.current_word.register_writing_wrong()
            else:
                self.current_word["writing_wrong"] = (
                    self.current_word.get("writing_wrong", 0) + 1
                )

        return {
            "status": "submitted",
            "is_correct": is_correct,
            "word": self.current_word,
            "correct_answer": self.current_word.get("hebrew", ""),
        }

    def current_stats(self):
        if not self.current_word:
            return {"correct": 0, "wrong": 0, "total": 0, "last_correct": False}

        if hasattr(self.current_word, "writing_score"):
            return self.current_word.writing_score()

        correct = self.current_word.get("writing_correct", 0)
        wrong = self.current_word.get("writing_wrong", 0)
        return {
            "correct": correct,
            "wrong": wrong,
            "total": correct + wrong,
            "last_correct": self.current_word.get("writing_last_correct", False),
        }

    def _normalize_hebrew(self, text):
        normalized = unicodedata.normalize("NFC", text or "")
        return " ".join(normalized.strip().split())
