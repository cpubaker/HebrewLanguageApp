import os
import random
import tkinter as tk
from tkinter import messagebox

from app_paths import AppPaths
from data_service import HebrewDataService
from ui.guide_window import GuideWindow
from ui.verbs_window import VerbsWindow


class HebrewLearningApp:
    def __init__(self, master):
        self.master = master
        self.paths = AppPaths.from_src_file(__file__)
        self.data_service = HebrewDataService(master, self.paths)

        self.words = self.data_service.load_words()
        self.guide_sections = self.data_service.load_guide_sections()
        self.verbs = self.data_service.load_verbs()
        self.current_word = None
        self.icon_image = None

        self._configure_window()
        self._build_layout()
        self.next_word()

    def _configure_window(self):
        self.master.title("Learn Hebrew")
        self.master.geometry("520x560")
        self.master.minsize(460, 500)
        self.master.configure(padx=20, pady=20)
        self.set_app_icon()

    def _build_layout(self):
        title_label = tk.Label(
            self.master,
            text="Hebrew Vocabulary Trainer",
            font=("Helvetica", 18, "bold"),
        )
        title_label.pack(pady=(0, 15))

        self.hebrew_word_label = tk.Label(
            self.master,
            text="",
            font=("Helvetica", 28, "bold"),
        )
        self.hebrew_word_label.pack(pady=(10, 8))

        self.transcription_label = tk.Label(
            self.master,
            text="",
            font=("Helvetica", 14),
            fg="#444444",
        )
        self.transcription_label.pack(pady=(0, 20))

        self.button_frame = tk.Frame(self.master)
        self.button_frame.pack(fill="x", pady=10)

        self.feedback_label = tk.Label(
            self.master,
            text="",
            font=("Helvetica", 14, "bold"),
        )
        self.feedback_label.pack(pady=(10, 10))

        self.score_label = tk.Label(
            self.master,
            text="",
            font=("Helvetica", 13),
        )
        self.score_label.pack(pady=(0, 20))

        controls_frame = tk.Frame(self.master)
        controls_frame.pack(pady=10)

        next_button = tk.Button(
            controls_frame,
            text="Далі",
            width=12,
            height=1,
            command=self.next_word,
        )
        next_button.pack(side=tk.LEFT, padx=8)

        guide_button = tk.Button(
            controls_frame,
            text="Довідник",
            width=12,
            height=1,
            command=self.open_guide,
        )
        guide_button.pack(side=tk.LEFT, padx=8)

        verbs_button = tk.Button(
            controls_frame,
            text="Дієслова",
            width=12,
            height=1,
            command=self.open_verbs,
        )
        verbs_button.pack(side=tk.LEFT, padx=8)

    def set_app_icon(self):
        if os.path.exists(self.paths.icon_file):
            try:
                self.icon_image = tk.PhotoImage(file=self.paths.icon_file)
                self.master.iconphoto(False, self.icon_image)
            except Exception as error:
                print(f"Failed to load icon: {error}")
            return

        print(f"Icon not found: {self.paths.icon_file}")

    def next_word(self):
        if not self.words:
            messagebox.showwarning("No data", "The words list is empty.")
            return

        self.current_word = random.choice(self.words)
        self.display_word()

    def display_word(self):
        correct_translation = self.current_word["english"]
        options = [correct_translation]

        other_words = [word for word in self.words if word != self.current_word]
        if other_words:
            wrong_translation = random.choice(other_words)["english"]
            options.append(wrong_translation)
            random.shuffle(options)

        self.hebrew_word_label.config(text=self.current_word["hebrew"])
        self.transcription_label.config(text=f"({self.current_word['transcription']})")
        self.feedback_label.config(text="")
        self.update_score()

        for widget in self.button_frame.winfo_children():
            widget.destroy()

        for option in options:
            button = tk.Button(
                self.button_frame,
                text=option,
                font=("Helvetica", 12),
                width=34,
                wraplength=340,
                justify="center",
                pady=10,
                command=lambda selected=option: self.check_answer(selected),
            )
            button.pack(fill="x", pady=6)

    def check_answer(self, translation):
        if translation == self.current_word["english"]:
            self.current_word["correct"] += 1
            self.current_word["last_correct"] = True
            self.feedback_label.config(text="Correct!", fg="green")
        else:
            self.current_word["wrong"] += 1
            self.current_word["last_correct"] = False
            self.feedback_label.config(text="Wrong!", fg="red")

        self.update_score()
        self.data_service.save_words(self.words)

    def update_score(self):
        correct = self.current_word.get("correct", 0)
        wrong = self.current_word.get("wrong", 0)
        total = correct + wrong

        self.score_label.config(
            text=f"Correct: {correct}    Wrong: {wrong}    Total attempts: {total}"
        )

    def open_guide(self):
        GuideWindow(self.master, self.guide_sections)

    def open_verbs(self):
        VerbsWindow(self.master, self.verbs)
