from dataclasses import dataclass

from application.ports import ContentRepositoryPort


@dataclass(frozen=True)
class AppContent:
    words: list
    guide_sections: list
    verbs: list
    reading_sections: list


class AppContentLoader:
    def __init__(self, repository: ContentRepositoryPort):
        self.repository = repository

    def load(self):
        return AppContent(
            words=self.repository.load_words(),
            guide_sections=self.repository.load_guide_sections(),
            verbs=self.repository.load_verbs(),
            reading_sections=self.repository.load_reading_sections(),
        )
