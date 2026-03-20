import random
import tkinter as tk
from datetime import datetime
from tkinter import messagebox, ttk

from ui.theme import AppTheme


class FlashcardsWindow:
    def __init__(self, master, words, data_service):
        self.words = words
        self.data_service = data_service
        self.current_word = None

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("Картки")
        self.window.geometry("720x580")
        self.window.minsize(600, 520)

        self._build_layout()
        self.next_card()

    def _build_layout(self):
        container = ttk.Frame(self.window, style="App.TFrame", padding=24)
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(1, weight=1)

        hero_card = ttk.Frame(container, style="Hero.TFrame", padding=(20, 18))
        hero_card.grid(row=0, column=0, sticky="ew")
        hero_card.columnconfigure(0, weight=1)

        ttk.Label(
            hero_card,
            text="Флеш-картки",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text="Reveal the translation after you decide whether you know the word.",
            style="HeroBody.TLabel",
            wraplength=560,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        card = ttk.Frame(container, style="Card.TFrame", padding=(28, 24))
        card.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        card.columnconfigure(0, weight=1)
        card.grid_anchor("n")

        ttk.Label(card, text="Flashcard", style="Pill.TLabel").grid(
            row=0, column=0, sticky="w"
        )

        self.hebrew_label = ttk.Label(
            card,
            text="",
            style="Display.TLabel",
            anchor="center",
            justify="center",
        )
        self.hebrew_label.grid(row=1, column=0, sticky="ew", pady=(18, 6))

        self.transcription_label = ttk.Label(
            card,
            text="",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        )
        self.transcription_label.grid(row=2, column=0, sticky="ew")

        self.translation_label = ttk.Label(
            card,
            text="",
            style="SectionTitle.TLabel",
            wraplength=460,
            justify="center",
            anchor="center",
        )
        self.translation_label.grid(row=3, column=0, sticky="ew", pady=(20, 0))

        stats_card = ttk.Frame(card, style="Muted.TFrame", padding=(18, 14))
        stats_card.grid(row=4, column=0, sticky="ew", pady=(18, 0))
        stats_card.columnconfigure(0, weight=1)

        self.stats_label = ttk.Label(
            stats_card,
            text="",
            style="SurfaceMuted.TLabel",
            justify="center",
            anchor="center",
        )
        self.stats_label.grid(row=0, column=0, sticky="ew")

        button_frame = ttk.Frame(card, style="Card.TFrame")
        button_frame.grid(row=5, column=0, pady=(24, 12))

        self.dont_know_button = ttk.Button(
            button_frame,
            text="Не знаю",
            style="Secondary.TButton",
            command=lambda: self.answer_card(False),
        )
        self.dont_know_button.grid(row=0, column=0, padx=(0, 8))

        self.know_button = ttk.Button(
            button_frame,
            text="Знаю",
            style="Accent.TButton",
            command=lambda: self.answer_card(True),
        )
        self.know_button.grid(row=0, column=1, padx=(8, 0))

        self.next_button = ttk.Button(
            card,
            text="Далі",
            style="Secondary.TButton",
            command=self.next_card,
        )
        self.next_button.grid(row=6, column=0, pady=(18, 12))
        self.next_button.grid_remove()

    def next_card(self):
        if not self.words:
            messagebox.showwarning("Немає даних", "Список слів порожній.")
            self.window.destroy()
            return

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = random.choice(candidates)

        self.hebrew_label.config(text=self.current_word["hebrew"])
        self.transcription_label.config(
            text=f"({self.current_word.get('transcription', '')})"
        )
        self.translation_label.config(text="")

        self._update_stats()
        self._set_answer_state(answered=False)

    def answer_card(self, known):
        if not self.current_word:
            return

        if known:
            self.current_word["correct"] = self.current_word.get("correct", 0) + 1
            self.current_word["last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
        else:
            self.current_word["wrong"] = self.current_word.get("wrong", 0) + 1

        self.translation_label.config(text=self.current_word["english"])
        self._update_stats()
        self._set_answer_state(answered=True)
        self.data_service.save_words(self.words)

    def _update_stats(self):
        correct = self.current_word.get("correct", 0)
        wrong = self.current_word.get("wrong", 0)
        last_correct = self.current_word.get("last_correct", False)

        if last_correct:
            last_correct_text = f"Останнє 'Знаю': {last_correct}"
        else:
            last_correct_text = "Останнього 'Знаю' ще не було"

        self.stats_label.config(
            text=f"Знаю: {correct}    Не знаю: {wrong}\n{last_correct_text}"
        )

    def _set_answer_state(self, *, answered):
        if answered:
            self.know_button.config(state="disabled")
            self.dont_know_button.config(state="disabled")
            self.next_button.grid()
            return

        self.know_button.config(state="normal")
        self.dont_know_button.config(state="normal")
        self.next_button.grid_remove()
