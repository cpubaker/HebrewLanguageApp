import tkinter as tk
from tkinter import messagebox, ttk

from application.flashcard_session import FlashcardSession
from ui.theme import AppTheme


class FlashcardsWindow:
    def __init__(self, master, words, progress_service):
        self.words = words
        self.progress_service = progress_service
        self.session = FlashcardSession(words)

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("\u041a\u0430\u0440\u0442\u043a\u0438")
        self.window.geometry("760x720")
        self.window.minsize(680, 620)

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
            text="\u0424\u043b\u0435\u0448-\u043a\u0430\u0440\u0442\u043a\u0438",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text="Reveal the translation after you decide whether you know the word.",
            style="HeroBody.TLabel",
            wraplength=600,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        card = ttk.Frame(container, style="Card.TFrame", padding=(28, 20))
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

        self.context_label = ttk.Label(
            card,
            text="",
            style="CardBody.TLabel",
            wraplength=620,
            justify="right",
            anchor="e",
        )
        self.context_label.grid(row=3, column=0, sticky="ew", pady=(18, 0))

        self.context_translation_label = ttk.Label(
            card,
            text="",
            style="Muted.TLabel",
            wraplength=620,
            justify="center",
            anchor="center",
        )
        self.context_translation_label.grid(row=4, column=0, sticky="ew", pady=(8, 0))

        self.translation_label = ttk.Label(
            card,
            text="",
            style="SectionTitle.TLabel",
            wraplength=520,
            justify="center",
            anchor="center",
        )
        self.translation_label.grid(row=5, column=0, sticky="ew", pady=(16, 0))

        stats_card = ttk.Frame(card, style="Muted.TFrame", padding=(18, 14))
        stats_card.grid(row=6, column=0, sticky="ew", pady=(14, 0))
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
        button_frame.grid(row=7, column=0, sticky="ew", pady=(18, 8))
        button_frame.columnconfigure(0, weight=1)
        button_frame.columnconfigure(1, weight=1)

        self.dont_know_button = ttk.Button(
            button_frame,
            text="\u041d\u0435 \u0437\u043d\u0430\u044e",
            style="Secondary.TButton",
            command=lambda: self.answer_card(False),
        )
        self.dont_know_button.grid(row=0, column=0, padx=(0, 8), sticky="ew")

        self.know_button = ttk.Button(
            button_frame,
            text="\u0417\u043d\u0430\u044e",
            style="Accent.TButton",
            command=lambda: self.answer_card(True),
        )
        self.know_button.grid(row=0, column=1, padx=(8, 0), sticky="ew")

        self.next_button = ttk.Button(
            button_frame,
            text="\u0414\u0430\u043b\u0456",
            style="Secondary.TButton",
            command=self.next_card,
        )
        self.next_button.grid(
            row=0,
            column=1,
            sticky="ew",
            padx=(8, 0),
        )
        self.next_button.grid_remove()

    def next_card(self):
        card = self.session.next_card()
        if not card:
            messagebox.showwarning(
                "\u041d\u0435\u043c\u0430\u0454 \u0434\u0430\u043d\u0438\u0445",
                "\u0421\u043f\u0438\u0441\u043e\u043a \u0441\u043b\u0456\u0432 \u043f\u043e\u0440\u043e\u0436\u043d\u0456\u0439.",
            )
            self.window.destroy()
            return

        current_word = card["word"]
        current_context = card["context"]

        self.hebrew_label.config(text=current_word["hebrew"])
        self.transcription_label.config(
            text=f"({current_word.get('transcription', '')})"
        )
        if current_context:
            self._render_context_text(current_context.get("hebrew", ""))
        else:
            self._render_context_text(
                "\u041a\u043e\u043d\u0442\u0435\u043a\u0441\u0442 \u0434\u043b\u044f \u0446\u044c\u043e\u0433\u043e \u0441\u043b\u043e\u0432\u0430 \u0449\u0435 \u043d\u0435 \u0434\u043e\u0434\u0430\u043d\u043e.",
                bold=False,
            )

        self.context_translation_label.config(text="")
        self.translation_label.config(text="")
        self._update_stats()
        self._set_answer_state(answered=False)

    def answer_card(self, known):
        result = self.session.answer_card(known)
        if not result:
            return

        current_context = result["context"]
        current_word = result["word"]

        if current_context:
            self.context_translation_label.config(
                text=current_context.get("translation", "")
            )

        self.translation_label.config(text=current_word["english"])
        self._update_stats()
        self._set_answer_state(answered=True, known=known)
        self.progress_service.save_words(self.words)

    def _update_stats(self):
        stats = self.session.current_stats()
        last_correct = stats["last_correct"]

        if last_correct:
            last_correct_text = (
                f"\u041e\u0441\u0442\u0430\u043d\u043d\u0454 '\u0417\u043d\u0430\u044e': {last_correct}"
            )
        else:
            last_correct_text = (
                "\u041e\u0441\u0442\u0430\u043d\u043d\u044c\u043e\u0433\u043e '\u0417\u043d\u0430\u044e' \u0449\u0435 \u043d\u0435 \u0431\u0443\u043b\u043e"
            )

        self.stats_label.config(
            text=(
                f"\u0417\u043d\u0430\u044e: {stats['correct']}    "
                f"\u041d\u0435 \u0437\u043d\u0430\u044e: {stats['wrong']}\n{last_correct_text}"
            )
        )

    def _set_answer_state(self, *, answered, known=None):
        if answered:
            if known:
                self.dont_know_button.grid_remove()
                self.know_button.config(style="Success.TButton", state="disabled")
                self.know_button.grid(row=0, column=0, padx=(0, 8), sticky="ew")
            else:
                self.know_button.grid_remove()
                self.dont_know_button.config(style="Danger.TButton", state="disabled")
                self.dont_know_button.grid(row=0, column=0, padx=(0, 8), sticky="ew")
            self.next_button.grid()
            return

        self.know_button.config(style="Accent.TButton", state="normal")
        self.dont_know_button.config(style="Secondary.TButton", state="normal")
        self.next_button.grid_remove()
        self.dont_know_button.grid(row=0, column=0, padx=(0, 8), sticky="ew")
        self.know_button.grid(row=0, column=1, padx=(8, 0), sticky="ew")

    def _configure_context_tags(self):
        return

    def _render_context_text(self, text, *, bold=True):
        if not text:
            self.context_label.config(text="", style="CardBody.TLabel")
            return

        style = "CardBody.TLabel" if bold else "Muted.TLabel"
        formatted_text = self._format_context_text(text)
        self.context_label.config(text=formatted_text, style=style)

    def _format_context_text(self, text):
        if self._contains_hebrew(text):
            return f"\u202B{text}\u202C"
        return text

    def _contains_hebrew(self, text):
        return any("\u0590" <= char <= "\u05FF" for char in text)
