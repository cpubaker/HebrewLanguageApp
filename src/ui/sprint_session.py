import random
from datetime import datetime


class SprintSession:
    def __init__(self, words, rng=None):
        self.words = words
        self.rng = rng or random.Random()
        self.current_word = None
        self.current_options = []
        self.correct_count = 0
        self.wrong_count = 0
        self.last_result = None

    def can_start(self):
        unique_translations = {
            str(word.get("english", "")).strip()
            for word in self.words
            if str(word.get("english", "")).strip()
        }
        return len(self.words) >= 2 and len(unique_translations) >= 2

    def next_prompt(self):
        if not self.can_start():
            self.current_word = None
            self.current_options = []
            return None

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = self.rng.choice(candidates)
        correct_translation = self.current_word["english"]
        distractors = [
            word["english"]
            for word in self.words
            if word is not self.current_word and word.get("english") != correct_translation
        ]

        if not distractors:
            self.current_word = None
            self.current_options = []
            return None

        options = [correct_translation, self.rng.choice(distractors)]
        self.rng.shuffle(options)
        self.current_options = options

        return {
            "word": self.current_word,
            "options": list(self.current_options),
        }

    def submit_answer(self, selected_translation):
        if not self.current_word:
            return None

        correct_translation = self.current_word["english"]
        is_correct = selected_translation == correct_translation

        if is_correct:
            self.correct_count += 1
            self.current_word["correct"] = self.current_word.get("correct", 0) + 1
            self.current_word["last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
        else:
            self.wrong_count += 1
            self.current_word["wrong"] = self.current_word.get("wrong", 0) + 1

        self.last_result = {
            "is_correct": is_correct,
            "selected_translation": selected_translation,
            "correct_translation": correct_translation,
            "word": self.current_word,
        }
        return self.last_result

    @property
    def attempts(self):
        return self.correct_count + self.wrong_count
