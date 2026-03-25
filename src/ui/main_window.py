import os
import tkinter as tk
from tkinter import messagebox, ttk

from application.vocabulary_session import VocabularySession
from app_version import APP_NAME, get_version_label
from ui.debounced_save import DebouncedSaveController
from ui.flashcards_window import FlashcardsWindow
from ui.guide_window import GuideWindow
from ui.reading_window import ReadingWindow
from ui.sprint_window import SprintWindow
from ui.theme import AppTheme
from ui.verbs_window import VerbsWindow
from ui.writing_window import WritingWindow


class HebrewLearningApp:
    def __init__(self, master, runtime):
        self.master = master
        self.paths = runtime.paths
        self.progress_service = runtime.progress_service

        self.words = runtime.app_content.words
        self.guide_sections = runtime.app_content.guide_sections
        self.verbs = runtime.app_content.verbs
        self.reading_sections = runtime.app_content.reading_sections
        self.session = VocabularySession(self.words)
        self.icon_image = None
        self.answer_buttons = {}
        self.autosave = DebouncedSaveController(self.master, self.progress_service)

        self._configure_window()
        self._build_layout()
        self.next_word()

    def _configure_window(self):
        AppTheme.apply(self.master)
        self.master.title(f"{APP_NAME} {get_version_label()}")
        self.master.geometry("760x780")
        self.master.minsize(680, 700)
        self.set_app_icon()
        self.master.protocol("WM_DELETE_WINDOW", self.close)

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
            text="\u0414\u0430\u043b\u0456",
            style="Accent.TButton",
            command=self.next_word,
        ).grid(row=0, column=0, sticky="ew", padx=(0, 10), pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="\u0414\u043e\u0432\u0456\u0434\u043d\u0438\u043a",
            style="Secondary.TButton",
            command=self.open_guide,
        ).grid(row=0, column=1, sticky="ew", padx=5, pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="\u0414\u0456\u0454\u0441\u043b\u043e\u0432\u0430",
            style="Secondary.TButton",
            command=self.open_verbs,
        ).grid(row=0, column=2, sticky="ew", padx=(10, 0), pady=(0, 10))
        ttk.Button(
            navigation_card,
            text="\u0427\u0438\u0442\u0430\u043d\u043d\u044f",
            style="Secondary.TButton",
            command=self.open_reading,
        ).grid(row=1, column=0, sticky="ew", padx=(0, 10))
        ttk.Button(
            navigation_card,
            text="\u041a\u0430\u0440\u0442\u043a\u0438",
            style="Secondary.TButton",
            command=self.open_flashcards,
        ).grid(row=1, column=1, sticky="ew", padx=5)
        ttk.Button(
            navigation_card,
            text="\u041f\u0438\u0441\u0430\u043d\u043d\u044f",
            style="Secondary.TButton",
            command=self.open_writing,
        ).grid(row=1, column=2, sticky="ew", padx=(10, 0))
        ttk.Button(
            navigation_card,
            text="\u0421\u043f\u0440\u0438\u043d\u0442",
            style="Accent.TButton",
            command=self.open_sprint,
        ).grid(row=2, column=0, columnspan=3, sticky="ew", pady=(10, 0))

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
        prompt = self.session.next_prompt()
        if not prompt:
            messagebox.showwarning("No data", "The words list is empty.")
            return

        current_word = prompt["word"]
        self.hebrew_word_label.config(text=current_word["hebrew"])
        self.transcription_label.config(text=f"({current_word['transcription']})")
        self.feedback_label.config(text="", style="Muted.TLabel")
        self.update_score()
        self.answer_buttons = {}

        for widget in self.button_frame.winfo_children():
            widget.destroy()

        for option in prompt["options"]:
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
        result = self.session.submit_answer(translation)
        if not result:
            return

        correct_translation = result["correct_translation"]

        if result["is_correct"]:
            self.feedback_label.config(
                text="Correct! Press '\u0414\u0430\u043b\u0456' for the next word.",
                style="Success.TLabel",
            )
        else:
            self.feedback_label.config(
                text=f"Wrong. Correct answer: {correct_translation}",
                style="Danger.TLabel",
            )

        self._update_answer_button_states(translation, correct_translation)
        self.update_score()
        self.autosave.request_save(self.words)

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
        score = self.session.current_score()
        self.score_label.config(
            text=(
                f"Correct: {score['correct']}    Wrong: {score['wrong']}    "
                f"Total attempts: {score['total']}"
            )
        )

    def open_guide(self):
        GuideWindow(self.master, self.guide_sections)

    def open_verbs(self):
        VerbsWindow(self.master, self.verbs)

    def open_reading(self):
        ReadingWindow(self.master, self.reading_sections)

    def open_flashcards(self):
        FlashcardsWindow(self.master, self.words, self.progress_service)

    def open_writing(self):
        WritingWindow(self.master, self.words, self.progress_service)

    def open_sprint(self):
        SprintWindow(self.master, self.words, self.progress_service)

    def close(self):
        self.autosave.cancel()
        self.progress_service.flush()
        self.master.destroy()
