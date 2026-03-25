import random
from datetime import datetime

from domain.models import normalize_words_collection


class FlashcardSession:
    def __init__(self, words, rng=None):
        self.words = normalize_words_collection(words)
        self.rng = rng or random.Random()
        self.current_word = None
        self.current_context = None
        self.last_answer_known = None
        self.last_context_ids = {}

    def next_card(self):
        if not self.words:
            self.current_word = None
            self.current_context = None
            self.last_answer_known = None
            return None

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = self.rng.choice(candidates)
        self.current_context = self._select_context(self.current_word)
        self.last_answer_known = None

        return {
            "word": self.current_word,
            "context": self.current_context,
        }

    def answer_card(self, known):
        if not self.current_word:
            return None

        if known:
            self.current_word.register_correct(now=datetime.now())
        else:
            self.current_word.register_wrong()

        self.last_answer_known = known
        return {
            "known": known,
            "word": self.current_word,
            "context": self.current_context,
        }

    def current_stats(self):
        if not self.current_word:
            return {"correct": 0, "wrong": 0, "last_correct": False}

        score = self.current_word.vocabulary_score()
        score["last_correct"] = self.current_word.get("last_correct", False)
        return score

    def _select_context(self, word):
        contexts = word.get("_contexts", [])
        if not contexts:
            return None

        if len(contexts) == 1:
            context = contexts[0]
        else:
            previous_context_id = self.last_context_ids.get(word.get("_word_id"))
            candidates = [
                context
                for context in contexts
                if context.get("id") != previous_context_id
            ]
            context = self.rng.choice(candidates or contexts)

        context_id = context.get("id")
        if context_id:
            self.last_context_ids[word.get("_word_id")] = context_id

        return context
