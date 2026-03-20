from tkinter import messagebox, ttk

from ui.audio_player import AudioPlaybackError, AudioPlayer
from ui.text_browser_window import TextBrowserWindow


class VerbsWindow(TextBrowserWindow):
    def __init__(self, master, verbs):
        self.current_section = None
        self.play_audio_button = None

        super().__init__(
            master,
            sections=verbs,
            window_title="Дієслова",
            list_label="Дієслова",
            empty_title="Список дієслів порожній",
            empty_message="У папці verbs поки немає жодного дієслова.",
        )

        self.window.protocol("WM_DELETE_WINDOW", self._on_close)

    def _build_header_controls(self, parent):
        self.play_audio_button = ttk.Button(
            parent,
            text="🔊",
            style="Icon.TButton",
            command=self.play_selected_audio,
        )
        self.play_audio_button.pack(anchor="e")

    def _populate_sections(self):
        for section in self.sections:
            self.section_listbox.insert("end", section["title"])

        if self.sections:
            self.section_listbox.selection_set(0)
            self.show_section()
            return

        self._show_empty_state()
        self._update_audio_controls(None)

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection or not self.sections:
            return

        section = self.sections[selection[0]]
        self.current_section = section
        self._set_section_image(section.get("image_path"))
        self._display_section(section["title"], section["body"])
        self._update_audio_controls(section)

    def play_selected_audio(self):
        if not self.current_section:
            return

        audio_path = self.current_section.get("audio_path")
        if not audio_path:
            self._update_audio_controls(self.current_section)
            return

        try:
            AudioPlayer.play(audio_path)
        except FileNotFoundError:
            self._update_audio_controls(None)
            messagebox.showwarning(
                "Аудіо не знайдено",
                "Файл озвучки не знайдено. Перевірте, що mp3 лежить у data/input/audio/verbs.",
            )
        except AudioPlaybackError:
            messagebox.showerror(
                "Не вдалося відтворити",
                "Не вдалося відтворити mp3-файл. Спробуйте інший файл або перевірте аудіоформат.",
            )

    def _update_audio_controls(self, section):
        if not self.play_audio_button:
            return

        audio_path = section.get("audio_path") if section else None
        if audio_path:
            self.play_audio_button.config(state="normal")
            return

        self.play_audio_button.config(state="disabled")

    def _on_close(self):
        AudioPlayer.stop()
        self.window.destroy()
