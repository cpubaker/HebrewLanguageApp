import random
import tkinter as tk
from datetime import datetime
from tkinter import messagebox


class FlashcardsWindow:
    def __init__(self, master, words, data_service):
        self.words = words
        self.data_service = data_service
        self.current_word = None

        self.window = tk.Toplevel(master)
        self.window.title("Картки")
        self.window.geometry("520x420")
        self.window.minsize(440, 360)
        self.window.configure(padx=20, pady=20)

        self._build_layout()
        self.next_card()

    def _build_layout(self):
        title_label = tk.Label(
            self.window,
            text="Флеш-картки",
            font=("Helvetica", 18, "bold"),
        )
        title_label.pack(pady=(0, 20))

        self.hebrew_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 30, "bold"),
        )
        self.hebrew_label.pack(pady=(10, 10))

        self.transcription_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 14),
            fg="#444444",
        )
        self.transcription_label.pack(pady=(0, 18))

        self.translation_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 16, "bold"),
            wraplength=380,
            justify="center",
        )
        self.translation_label.pack(pady=(0, 18))

        self.stats_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 12),
            justify="center",
        )
        self.stats_label.pack(pady=(0, 18))

        button_frame = tk.Frame(self.window)
        button_frame.pack(pady=10)

        self.dont_know_button = tk.Button(
            button_frame,
            text="Не знаю",
            width=12,
            command=lambda: self.answer_card(False),
        )
        self.dont_know_button.pack(side=tk.LEFT, padx=8)

        self.know_button = tk.Button(
            button_frame,
            text="Знаю",
            width=12,
            command=lambda: self.answer_card(True),
        )
        self.know_button.pack(side=tk.LEFT, padx=8)

        self.next_button = tk.Button(
            self.window,
            text="Далі",
            width=12,
            command=self.next_card,
        )

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
            last_correct_text = "Останнє 'Знаю': ще не було"

        self.stats_label.config(
            text=f"Знаю: {correct}    Не знаю: {wrong}\n{last_correct_text}"
        )

    def _set_answer_state(self, *, answered):
        if answered:
            self.know_button.config(state="disabled")
            self.dont_know_button.config(state="disabled")
            self.next_button.pack(pady=(12, 0))
            return

        self.know_button.config(state="normal")
        self.dont_know_button.config(state="normal")
        self.next_button.pack_forget()
