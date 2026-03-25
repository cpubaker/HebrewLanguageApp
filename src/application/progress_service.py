from application.ports import ProgressRepositoryPort


class ProgressService:
    def __init__(self, repository: ProgressRepositoryPort):
        self.repository = repository
        self._pending_words = None

    def save_words(self, words):
        self.repository.save_words(words)
        self._pending_words = None

    def queue_save(self, words):
        self._pending_words = words

    def flush(self):
        if self._pending_words is None:
            return False

        pending_words = self._pending_words
        self._pending_words = None
        self.repository.save_words(pending_words)
        return True
