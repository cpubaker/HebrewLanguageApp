import random
import tkinter as tk
import unicodedata
from datetime import datetime
from tkinter import messagebox


class WritingWindow:
    def __init__(self, master, words, data_service):
        self.words = words
        self.data_service = data_service
        self.current_word = None

        self.window = tk.Toplevel(master)
        self.window.title("Писання")
        self.window.geometry("560x460")
        self.window.minsize(460, 400)
        self.window.configure(padx=20, pady=20)

        self._build_layout()
        self.next_word()

    def _build_layout(self):
        title_label = tk.Label(
            self.window,
            text="Тренування письма",
            font=("Helvetica", 18, "bold"),
        )
        title_label.pack(pady=(0, 20))

        subtitle_label = tk.Label(
            self.window,
            text="Подивіться на переклад і напишіть слово івритом.",
            font=("Helvetica", 12),
            fg="#444444",
            wraplength=420,
            justify="center",
        )
        subtitle_label.pack(pady=(0, 16))

        prompt_title_label = tk.Label(
            self.window,
            text="Слово для перекладу",
            font=("Helvetica", 12, "bold"),
        )
        prompt_title_label.pack()

        self.prompt_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 24, "bold"),
            wraplength=420,
            justify="center",
        )
        self.prompt_label.pack(pady=(8, 18))

        self.answer_entry = tk.Entry(
            self.window,
            font=("Helvetica", 22),
            justify="center",
        )
        self.answer_entry.pack(fill="x", padx=20)
        self.answer_entry.bind("<Return>", self.submit_answer)

        self.feedback_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 13, "bold"),
            wraplength=420,
            justify="center",
        )
        self.feedback_label.pack(pady=(16, 12))

        self.stats_label = tk.Label(
            self.window,
            text="",
            font=("Helvetica", 12),
            justify="center",
        )
        self.stats_label.pack(pady=(0, 18))

        button_frame = tk.Frame(self.window)
        button_frame.pack(pady=8)

        self.check_button = tk.Button(
            button_frame,
            text="Перевірити",
            width=14,
            command=self.submit_answer,
        )
        self.check_button.pack(side=tk.LEFT, padx=8)

        self.next_button = tk.Button(
            button_frame,
            text="Далі",
            width=14,
            command=self.next_word,
        )
        self.next_button.pack(side=tk.LEFT, padx=8)

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
        self.feedback_label.config(text="", fg="#000000")
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
                fg="#b36b00",
            )
            return

        if user_answer == correct_answer:
            self.current_word["writing_correct"] = (
                self.current_word.get("writing_correct", 0) + 1
            )
            self.current_word["writing_last_correct"] = datetime.now().isoformat(
                timespec="seconds"
            )
            self.feedback_label.config(text="Правильно!", fg="green")
        else:
            self.current_word["writing_wrong"] = (
                self.current_word.get("writing_wrong", 0) + 1
            )
            self.feedback_label.config(
                text=f"Неправильно. Правильний варіант: {self.current_word.get('hebrew', '')}",
                fg="red",
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
            text=f"Правильно: {correct}    Неправильно: {wrong}    Спроб: {total}\n{last_correct_text}"
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
