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
            if not filename.endswith(".txt"):
                continue

            file_path = os.path.join(directory, filename)
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
            messagebox.showwarning(empty_title, empty_message)

        return sections
