import tkinter as tk
from tkinter import messagebox, ttk

from application.sprint_session import SprintSession
from ui.theme import AppTheme


class SprintWindow:
    DURATION_SECONDS = 60

    def __init__(self, master, words, progress_service):
        self.words = words
        self.progress_service = progress_service
        self.session = SprintSession(words)
        self.remaining_seconds = self.DURATION_SECONDS
        self.timer_job = None
        self.sprint_active = False

        if not self.session.can_start():
            messagebox.showwarning(
                "Недостатньо даних",
                "Для вправи 'Спринт' потрібно щонайменше два слова з різними перекладами.",
            )
            return

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title("Спринт")
        self.window.geometry("760x720")
        self.window.minsize(680, 620)
        self.window.protocol("WM_DELETE_WINDOW", self.close)

        self.answer_buttons = {}

        self._build_layout()
        self.start_sprint()

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
            text="Спринт",
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            hero_card,
            text=(
                "У тебе є одна хвилина. Обирай правильний переклад якнайшвидше "
                "і дивись підсумок унизу."
            ),
            style="HeroBody.TLabel",
            wraplength=620,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        card = ttk.Frame(container, style="Card.TFrame", padding=(28, 24))
        card.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        card.columnconfigure(0, weight=1)
        card.grid_anchor("n")

        header_row = ttk.Frame(card, style="Card.TFrame")
        header_row.grid(row=0, column=0, sticky="ew")
        header_row.columnconfigure(0, weight=1)

        ttk.Label(header_row, text="Режим на час", style="Pill.TLabel").grid(
            row=0, column=0, sticky="w"
        )

        self.timer_label = ttk.Label(
            header_row,
            text="01:00",
            style="SectionTitle.TLabel",
            anchor="e",
            justify="right",
        )
        self.timer_label.grid(row=0, column=1, sticky="e")

        self.hebrew_label = ttk.Label(
            card,
            text="",
            style="Display.TLabel",
            anchor="center",
            justify="center",
        )
        self.hebrew_label.grid(row=1, column=0, sticky="ew", pady=(24, 6))

        self.transcription_label = ttk.Label(
            card,
            text="",
            style="Muted.TLabel",
            anchor="center",
            justify="center",
        )
        self.transcription_label.grid(row=2, column=0, sticky="ew")

        self.prompt_label = ttk.Label(
            card,
            text="Обери правильний переклад",
            style="CardBody.TLabel",
            anchor="center",
            justify="center",
        )
        self.prompt_label.grid(row=3, column=0, sticky="ew", pady=(22, 12))

        self.button_frame = ttk.Frame(card, style="Card.TFrame")
        self.button_frame.grid(row=4, column=0, sticky="ew")

        self.status_separator = ttk.Separator(card)
        self.status_separator.grid(row=5, column=0, sticky="ew", pady=(18, 0))

        status_card = ttk.Frame(card, style="Muted.TFrame", padding=(18, 16))
        status_card.grid(row=6, column=0, sticky="ew", pady=(18, 0))
        status_card.columnconfigure(0, weight=1)

        self.feedback_label = ttk.Label(
            status_card,
            text="",
            style="SurfaceMuted.TLabel",
            anchor="center",
            justify="center",
            wraplength=600,
        )
        self.feedback_label.grid(row=0, column=0, sticky="ew")

        self.result_label = ttk.Label(
            status_card,
            text="",
            style="SectionTitle.TLabel",
            anchor="center",
            justify="center",
        )
        self.result_label.grid(row=1, column=0, sticky="ew", pady=(10, 0))

        self.restart_button = ttk.Button(
            card,
            text="Почати ще раз",
            style="Accent.TButton",
            command=self.start_sprint,
        )
        self.restart_button.grid(row=7, column=0, pady=(20, 0))
        self.restart_button.grid_remove()

    def start_sprint(self):
        self._cancel_timer()
        self.session = SprintSession(self.words)
        self.remaining_seconds = self.DURATION_SECONDS
        self.sprint_active = True
        self._set_quiz_visibility(True)
        self.feedback_label.config(
            text="Час пішов. Обирай правильний переклад.",
            style="SurfaceMuted.TLabel",
        )
        self.restart_button.grid_remove()
        self._render_timer()
        self._show_next_prompt()
        self._tick()

    def _tick(self):
        if not self.sprint_active:
            return

        self.timer_job = self.window.after(1000, self._advance_timer)

    def _advance_timer(self):
        if not self.sprint_active:
            return

        self.remaining_seconds -= 1
        self._render_timer()

        if self.remaining_seconds <= 0:
            self.finish_sprint()
            return

        self._tick()

    def _render_timer(self):
        minutes, seconds = divmod(max(self.remaining_seconds, 0), 60)
        self.timer_label.config(text=f"{minutes:02d}:{seconds:02d}")

    def _show_next_prompt(self):
        prompt = self.session.next_prompt()
        if not prompt:
            self.finish_sprint(
                message="Не вдалося зібрати наступне питання для спринту."
            )
            return

        current_word = prompt["word"]
        self.hebrew_label.config(text=current_word["hebrew"])
        self.transcription_label.config(
            text=f"({current_word.get('transcription', '')})"
        )
        self._render_answer_buttons(prompt["options"])
        self._update_result_label()

    def _render_answer_buttons(self, options):
        self.answer_buttons = {}
        for widget in self.button_frame.winfo_children():
            widget.destroy()

        for option in options:
            button = tk.Button(
                self.button_frame,
                text=option,
                wraplength=460,
                justify="center",
                command=lambda selected=option: self.answer(selected),
            )
            AppTheme.style_classic_button(button, variant="choice")
            button.pack(fill="x", pady=6)
            self.answer_buttons[option] = button

    def _set_quiz_visibility(self, visible):
        if visible:
            self.prompt_label.grid()
            self.button_frame.grid()
            self.status_separator.grid()
            return

        self.prompt_label.grid_remove()
        self.button_frame.grid_remove()
        self.status_separator.grid_remove()

    def answer(self, selected_translation):
        if not self.sprint_active:
            return

        result = self.session.submit_answer(selected_translation)
        if not result:
            return

        if result["is_correct"]:
            self.feedback_label.config(
                text=f"Правильно: {result['correct_translation']}",
                style="Success.TLabel",
            )
        else:
            self.feedback_label.config(
                text=f"Неправильно. Правильна відповідь: {result['correct_translation']}",
                style="Danger.TLabel",
            )

        self._update_result_label()
        self.progress_service.save_words(self.words)

        if self.remaining_seconds > 0:
            self._show_next_prompt()

    def _update_result_label(self):
        self.result_label.config(
            text=(
                f"Правильно: {self.session.correct_count}    "
                f"Неправильно: {self.session.wrong_count}    "
                f"Всього: {self.session.attempts}"
            )
        )

    def finish_sprint(self, message=None):
        self.sprint_active = False
        self._cancel_timer()
        self._set_quiz_visibility(False)

        final_message = (
            message
            or "Хвилина завершилась. Подивись результат і, якщо хочеш, спробуй ще раз."
        )
        self.feedback_label.config(text=final_message, style="Warning.TLabel")
        self.hebrew_label.config(text="Спринт завершено")
        self.transcription_label.config(text="")

        for button in self.answer_buttons.values():
            button.config(state="disabled", cursor="arrow")

        self.restart_button.grid()
        self._update_result_label()

    def _cancel_timer(self):
        if self.timer_job and hasattr(self, "window") and self.window.winfo_exists():
            self.window.after_cancel(self.timer_job)
        self.timer_job = None

    def close(self):
        self._cancel_timer()
        self.window.destroy()
