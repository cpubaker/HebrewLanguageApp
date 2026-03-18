import json
import os
import re
from tkinter import messagebox

from reading_levels import READING_LEVELS


class HebrewDataService:
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
            if not filename.endswith((".md", ".txt")):
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
        with open(self.paths.words_file, "w", encoding="utf-8") as file:
            json.dump(words, file, ensure_ascii=False, indent=4)

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
            if not filename.endswith((".md", ".txt")):
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
            if not filename.endswith((".md", ".txt")):
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

        lesson_stem = os.path.splitext(filename)[0]
        image_name = re.sub(r"^\d+[_-]*", "", lesson_stem).strip()
        if not image_name:
            return None

        image_path = os.path.join(images_dir, f"{image_name}.png")
        if os.path.exists(image_path):
            return image_path

        return None

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

