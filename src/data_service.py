import json
import os
import re
from tkinter import messagebox

from reading_levels import READING_LEVELS


class HebrewDataService:
    TRANSIENT_WORD_FIELDS = {"_word_id", "_contexts"}

    def __init__(self, master, paths):
        self.master = master
        self.paths = paths

    def load_words(self):
        if not os.path.exists(self.paths.words_file):
            messagebox.showerror(
                "File not found",
                f"Could not find words file:\n{self.paths.words_file}",
            )
            self.master.destroy()
            raise FileNotFoundError(self.paths.words_file)

        with open(self.paths.words_file, "r", encoding="utf-8") as file:
            words = json.load(file)

        for word in words:
            word.setdefault("correct", 0)
            word.setdefault("wrong", 0)
            word.setdefault("writing_correct", 0)
            word.setdefault("writing_wrong", 0)

            last_correct = word.get("last_correct", False)
            if isinstance(last_correct, bool):
                word["last_correct"] = False

            writing_last_correct = word.get("writing_last_correct", False)
            if isinstance(writing_last_correct, bool):
                word["writing_last_correct"] = False

            word["_word_id"] = self._build_word_id(word)

        contexts_by_word_id = self.load_word_contexts(words)
        for word in words:
            word["_contexts"] = contexts_by_word_id.get(word["_word_id"], [])

        return words

    def load_guide_sections(self):
        return self.load_text_sections(
            self.paths.guide_dir,
            missing_title="Folder not found",
            missing_message=f"Could not find guide folder:\n{self.paths.guide_dir}",
            empty_title="Guide is empty",
            empty_message=f"No guide sections were found in:\n{self.paths.guide_dir}",
        )

    def load_verbs(self):
        if not os.path.exists(self.paths.verbs_dir):
            messagebox.showerror(
                "Folder not found",
                f"Could not find verbs folder:\n{self.paths.verbs_dir}",
            )
            self.master.destroy()
            raise FileNotFoundError(self.paths.verbs_dir)

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
                {
                    "title": title,
                    "body": body,
                    "filename": filename,
                    "image_path": self._find_verb_image_path(filename),
                    "audio_path": self._find_verb_audio_path(filename),
                }
            )

        if not sections:
            messagebox.showwarning(
                "Verbs are empty",
                f"No verbs were found in:\n{self.paths.verbs_dir}",
            )

        return sections

    def load_reading_sections(self):
        if not os.path.exists(self.paths.reading_dir):
            messagebox.showerror(
                "Folder not found",
                f"Could not find reading folder:\n{self.paths.reading_dir}",
            )
            self.master.destroy()
            raise FileNotFoundError(self.paths.reading_dir)

        sections = []

        for level in READING_LEVELS:
            level_dir = os.path.join(self.paths.reading_dir, level)
            if not os.path.isdir(level_dir):
                continue

            sections.extend(self._load_reading_sections_from_directory(level_dir, level))

        if not sections:
            messagebox.showwarning(
                "Reading is empty",
                f"No reading texts were found in:\n{self.paths.reading_dir}",
            )

        return sections

    def save_words(self, words):
        sanitized_words = []
        for word in words:
            sanitized_words.append(
                {
                    key: value
                    for key, value in word.items()
                    if key not in self.TRANSIENT_WORD_FIELDS
                }
            )

        with open(self.paths.words_file, "w", encoding="utf-8") as file:
            json.dump(sanitized_words, file, ensure_ascii=False, indent=4)

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

        contexts_by_id = {
            context["id"]: context
            for context in contexts
            if isinstance(context, dict) and context.get("id")
        }

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

    def load_text_sections(
        self,
        directory,
        *,
        missing_title,
        missing_message,
        empty_title,
        empty_message,
    ):
        if not os.path.exists(directory):
            messagebox.showerror(missing_title, missing_message)
            self.master.destroy()
            raise FileNotFoundError(directory)

        sections = {}

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
                sections[title] = body

        if not sections:
            messagebox.showwarning(empty_title, empty_message)

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
                {
                    "title": title,
                    "body": body,
                    "level": level,
                    "filename": filename,
                }
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

