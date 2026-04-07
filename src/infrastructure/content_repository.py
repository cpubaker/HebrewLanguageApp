import json
import os
import re
from collections import Counter

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

        self._assign_word_ids(words)
        for word in words:
            word.normalize_loading_fields()

        progress_by_word_id = self._load_word_progress()
        for word in words:
            self._apply_progress_snapshot(word, progress_by_word_id.get(word.word_id))

        contexts_by_word_id = self.load_word_contexts(words)
        for word in words:
            word.set_contexts(contexts_by_word_id.get(word.word_id, []))

        return words

    def _load_word_progress(self):
        progress_file = self._word_progress_file()
        if not progress_file or not os.path.exists(progress_file):
            return {}

        with open(progress_file, "r", encoding="utf-8") as file:
            loaded_progress = json.load(file)

        if not isinstance(loaded_progress, dict):
            return {}

        progress_by_word_id = {}
        for raw_word_id, raw_payload in loaded_progress.items():
            word_id = str(raw_word_id).strip()
            if not word_id or not isinstance(raw_payload, dict):
                continue

            progress_by_word_id[word_id] = raw_payload

        return progress_by_word_id

    def _apply_progress_snapshot(self, word, snapshot):
        if not snapshot:
            return

        for field_name in (
            "correct",
            "wrong",
            "last_correct",
            "writing_correct",
            "writing_wrong",
            "writing_last_correct",
        ):
            if field_name in snapshot:
                word[field_name] = snapshot[field_name]

        word.normalize_loading_fields()

    def _word_progress_file(self):
        configured_path = getattr(self.paths, "word_progress_file", "")
        if configured_path:
            return configured_path

        words_file = getattr(self.paths, "words_file", "")
        base_dir = os.path.dirname(words_file) or "."
        return os.path.join(base_dir, "word_progress.json")

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

        for filename in self._sorted_directory_filenames(self.paths.verbs_dir):
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
            word_id = word.word_id or self._build_word_id(word)
            context_ids = word_context_links.get(word_id, [])
            resolved_contexts[word_id] = [
                contexts_by_id[context_id]
                for context_id in context_ids
                if context_id in contexts_by_id
            ]

        return resolved_contexts

    def load_text_sections(self, directory, *, resource_label):
        return self._load_structured_text_sections(
            directory,
            resource_label=resource_label,
            section_factory=lambda title, body, filename: GuideSection.from_values(
                title=title,
                body=body,
                filename=filename,
            ),
        )

    def _load_structured_text_sections(self, directory, *, resource_label, section_factory):
        if not os.path.exists(directory):
            raise MissingDataPathError(directory, resource_label=resource_label)

        sections = []

        for filename in self._sorted_directory_filenames(directory):
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

        for filename in self._sorted_directory_filenames(directory):
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

    def _assign_word_ids(self, words):
        used_word_ids = Counter()

        for word in words:
            preferred_word_id = str(word.get("word_id", "")).strip()
            if preferred_word_id:
                resolved_word_id = self._ensure_available_word_id(
                    preferred_word_id,
                    used_word_ids,
                )
                word.set_word_id(resolved_word_id)
                continue

            resolved_word_id = self._build_word_id(word, used_word_ids)
            word.set_word_id(resolved_word_id)

    def _build_word_id(self, word, used_word_ids=None):
        if used_word_ids is None:
            used_word_ids = Counter()
        fallback_candidates = []

        for candidate in self._iter_word_id_candidates(word):
            if not candidate:
                continue

            fallback_candidates.append(candidate)
            if used_word_ids[candidate] == 0:
                used_word_ids[candidate] += 1
                return candidate

        fallback_word_id = fallback_candidates[0] if fallback_candidates else "word_unknown"
        return self._ensure_available_word_id(fallback_word_id, used_word_ids)

    def _iter_word_id_candidates(self, word):
        normalized_fields = {
            field_name: self._normalize_word_id_fragment(word.get(field_name, ""))
            for field_name in ("id", "english", "transcription", "hebrew")
        }

        if normalized_fields["id"]:
            yield f"word_{normalized_fields['id']}"

        if normalized_fields["english"]:
            yield f"word_{normalized_fields['english']}"

        if normalized_fields["english"] and normalized_fields["transcription"]:
            yield (
                f"word_{normalized_fields['english']}_"
                f"{normalized_fields['transcription']}"
            )

        if normalized_fields["transcription"]:
            yield f"word_{normalized_fields['transcription']}"

        if normalized_fields["hebrew"]:
            yield f"word_{normalized_fields['hebrew']}"

    def _normalize_word_id_fragment(self, raw_value):
        normalized = re.sub(r"[^a-z0-9]+", "_", str(raw_value).strip().lower()).strip("_")
        return normalized or None

    def _ensure_available_word_id(self, base_word_id, used_word_ids):
        if not base_word_id:
            return None

        count = used_word_ids[base_word_id]
        used_word_ids[base_word_id] += 1
        if count == 0:
            return base_word_id

        return f"{base_word_id}_{count + 1}"

    def _is_text_section_file(self, filename):
        if not filename.endswith((".md", ".txt")):
            return False

        lesson_stem = os.path.splitext(os.path.basename(filename))[0]
        return bool(re.match(r"^\d+", lesson_stem))

    def _sorted_directory_filenames(self, directory):
        return sorted(os.listdir(directory), key=self._lesson_sort_key)

    def _lesson_sort_key(self, filename):
        lesson_stem = os.path.splitext(os.path.basename(filename))[0]
        numeric_prefix = re.match(r"^(\d+)", lesson_stem)

        if numeric_prefix:
            return (0, int(numeric_prefix.group(1)), lesson_stem.lower(), filename.lower())

        return (1, lesson_stem.lower(), filename.lower())

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
