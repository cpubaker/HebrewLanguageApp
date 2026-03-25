from application.ports import ProgressRepositoryPort


class ProgressService:
    def __init__(self, repository: ProgressRepositoryPort):
        self.repository = repository

    def save_words(self, words):
        self.repository.save_words(words)
