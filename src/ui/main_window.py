import os
import random
import tkinter as tk
from datetime import datetime
from tkinter import messagebox

from app_paths import AppPaths
from app_version import APP_NAME, get_version_label
from data_service import HebrewDataService
from ui.flashcards_window import FlashcardsWindow
from ui.guide_window import GuideWindow
from ui.reading_window import ReadingWindow
from ui.verbs_window import VerbsWindow
from ui.writing_window import WritingWindow


class HebrewLearningApp:
    def __init__(self, master):
        self.master = master
        self.paths = AppPaths.from_src_file(__file__)
        self.data_service = HebrewDataService(master, self.paths)

        self.words = self.data_service.load_words()
        self.guide_sections = self.data_service.load_guide_sections()
        self.verbs = self.data_service.load_verbs()
        self.reading_sections = self.data_service.load_reading_sections()
        self.current_word = None
        self.icon_image = None

        self._configure_window()
        self._build_layout()
        self.next_word()

    def _configure_window(self):
        self.master.title(f"{APP_NAME} {get_version_label()}")
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

        top_controls_frame = tk.Frame(controls_frame)
        top_controls_frame.pack()

        bottom_controls_frame = tk.Frame(controls_frame)
        bottom_controls_frame.pack(pady=(8, 0))

        next_button = tk.Button(
            top_controls_frame,
            text="Далі",
            width=12,
            height=1,
            command=self.next_word,
        )
        next_button.pack(side=tk.LEFT, padx=8)

        guide_button = tk.Button(
            top_controls_frame,
            text="Довідник",
            width=12,
            height=1,
            command=self.open_guide,
        )
        guide_button.pack(side=tk.LEFT, padx=8)

        verbs_button = tk.Button(
            top_controls_frame,
            text="Дієслова",
            width=12,
            height=1,
            command=self.open_verbs,
        )
        verbs_button.pack(side=tk.LEFT, padx=8)

        reading_button = tk.Button(
            bottom_controls_frame,
            text="Читання",
            width=12,
            height=1,
            command=self.open_reading,
        )
        reading_button.pack(side=tk.LEFT, padx=8)

        flashcards_button = tk.Button(
            bottom_controls_frame,
            text="Картки",
            width=12,
            height=1,
            command=self.open_flashcards,
        )
        flashcards_button.pack(side=tk.LEFT, padx=8)

        writing_button = tk.Button(
            bottom_controls_frame,
            text="Писання",
            width=12,
            height=1,
            command=self.open_writing,
        )
        writing_button.pack(side=tk.LEFT, padx=8)

        footer_frame = tk.Frame(self.master)
        footer_frame.pack(side=tk.BOTTOM, fill="x", pady=(16, 0))

        version_label = tk.Label(
            footer_frame,
            text=get_version_label(),
            font=("Helvetica", 10),
            fg="#666666",
        )
        version_label.pack(anchor="e")

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
            self.current_word["last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
            self.feedback_label.config(text="Correct!", fg="green")
        else:
            self.current_word["wrong"] += 1
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

    def open_reading(self):
        ReadingWindow(self.master, self.reading_sections)

    def open_flashcards(self):
        FlashcardsWindow(self.master, self.words, self.data_service)

    def open_writing(self):
        WritingWindow(self.master, self.words, self.data_service)
