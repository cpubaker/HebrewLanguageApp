from datetime import date

from domain.models import normalize_words_collection


class WordOfDayService:
    def __init__(self, words):
        self.words = normalize_words_collection(words)

    def get_word_of_day(self, target_date=None):
        if not self.words:
            return None

        target_date = target_date or date.today()
        pool = self._words_with_contexts() or self.words
        day_index = target_date.toordinal()

        word = pool[day_index % len(pool)]
        context = self._select_context(word, day_index)

        return {
            "word": word,
            "context": context,
        }

    def _words_with_contexts(self):
        return [word for word in self.words if word.contexts]

    def _select_context(self, word, day_index):
        contexts = word.contexts
        if not contexts:
            return None
        return contexts[day_index % len(contexts)]
