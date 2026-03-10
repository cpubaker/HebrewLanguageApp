import json
import os
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
        if not os.path.exists(self.paths.guide_dir):
            messagebox.showerror(
                "Folder not found",
                f"Could not find guide folder:\n{self.paths.guide_dir}",
            )
            self.master.destroy()
            raise FileNotFoundError(self.paths.guide_dir)

        sections = {}

        for filename in sorted(os.listdir(self.paths.guide_dir)):
            if not filename.endswith(".txt"):
                continue

            file_path = os.path.join(self.paths.guide_dir, filename)
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read().strip()

            if not content:
                continue

            lines = content.splitlines()
            title = lines[0].strip()
            body = "\n".join(lines[1:]).strip()

            if title:
                sections[title] = body

        if not sections:
            messagebox.showwarning(
                "Guide is empty",
                f"No guide sections were found in:\n{self.paths.guide_dir}",
            )

        return sections

    def save_words(self, words):
        with open(self.paths.words_file, "w", encoding="utf-8") as file:
            json.dump(words, file, ensure_ascii=False, indent=4)
