import random
import re
import tkinter as tk
from datetime import datetime
from tkinter import messagebox, ttk

from ui.theme import AppTheme


class FlashcardsWindow:
    def __init__(self, master, words, data_service):
        self.words = words
        self.data_service = data_service
        self.current_word = None
        self.current_context = None
        self.last_answer_known = None
        self.last_context_ids = {}

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("Картки")
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
            text="Флеш-картки",
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

        self.context_text = tk.Text(
            card,
            wrap="word",
            height=2,
            font=(AppTheme.FONT_FAMILY, 11),
            padx=8,
            pady=4,
        )
        self.context_text.grid(row=3, column=0, sticky="ew", pady=(18, 0))
        self.context_text.configure(
            bg=AppTheme.SURFACE,
            fg=AppTheme.TEXT,
            insertbackground=AppTheme.TEXT,
            highlightthickness=0,
            borderwidth=0,
            relief="flat",
        )
        self._configure_context_tags()

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
            text="Не знаю",
            style="Secondary.TButton",
            command=lambda: self.answer_card(False),
        )
        self.dont_know_button.grid(row=0, column=0, padx=(0, 8), sticky="ew")

        self.know_button = ttk.Button(
            button_frame,
            text="Знаю",
            style="Accent.TButton",
            command=lambda: self.answer_card(True),
        )
        self.know_button.grid(row=0, column=1, padx=(8, 0), sticky="ew")

        self.next_button = ttk.Button(
            button_frame,
            text="Далі",
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
        if not self.words:
            messagebox.showwarning("Немає даних", "Список слів порожній.")
            self.window.destroy()
            return

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = random.choice(candidates)
        self.current_context = self._select_context(self.current_word)

        self.hebrew_label.config(text=self.current_word["hebrew"])
        self.transcription_label.config(
            text=f"({self.current_word.get('transcription', '')})"
        )
        if self.current_context:
            self._render_context_text(self.current_context.get("hebrew", ""))
        else:
            self._render_context_text(
                "Контекст для цього слова ще не додано.",
                bold=False,
            )
        self.context_translation_label.config(text="")
        self.translation_label.config(text="")
        self.last_answer_known = None

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

        if self.current_context:
            self.context_translation_label.config(
                text=self.current_context.get("translation", "")
            )

        self.translation_label.config(text=self.current_word["english"])
        self.last_answer_known = known
        self._update_stats()
        self._set_answer_state(answered=True, known=known)
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
        self.context_text.tag_configure(
            "context",
            font=(AppTheme.FONT_FAMILY, 11),
            justify="center",
            foreground=AppTheme.TEXT,
        )
        self.context_text.tag_configure(
            "context_muted",
            font=(AppTheme.FONT_FAMILY, 11),
            justify="center",
            foreground=AppTheme.MUTED_TEXT,
        )
        self.context_text.tag_configure(
            "context_bold",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 11, "bold"),
            justify="center",
            foreground=AppTheme.TEXT,
        )

    def _render_context_text(self, text, *, bold=True):
        self.context_text.config(state="normal")
        self.context_text.delete("1.0", tk.END)

        if not text:
            self.context_text.config(state="disabled")
            return

        target = self.current_word.get("hebrew", "") if self.current_word else ""
        if bold and target:
            last_index = 0
            for match in re.finditer(re.escape(target), text):
                start, end = match.span()
                if start > last_index:
                    self.context_text.insert(
                        tk.END, text[last_index:start], ("context",)
                    )
                self.context_text.insert(tk.END, text[start:end], ("context_bold",))
                last_index = end

            if last_index == 0:
                self.context_text.insert(tk.END, text, ("context",))
            elif last_index < len(text):
                self.context_text.insert(tk.END, text[last_index:], ("context",))
        else:
            self.context_text.insert(tk.END, text, ("context_muted",))

        self._resize_context_box()
        self.context_text.config(state="disabled")

    def _resize_context_box(self):
        self.context_text.update_idletasks()

        try:
            display_lines = int(
                self.context_text.count("1.0", "end-1c", "displaylines")[0]
            )
        except (tk.TclError, TypeError, ValueError, IndexError):
            content = self.context_text.get("1.0", "end-1c")
            display_lines = max(1, len(content) // 34)

        self.context_text.configure(height=min(max(display_lines, 2), 5))

    def _select_context(self, word):
        contexts = word.get("_contexts", [])
        if not contexts:
            return None

        if len(contexts) == 1:
            context = contexts[0]
        else:
            previous_context_id = self.last_context_ids.get(word.get("_word_id"))
            candidates = [
                context
                for context in contexts
                if context.get("id") != previous_context_id
            ]
            context = random.choice(candidates or contexts)

        context_id = context.get("id")
        if context_id:
            self.last_context_ids[word.get("_word_id")] = context_id

        return context
