from infrastructure.content_repository import ContentRepository
from infrastructure.progress_repository import ProgressRepository


class HebrewDataService:
    def __init__(self, paths):
        self.paths = paths
        self.content = ContentRepository(paths)
        self.progress = ProgressRepository(paths)

    def load_words(self):
        return self.content.load_words()

    def load_guide_sections(self):
        return self.content.load_guide_sections()

    def load_verbs(self):
        return self.content.load_verbs()

    def load_reading_sections(self):
        return self.content.load_reading_sections()

    def save_words(self, words):
        self.progress.save_words(words)

    def load_word_contexts(self, words):
        return self.content.load_word_contexts(words)

    def load_text_sections(self, directory, *, resource_label):
        return self.content.load_text_sections(directory, resource_label=resource_label)

    def _find_verb_image_path(self, filename):
        return self.content._find_verb_image_path(filename)

    def _find_verb_audio_path(self, filename):
        return self.content._find_verb_audio_path(filename)

    def _get_lesson_asset_name(self, filename):
        return self.content._get_lesson_asset_name(filename)

    def _build_word_id(self, word):
        return self.content._build_word_id(word)

    def _is_text_section_file(self, filename):
        return self.content._is_text_section_file(filename)

    def _split_markdown_section(self, content):
        return self.content._split_markdown_section(content)
