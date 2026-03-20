import random
import tkinter as tk
import unicodedata
from datetime import datetime
from tkinter import messagebox, ttk

from ui.theme import AppTheme


class WritingWindow:
    def __init__(self, master, words, data_service):
        self.words = words
        self.data_service = data_service
        self.current_word = None

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("Писання")
        self.window.geometry("720x560")
        self.window.minsize(600, 500)

        self._build_layout()
        self.next_word()

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
            text="Тренування письма",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text="Read the prompt and type the Hebrew word from memory.",
            style="HeroBody.TLabel",
            wraplength=600,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        card = ttk.Frame(container, style="Card.TFrame", padding=(28, 24))
        card.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        card.columnconfigure(0, weight=1)

        ttk.Label(card, text="Writing Practice", style="Pill.TLabel").grid(
            row=0, column=0, sticky="w"
        )

        ttk.Label(
            card,
            text="Слово для перекладу",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        ).grid(row=1, column=0, sticky="ew", pady=(18, 6))

        self.prompt_label = ttk.Label(
            card,
            text="",
            style="Display.TLabel",
            wraplength=520,
            justify="center",
            anchor="center",
        )
        self.prompt_label.grid(row=2, column=0, sticky="ew", pady=(0, 18))

        self.answer_entry = ttk.Entry(
            card,
            font=(AppTheme.DISPLAY_FONT_FAMILY, 20),
            justify="center",
        )
        self.answer_entry.grid(row=3, column=0, sticky="ew")
        self.answer_entry.bind("<Return>", self.submit_answer)

        self.feedback_label = ttk.Label(
            card,
            text="",
            style="CardBody.TLabel",
            wraplength=520,
            justify="center",
            anchor="center",
        )
        self.feedback_label.grid(row=4, column=0, sticky="ew", pady=(18, 0))

        stats_card = ttk.Frame(card, style="Muted.TFrame", padding=(18, 14))
        stats_card.grid(row=5, column=0, sticky="ew", pady=(18, 0))
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
        button_frame.grid(row=6, column=0, pady=(20, 0))

        self.check_button = ttk.Button(
            button_frame,
            text="Перевірити",
            style="Accent.TButton",
            command=self.submit_answer,
        )
        self.check_button.grid(row=0, column=0, padx=(0, 8))

        self.next_button = ttk.Button(
            button_frame,
            text="Далі",
            style="Secondary.TButton",
            command=self.next_word,
        )
        self.next_button.grid(row=0, column=1, padx=(8, 0))

    def next_word(self):
        if not self.words:
            messagebox.showwarning("Немає даних", "Список слів порожній.")
            self.window.destroy()
            return

        candidates = self.words
        if self.current_word and len(self.words) > 1:
            candidates = [word for word in self.words if word is not self.current_word]

        self.current_word = random.choice(candidates)

        prompt = self.current_word.get("ukrainian") or self.current_word.get(
            "english", ""
        )
        self.prompt_label.config(text=prompt)
        self.answer_entry.config(state="normal")
        self.answer_entry.delete(0, tk.END)
        self.feedback_label.config(text="", style="CardBody.TLabel")
        self._update_stats()
        self._set_answer_state(answered=False)
        self.answer_entry.focus_set()

    def submit_answer(self, _event=None):
        if not self.current_word or self.answer_entry.cget("state") == "disabled":
            return

        user_answer = self._normalize_hebrew(self.answer_entry.get())
        correct_answer = self._normalize_hebrew(self.current_word.get("hebrew", ""))

        if not user_answer:
            self.feedback_label.config(
                text="Введіть переклад івритом, щоб перевірити відповідь.",
                style="Warning.TLabel",
            )
            return

        if user_answer == correct_answer:
            self.current_word["writing_correct"] = (
                self.current_word.get("writing_correct", 0) + 1
            )
            self.current_word["writing_last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
            self.feedback_label.config(text="Правильно!", style="Success.TLabel")
        else:
            self.current_word["writing_wrong"] = (
                self.current_word.get("writing_wrong", 0) + 1
            )
            self.feedback_label.config(
                text=(
                    "Неправильно. Правильний варіант: "
                    f"{self.current_word.get('hebrew', '')}"
                ),
                style="Danger.TLabel",
            )

        self._update_stats()
        self._set_answer_state(answered=True)
        self.data_service.save_words(self.words)

    def _update_stats(self):
        correct = self.current_word.get("writing_correct", 0)
        wrong = self.current_word.get("writing_wrong", 0)
        total = correct + wrong
        last_correct = self.current_word.get("writing_last_correct", False)

        if last_correct:
            last_correct_text = f"Остання правильна відповідь: {last_correct}"
        else:
            last_correct_text = "Останньої правильної відповіді ще не було"

        self.stats_label.config(
            text=(
                f"Правильно: {correct}    Неправильно: {wrong}    Спроб: {total}\n"
                f"{last_correct_text}"
            )
        )

    def _set_answer_state(self, *, answered):
        if answered:
            self.answer_entry.config(state="disabled")
            self.check_button.config(state="disabled")
            self.next_button.config(state="normal")
            return

        self.answer_entry.config(state="normal")
        self.check_button.config(state="normal")
        self.next_button.config(state="disabled")

    def _normalize_hebrew(self, text):
        normalized = unicodedata.normalize("NFC", text or "")
        return " ".join(normalized.strip().split())
