import os
import random
import tkinter as tk
from datetime import datetime
from tkinter import messagebox, ttk

from app_paths import AppPaths
from app_version import APP_NAME, get_version_label
from data_service import HebrewDataService
from ui.flashcards_window import FlashcardsWindow
from ui.guide_window import GuideWindow
from ui.reading_window import ReadingWindow
from ui.theme import AppTheme
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
        self.answer_buttons = {}
        self.answered = False

        self._configure_window()
        self._build_layout()
        self.next_word()

    def _configure_window(self):
        AppTheme.apply(self.master)
        self.master.title(f"{APP_NAME} {get_version_label()}")
        self.master.geometry("760x780")
        self.master.minsize(680, 700)
        self.set_app_icon()

    def _build_layout(self):
        container = ttk.Frame(self.master, style="App.TFrame", padding=24)
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(1, weight=1)

        hero_card = ttk.Frame(container, style="Hero.TFrame", padding=(24, 22))
        hero_card.grid(row=0, column=0, sticky="ew")
        hero_card.columnconfigure(0, weight=1)

        ttk.Label(
            hero_card,
            text="Hebrew Vocabulary Trainer",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text=(
                "Practice vocabulary, reading, and writing in a calmer, more focused "
                "workspace."
            ),
            style="HeroBody.TLabel",
            wraplength=640,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        practice_card = ttk.Frame(container, style="Card.TFrame", padding=(28, 24))
        practice_card.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        practice_card.columnconfigure(0, weight=1)
        practice_card.grid_anchor("n")

        ttk.Label(
            practice_card,
            text="Vocabulary Drill",
            style="Pill.TLabel",
        ).grid(row=0, column=0, sticky="w")

        self.hebrew_word_label = ttk.Label(
            practice_card,
            text="",
            style="Display.TLabel",
            anchor="center",
            justify="center",
        )
        self.hebrew_word_label.grid(row=1, column=0, sticky="ew", pady=(18, 6))

        self.transcription_label = ttk.Label(
            practice_card,
            text="",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        )
        self.transcription_label.grid(row=2, column=0, sticky="ew")

        ttk.Label(
            practice_card,
            text="Choose the correct translation",
            style="CardBody.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=3, column=0, sticky="ew", pady=(22, 12))

        self.button_frame = ttk.Frame(practice_card, style="Card.TFrame")
        self.button_frame.grid(row=4, column=0, sticky="ew", pady=(0, 8))

        ttk.Separator(practice_card).grid(row=5, column=0, sticky="ew", pady=(18, 0))

        status_card = ttk.Frame(practice_card, style="Card.TFrame", padding=(4, 12))
        status_card.grid(row=6, column=0, sticky="ew", pady=(6, 8))
        status_card.columnconfigure(0, weight=1)

        self.feedback_label = ttk.Label(
            status_card,
            text="",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        )
        self.feedback_label.grid(row=0, column=0, sticky="ew")

        self.score_label = ttk.Label(
            status_card,
            text="",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        )
        self.score_label.grid(row=1, column=0, sticky="ew", pady=(6, 0))

        navigation_card = ttk.Frame(container, style="Card.TFrame", padding=(20, 18))
        navigation_card.grid(row=2, column=0, sticky="ew", pady=(18, 0))
        for column in range(3):
            navigation_card.columnconfigure(column, weight=1)

        ttk.Button(
            navigation_card,
            text="Далі",
            style="Accent.TButton",
            command=self.next_word,
        ).grid(row=0, column=0, sticky="ew", padx=(0, 10), pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="Довідник",
            style="Secondary.TButton",
            command=self.open_guide,
        ).grid(row=0, column=1, sticky="ew", padx=5, pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="Дієслова",
            style="Secondary.TButton",
            command=self.open_verbs,
        ).grid(row=0, column=2, sticky="ew", padx=(10, 0), pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="Читання",
            style="Secondary.TButton",
            command=self.open_reading,
        ).grid(row=1, column=0, sticky="ew", padx=(0, 10))
        ttk.Button(
            navigation_card,
            text="Картки",
            style="Secondary.TButton",
            command=self.open_flashcards,
        ).grid(row=1, column=1, sticky="ew", padx=5)
        ttk.Button(
            navigation_card,
            text="Писання",
            style="Secondary.TButton",
            command=self.open_writing,
        ).grid(row=1, column=2, sticky="ew", padx=(10, 0))

        ttk.Label(
            container,
            text=get_version_label(),
            style="Footer.TLabel",
            anchor="e",
        ).grid(row=3, column=0, sticky="ew", pady=(14, 0))

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
        self.feedback_label.config(text="", style="Muted.TLabel")
        self.update_score()
        self.answered = False
        self.answer_buttons = {}

        for widget in self.button_frame.winfo_children():
            widget.destroy()

        for option in options:
            button = tk.Button(
                self.button_frame,
                text=option,
                wraplength=460,
                justify="center",
                command=lambda selected=option: self.check_answer(selected),
            )
            AppTheme.style_classic_button(button, variant="choice")
            button.pack(fill="x", pady=6)
            self.answer_buttons[option] = button

    def check_answer(self, translation):
        if self.answered or not self.current_word:
            return

        self.answered = True
        correct_translation = self.current_word["english"]

        if translation == self.current_word["english"]:
            self.current_word["correct"] += 1
            self.current_word["last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
            self.feedback_label.config(
                text="Correct! Press 'Далі' for the next word.",
                style="Success.TLabel",
            )
        else:
            self.current_word["wrong"] += 1
            self.feedback_label.config(
                text=f"Wrong. Correct answer: {correct_translation}",
                style="Danger.TLabel",
            )

        self._update_answer_button_states(translation, correct_translation)

        self.update_score()
        self.data_service.save_words(self.words)

    def _update_answer_button_states(self, selected_translation, correct_translation):
        for option, button in self.answer_buttons.items():
            if option == correct_translation:
                AppTheme.style_choice_button_state(button, "correct")
            elif option == selected_translation:
                AppTheme.style_choice_button_state(button, "wrong")
            else:
                AppTheme.style_choice_button_state(button, "disabled")

            button.config(state="disabled", cursor="arrow")

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
