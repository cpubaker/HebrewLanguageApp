import os
import re
import tkinter as tk
from tkinter import ttk

from application.word_of_day_service import WordOfDayService
from app_version import APP_NAME, get_version_label
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
        self.word_of_day = WordOfDayService(self.words).get_word_of_day()
        self.icon_image = None

        self._configure_window()
        self._build_layout()

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
            text="\u0422\u0440\u0435\u043d\u0430\u0436\u0435\u0440 \u0456\u0432\u0440\u0438\u0442\u0443",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text=(
                "\u0412\u0447\u0438 \u0441\u043b\u043e\u0432\u0430, \u0447\u0438\u0442\u0430\u043d\u043d\u044f \u0442\u0430 \u043f\u0438\u0441\u044c\u043c\u043e \u0432 \u043e\u0434\u043d\u043e\u043c\u0443 "
                "\u0441\u043f\u043e\u043a\u0456\u0439\u043d\u043e\u043c\u0443 \u0440\u043e\u0431\u043e\u0447\u043e\u043c\u0443 \u043f\u0440\u043e\u0441\u0442\u043e\u0440\u0456."
            ),
            style="HeroBody.TLabel",
            wraplength=640,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        practice_card = ttk.Frame(container, style="Card.TFrame", padding=(28, 24))
        practice_card.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        practice_card.columnconfigure(0, weight=1)
        practice_card.columnconfigure(1, weight=1)

        ttk.Label(
            practice_card,
            text="\u0421\u043b\u043e\u0432\u043e \u0434\u043d\u044f",
            style="Pill.TLabel",
        ).grid(row=0, column=0, sticky="w")

        word_of_day = self.word_of_day
        word = word_of_day["word"] if word_of_day else None
        context = word_of_day["context"] if word_of_day else None
        has_hebrew_context = bool(context and self._contains_hebrew(context.get("hebrew", "")))

        ttk.Label(
            practice_card,
            text=self._format_bidi_text(word["hebrew"]) if word else "\u2014",
            style="Display.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=1, column=0, columnspan=2, sticky="ew", pady=(18, 6))

        ttk.Label(
            practice_card,
            text=f"({word.get('transcription', '')})" if word else "",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=2, column=0, columnspan=2, sticky="ew")

        ttk.Label(
            practice_card,
            text=self._word_translation_text(word),
            style="SectionTitle.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=3, column=0, columnspan=2, sticky="ew", pady=(18, 0))

        context_card = ttk.Frame(practice_card, style="Muted.TFrame", padding=(18, 14))
        context_card.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(18, 0))
        context_card.columnconfigure(0, weight=1)

        ttk.Label(
            context_card,
            text="\u041f\u0440\u0438\u043a\u043b\u0430\u0434",
            style="MutedSectionTitle.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=0, column=0, sticky="ew")

        ttk.Label(
            context_card,
            text=self._format_bidi_text(context.get("hebrew", "")) if context else "\u0414\u043b\u044f \u0446\u044c\u043e\u0433\u043e \u0441\u043b\u043e\u0432\u0430 \u0449\u0435 \u043d\u0435\u043c\u0430\u0454 \u043f\u0440\u0438\u043a\u043b\u0430\u0434\u0443.",
            style="MutedBody.TLabel",
            wraplength=620,
            justify="right" if has_hebrew_context else "center",
            anchor="e" if has_hebrew_context else "center",
        ).grid(row=1, column=0, sticky="ew", pady=(8, 0))

        ttk.Label(
            context_card,
            text=context.get("translation", "") if context else "",
            style="SurfaceMuted.TLabel",
            wraplength=620,
            justify="right",
            anchor="e",
        ).grid(row=2, column=0, sticky="ew", pady=(8, 0))

        navigation_card = ttk.Frame(container, style="Card.TFrame", padding=(20, 18))
        navigation_card.grid(row=2, column=0, sticky="ew", pady=(18, 0))
        for column in range(3):
            navigation_card.columnconfigure(column, weight=1)

        ttk.Button(
            navigation_card,
            text="\u0424\u043b\u0435\u0448-\u043a\u0430\u0440\u0442\u043a\u0438",
            style="Accent.TButton",
            command=self.open_flashcards,
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
            text="\u041f\u0438\u0441\u0430\u043d\u043d\u044f",
            style="Secondary.TButton",
            command=self.open_writing,
        ).grid(row=1, column=1, sticky="ew", padx=5)
        ttk.Button(
            navigation_card,
            text="\u0421\u043f\u0440\u0438\u043d\u0442",
            style="Accent.TButton",
            command=self.open_sprint,
        ).grid(row=1, column=2, sticky="ew", padx=(10, 0))

        ttk.Label(
            container,
            text=get_version_label(),
            style="Footer.TLabel",
            anchor="e",
        ).grid(row=3, column=0, sticky="ew", pady=(14, 0))

    def _format_bidi_text(self, text):
        if not self._contains_hebrew(text):
            return text
        return f"\u202B{text}\u202C"

    def _word_translation_text(self, word):
        if not word:
            return "\u0421\u043b\u043e\u0432\u043d\u0438\u043a \u043f\u043e\u043a\u0438 \u043f\u043e\u0440\u043e\u0436\u043d\u0456\u0439."
        return word.get("ukrainian") or word.get("english", "")

    def _contains_hebrew(self, text):
        return bool(re.search(r"[\u0590-\u05FF]", text or ""))

    def set_app_icon(self):
        if os.path.exists(self.paths.icon_file):
            try:
                self.icon_image = tk.PhotoImage(file=self.paths.icon_file)
                self.master.iconphoto(False, self.icon_image)
            except Exception as error:
                print(f"Failed to load icon: {error}")
            return

        print(f"Icon not found: {self.paths.icon_file}")

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
        self.progress_service.flush()
        self.master.destroy()
