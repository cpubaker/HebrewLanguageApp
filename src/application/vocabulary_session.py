import random
from datetime import datetime

from domain.models import normalize_words_collection


class VocabularySession:
    def __init__(self, words, rng=None):
        self.words = normalize_words_collection(words)
        self.rng = rng or random.Random()
        self.current_word = None
        self.current_options = []
        self.answered = False

    def next_prompt(self):
        if not self.words:
            self.current_word = None
            self.current_options = []
            self.answered = False
            return None

        self.current_word = self.rng.choice(self.words)
        correct_translation = self.current_word["english"]
        options = [correct_translation]

        other_words = [word for word in self.words if word is not self.current_word]
        if other_words:
            wrong_translation = self.rng.choice(other_words)["english"]
            options.append(wrong_translation)
            self.rng.shuffle(options)

        self.current_options = options
        self.answered = False

        return {
            "word": self.current_word,
            "options": list(self.current_options),
        }

    def submit_answer(self, selected_translation):
        if self.answered or not self.current_word:
            return None

        self.answered = True
        correct_translation = self.current_word["english"]
        is_correct = selected_translation == correct_translation

        if is_correct:
            self.current_word.register_correct(now=datetime.now())
        else:
            self.current_word.register_wrong()

        return {
            "is_correct": is_correct,
            "selected_translation": selected_translation,
            "correct_translation": correct_translation,
            "word": self.current_word,
        }

    def current_score(self):
        if not self.current_word:
            return {"correct": 0, "wrong": 0, "total": 0}

        return self.current_word.vocabulary_score()
