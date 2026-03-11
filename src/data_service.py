import json
import os
import re
from tkinter import messagebox


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
            return json.load(file)

    def load_guide_sections(self):
        return self.load_text_sections(
            self.paths.guide_dir,
            missing_title="Folder not found",
            missing_message=f"Could not find guide folder:\n{self.paths.guide_dir}",
            empty_title="Guide is empty",
            empty_message=f"No guide sections were found in:\n{self.paths.guide_dir}",
        )

    def load_verbs(self):
        return self.load_text_sections(
            self.paths.verbs_dir,
            missing_title="Folder not found",
            missing_message=f"Could not find verbs folder:\n{self.paths.verbs_dir}",
            empty_title="Verbs are empty",
            empty_message=f"No verbs were found in:\n{self.paths.verbs_dir}",
        )

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

    def _split_markdown_section(self, content):
        lines = content.splitlines()

        for index, line in enumerate(lines):
            stripped_line = line.strip()
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
