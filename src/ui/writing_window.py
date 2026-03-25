import tkinter as tk
from tkinter import messagebox, ttk

from application.writing_session import WritingSession
from ui.theme import AppTheme


class WritingWindow:
    def __init__(self, master, words, progress_service):
        self.words = words
        self.progress_service = progress_service
        self.session = WritingSession(words)

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("\u041f\u0438\u0441\u0430\u043d\u043d\u044f")
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
            text="\u0422\u0440\u0435\u043d\u0443\u0432\u0430\u043d\u043d\u044f \u043f\u0438\u0441\u044c\u043c\u0430",
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
            text="\u0421\u043b\u043e\u0432\u043e \u0434\u043b\u044f \u043f\u0435\u0440\u0435\u043a\u043b\u0430\u0434\u0443",
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
            text="\u041f\u0435\u0440\u0435\u0432\u0456\u0440\u0438\u0442\u0438",
            style="Accent.TButton",
            command=self.submit_answer,
        )
        self.check_button.grid(row=0, column=0, padx=(0, 8))

        self.next_button = ttk.Button(
            button_frame,
            text="\u0414\u0430\u043b\u0456",
            style="Secondary.TButton",
            command=self.next_word,
        )
        self.next_button.grid(row=0, column=1, padx=(8, 0))

    def next_word(self):
        prompt = self.session.next_prompt()
        if not prompt:
            messagebox.showwarning(
                "\u041d\u0435\u043c\u0430\u0454 \u0434\u0430\u043d\u0438\u0445",
                "\u0421\u043f\u0438\u0441\u043e\u043a \u0441\u043b\u0456\u0432 \u043f\u043e\u0440\u043e\u0436\u043d\u0456\u0439.",
            )
            self.window.destroy()
            return

        self.prompt_label.config(text=prompt["prompt"])
        self.answer_entry.config(state="normal")
        self.answer_entry.delete(0, tk.END)
        self.feedback_label.config(text="", style="CardBody.TLabel")
        self._update_stats()
        self._set_answer_state(answered=False)
        self.answer_entry.focus_set()

    def submit_answer(self, _event=None):
        if self.answer_entry.cget("state") == "disabled":
            return

        result = self.session.submit_answer(self.answer_entry.get())
        if not result:
            return

        if result["status"] == "empty":
            self.feedback_label.config(
                text=(
                    "\u0412\u0432\u0435\u0434\u0456\u0442\u044c \u043f\u0435\u0440\u0435\u043a\u043b\u0430\u0434 "
                    "\u0456\u0432\u0440\u0438\u0442\u043e\u043c, \u0449\u043e\u0431 \u043f\u0435\u0440\u0435\u0432\u0456\u0440\u0438\u0442\u0438 "
                    "\u0432\u0456\u0434\u043f\u043e\u0432\u0456\u0434\u044c."
                ),
                style="Warning.TLabel",
            )
            return

        if result["is_correct"]:
            self.feedback_label.config(
                text="\u041f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e!",
                style="Success.TLabel",
            )
        else:
            self.feedback_label.config(
                text=(
                    "\u041d\u0435\u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e. "
                    "\u041f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u0438\u0439 \u0432\u0430\u0440\u0456\u0430\u043d\u0442: "
                    f"{result['correct_answer']}"
                ),
                style="Danger.TLabel",
            )

        self._update_stats()
        self._set_answer_state(answered=True)
        self.progress_service.save_words(self.words)

    def _update_stats(self):
        stats = self.session.current_stats()
        last_correct = stats["last_correct"]

        if last_correct:
            last_correct_text = (
                f"\u041e\u0441\u0442\u0430\u043d\u043d\u044f \u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u0430 "
                f"\u0432\u0456\u0434\u043f\u043e\u0432\u0456\u0434\u044c: {last_correct}"
            )
        else:
            last_correct_text = (
                "\u041e\u0441\u0442\u0430\u043d\u043d\u044c\u043e\u0457 \u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e\u0457 "
                "\u0432\u0456\u0434\u043f\u043e\u0432\u0456\u0434\u0456 \u0449\u0435 \u043d\u0435 \u0431\u0443\u043b\u043e"
            )

        self.stats_label.config(
            text=(
                f"\u041f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e: {stats['correct']}    "
                f"\u041d\u0435\u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e: {stats['wrong']}    "
                f"\u0421\u043f\u0440\u043e\u0431: {stats['total']}\n{last_correct_text}"
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
