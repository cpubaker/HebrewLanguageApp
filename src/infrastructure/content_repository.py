import json
import os
import re

from domain.errors import MissingDataPathError
from domain.models import ContextSentence, GuideSection, ReadingSection, VerbLesson, Word
from reading_levels import READING_LEVELS


class ContentRepository:
    def __init__(self, paths):
        self.paths = paths

    def load_words(self):
        if not os.path.exists(self.paths.words_file):
            raise MissingDataPathError(
                self.paths.words_file,
                resource_label="words file",
            )

        with open(self.paths.words_file, "r", encoding="utf-8") as file:
            words = [Word.from_dict(word) for word in json.load(file)]

        for word in words:
            word.normalize_loading_fields()
            word.set_word_id(self._build_word_id(word))

        contexts_by_word_id = self.load_word_contexts(words)
        for word in words:
            word.set_contexts(contexts_by_word_id.get(word.word_id, []))

        return words

    def load_guide_sections(self):
        return self._load_structured_text_sections(
            self.paths.guide_dir,
            resource_label="guide folder",
            section_factory=lambda title, body, filename: GuideSection.from_values(
                title=title,
                body=body,
                filename=filename,
            ),
        )

    def load_verbs(self):
        if not os.path.exists(self.paths.verbs_dir):
            raise MissingDataPathError(
                self.paths.verbs_dir,
                resource_label="verbs folder",
            )

        sections = []

        for filename in sorted(os.listdir(self.paths.verbs_dir)):
            if not self._is_text_section_file(filename):
                continue

            file_path = os.path.join(self.paths.verbs_dir, filename)
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read().strip()

            if not content:
                continue

            title, body = self._split_markdown_section(content)
            if not title:
                continue

            sections.append(
                VerbLesson.from_values(
                    title=title,
                    body=body,
                    filename=filename,
                    image_path=self._find_verb_image_path(filename),
                    audio_path=self._find_verb_audio_path(filename),
                )
            )

        return sections

    def load_reading_sections(self):
        if not os.path.exists(self.paths.reading_dir):
            raise MissingDataPathError(
                self.paths.reading_dir,
                resource_label="reading folder",
            )

        sections = []

        for level in READING_LEVELS:
            level_dir = os.path.join(self.paths.reading_dir, level)
            if not os.path.isdir(level_dir):
                continue

            sections.extend(self._load_reading_sections_from_directory(level_dir, level))

        return sections

    def load_word_contexts(self, words):
        contexts_file = getattr(self.paths, "context_sentences_file", "")
        links_file = getattr(self.paths, "word_context_links_file", "")
        if not contexts_file or not links_file:
            return {}

        if not os.path.exists(contexts_file) or not os.path.exists(links_file):
            return {}

        with open(contexts_file, "r", encoding="utf-8") as file:
            contexts = json.load(file)

        with open(links_file, "r", encoding="utf-8") as file:
            word_context_links = json.load(file)

        contexts_by_id = {}
        for context in contexts:
            resolved_context = ContextSentence.from_dict(context)
            if resolved_context.context_id:
                contexts_by_id[resolved_context.context_id] = resolved_context

        resolved_contexts = {}
        for word in words:
            word_id = word.get("_word_id") or self._build_word_id(word)
            context_ids = word_context_links.get(word_id, [])
            resolved_contexts[word_id] = [
                contexts_by_id[context_id]
                for context_id in context_ids
                if context_id in contexts_by_id
            ]

        return resolved_contexts

    def load_text_sections(self, directory, *, resource_label):
        sections = self._load_structured_text_sections(
            directory,
            resource_label=resource_label,
            section_factory=lambda title, body, _filename: GuideSection.from_values(
                title=title,
                body=body,
            ),
        )
        return {section["title"]: section["body"] for section in sections}

    def _load_structured_text_sections(self, directory, *, resource_label, section_factory):
        if not os.path.exists(directory):
            raise MissingDataPathError(directory, resource_label=resource_label)

        sections = []

        for filename in sorted(os.listdir(directory)):
            if not self._is_text_section_file(filename):
                continue

            file_path = os.path.join(directory, filename)
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read().strip()

            if not content:
                continue

            title, body = self._split_markdown_section(content)

            if title:
                sections.append(section_factory(title, body, filename))

        return sections

    def _load_reading_sections_from_directory(self, directory, level):
        sections = []

        for filename in sorted(os.listdir(directory)):
            if not self._is_text_section_file(filename):
                continue

            file_path = os.path.join(directory, filename)
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read().strip()

            if not content:
                continue

            title, body = self._split_markdown_section(content)
            if not title:
                continue

            sections.append(
                ReadingSection.from_values(
                    title=title,
                    body=body,
                    level=level,
                    filename=filename,
                )
            )

        return sections

    def _find_verb_image_path(self, filename):
        images_dir = getattr(self.paths, "verbs_images_dir", "")
        if not images_dir:
            return None

        lesson_name = self._get_lesson_asset_name(filename)
        if not lesson_name:
            return None

        image_path = os.path.join(images_dir, f"{lesson_name}.png")
        if os.path.exists(image_path):
            return image_path

        return None

    def _find_verb_audio_path(self, filename):
        audio_dir = getattr(self.paths, "verbs_audio_dir", "")
        if not audio_dir:
            return None

        lesson_name = self._get_lesson_asset_name(filename)
        if not lesson_name:
            return None

        audio_path = os.path.join(audio_dir, f"{lesson_name}.mp3")
        if os.path.exists(audio_path):
            return audio_path

        return None

    def _get_lesson_asset_name(self, filename):
        lesson_stem = os.path.splitext(filename)[0]
        return re.sub(r"^\d+[_-]*", "", lesson_stem).strip() or None

    def _build_word_id(self, word):
        for field_name in ("id", "english", "transcription", "hebrew"):
            raw_value = str(word.get(field_name, "")).strip().lower()
            if not raw_value:
                continue

            normalized = re.sub(r"[^a-z0-9]+", "_", raw_value).strip("_")
            if normalized:
                return f"word_{normalized}"

        return "word_unknown"

    def _is_text_section_file(self, filename):
        if not filename.endswith((".md", ".txt")):
            return False

        lesson_stem = os.path.splitext(os.path.basename(filename))[0]
        return bool(re.match(r"^\d+", lesson_stem))

    def _split_markdown_section(self, content):
        lines = content.lstrip("\ufeff").splitlines()

        for index, line in enumerate(lines):
            stripped_line = line.strip().lstrip("\ufeff")
            if not stripped_line:
                continue

            heading_match = re.match(r"^#{1,6}\s+(.*)$", stripped_line)
            if heading_match:
                title = heading_match.group(1).strip()
                body = "\n".join(lines[index + 1 :]).strip()
                return title, body

            title = stripped_line
            body = "\n".join(lines[index + 1 :]).strip()
            return title, body

        return "", ""
