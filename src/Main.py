import tkinter as tk
from tkinter import messagebox
import json
import random
import os
from hebrew_guide import GUIDE_SECTIONS


class HebrewLearningApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Learn Hebrew")
        self.master.geometry("520x560")
        self.master.minsize(460, 500)
        self.master.configure(padx=20, pady=20)

        # Project structure
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.words_file = os.path.join(self.project_root, "data", "input", "hebrew_words.json")
        self.icon_file = os.path.join(self.project_root, "src", "ui", "app_icon.png")

        # App icon
        self.set_app_icon()

        # Data
        self.words = self.load_words()
        self.current_word = None

        # Guide content
        self.guide_sections = GUIDE_SECTIONS

        # Title
        self.title_label = tk.Label(
            master,
            text="Hebrew Vocabulary Trainer",
            font=("Helvetica", 18, "bold")
        )
        self.title_label.pack(pady=(0, 15))

        # Hebrew word
        self.hebrew_word_label = tk.Label(
            master,
            text="",
            font=("Helvetica", 28, "bold")
        )
        self.hebrew_word_label.pack(pady=(10, 8))

        # Transcription
        self.transcription_label = tk.Label(
            master,
            text="",
            font=("Helvetica", 14),
            fg="#444444"
        )
        self.transcription_label.pack(pady=(0, 20))

        # Answers area
        self.button_frame = tk.Frame(master)
        self.button_frame.pack(fill="x", pady=10)

        # Feedback
        self.feedback_label = tk.Label(
            master,
            text="",
            font=("Helvetica", 14, "bold")
        )
        self.feedback_label.pack(pady=(10, 10))

        # Score / status
        self.score_label = tk.Label(
            master,
            text="",
            font=("Helvetica", 13)
        )
        self.score_label.pack(pady=(0, 20))

        # Bottom buttons
        self.controls_frame = tk.Frame(master)
        self.controls_frame.pack(pady=10)

        self.next_button = tk.Button(
            self.controls_frame,
            text="Next",
            width=12,
            height=1,
            command=self.next_word
        )
        self.next_button.pack(side=tk.LEFT, padx=8)

        self.guide_button = tk.Button(
            self.controls_frame,
            text="Довідник",
            width=12,
            height=1,
            command=self.open_guide
        )
        self.guide_button.pack(side=tk.LEFT, padx=8)

        # Load first word
        self.next_word()

    def set_app_icon(self):
        if os.path.exists(self.icon_file):
            try:
                self.icon_image = tk.PhotoImage(file=self.icon_file)
                self.master.iconphoto(False, self.icon_image)
            except Exception as e:
                print(f"Failed to load icon: {e}")
        else:
            print(f"Icon not found: {self.icon_file}")

    def load_words(self):
        if not os.path.exists(self.words_file):
            messagebox.showerror(
                "File not found",
                f"Could not find words file:\n{self.words_file}"
            )
            self.master.destroy()
            raise FileNotFoundError(self.words_file)

        with open(self.words_file, "r", encoding="utf-8") as file:
            return json.load(file)

    def save_progress(self):
        with open(self.words_file, "w", encoding="utf-8") as file:
            json.dump(self.words, file, ensure_ascii=False, indent=4)

    def next_word(self):
        if not self.words:
            messagebox.showwarning("No data", "The words list is empty.")
            return

        self.current_word = random.choice(self.words)
        self.display_word()

    def display_word(self):
        correct_translation = self.current_word["english"]

        other_words = [w for w in self.words if w != self.current_word]
        if not other_words:
            options = [correct_translation]
        else:
            wrong_word = random.choice(other_words)
            wrong_translation = wrong_word["english"]
            options = [correct_translation, wrong_translation]
            random.shuffle(options)

        self.hebrew_word_label.config(text=self.current_word["hebrew"])
        self.transcription_label.config(text=f"({self.current_word['transcription']})")

        self.feedback_label.config(text="")
        self.update_score()

        for widget in self.button_frame.winfo_children():
            widget.destroy()

        for option in options:
            btn = tk.Button(
                self.button_frame,
                text=option,
                font=("Helvetica", 12),
                width=34,
                wraplength=340,
                justify="center",
                pady=10,
                command=lambda opt=option: self.check_answer(opt)
            )
            btn.pack(fill="x", pady=6)

    def check_answer(self, translation):
        if translation == self.current_word["english"]:
            self.current_word["correct"] += 1
            self.current_word["last_correct"] = True
            self.feedback_label.config(text="Correct!", fg="green")
        else:
            self.current_word["wrong"] += 1
            self.current_word["last_correct"] = False
            self.feedback_label.config(text="Wrong!", fg="red")

        self.update_score()
        self.save_progress()

    def update_score(self):
        correct = self.current_word.get("correct", 0)
        wrong = self.current_word.get("wrong", 0)
        total = correct + wrong

        self.score_label.config(
            text=f"Correct: {correct}    Wrong: {wrong}    Total attempts: {total}"
        )

    def open_guide(self):
        guide_window = tk.Toplevel(self.master)
        guide_window.title("Довідник з івриту")
        guide_window.geometry("760x480")
        guide_window.minsize(680, 420)

        container = tk.Frame(guide_window, padx=12, pady=12)
        container.pack(fill="both", expand=True)

        left_frame = tk.Frame(container)
        left_frame.pack(side="left", fill="y", padx=(0, 12))

        right_frame = tk.Frame(container)
        right_frame.pack(side="right", fill="both", expand=True)

        section_label = tk.Label(
            left_frame,
            text="Розділи",
            font=("Helvetica", 12, "bold")
        )
        section_label.pack(anchor="w", pady=(0, 8))

        section_listbox = tk.Listbox(
            left_frame,
            width=24,
            height=18,
            font=("Helvetica", 11),
            exportselection=False
        )
        section_listbox.pack(fill="y")

        text_title = tk.Label(
            right_frame,
            text="",
            font=("Helvetica", 14, "bold"),
            anchor="w"
        )
        text_title.pack(fill="x", pady=(0, 8))

        text_widget = tk.Text(
            right_frame,
            wrap="word",
            font=("Helvetica", 12),
            padx=10,
            pady=10
        )
        text_widget.pack(fill="both", expand=True)

        for section_name in self.guide_sections:
            section_listbox.insert(tk.END, section_name)

        def show_section(event=None):
            selection = section_listbox.curselection()
            if not selection:
                return

            selected_section = section_listbox.get(selection[0])
            content = self.guide_sections[selected_section]

            text_title.config(text=selected_section)
            text_widget.config(state="normal")
            text_widget.delete("1.0", tk.END)
            text_widget.insert(tk.END, content)
            text_widget.config(state="disabled")

        section_listbox.bind("<<ListboxSelect>>", show_section)

        section_listbox.selection_set(0)
        show_section()


def main():
    root = tk.Tk()
    app = HebrewLearningApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
