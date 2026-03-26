import tkinter as tk
from tkinter import messagebox, ttk

from ui.audio_player import AudioPlaybackError, AudioPlayer
from ui.text_browser_window import TextBrowserWindow


class VerbsWindow(TextBrowserWindow):
    def __init__(self, master, verbs):
        self.current_section = None
        self.filtered_sections = []
        self.play_audio_button = None
        self.search_var = tk.StringVar()
        self.results_label = None

        super().__init__(
            master,
            sections=verbs,
            window_title="Дієслова",
            list_label="Дієслова",
            empty_title="Список дієслів порожній",
            empty_message="У папці verbs поки немає жодного дієслова.",
        )

        self.window.protocol("WM_DELETE_WINDOW", self._on_close)

    def _build_sidebar_controls(self, parent):
        controls_frame = ttk.Frame(parent, style="Card.TFrame")
        controls_frame.pack(fill="x", pady=(0, 12))

        ttk.Label(
            controls_frame,
            text="Пошук",
            style="Muted.TLabel",
        ).pack(anchor="w")

        search_entry = ttk.Entry(
            controls_frame,
            textvariable=self.search_var,
        )
        search_entry.pack(fill="x", pady=(6, 0))
        search_entry.bind("<KeyRelease>", self._on_search_changed)

        self.results_label = ttk.Label(
            controls_frame,
            text="",
            style="Footer.TLabel",
        )
        self.results_label.pack(anchor="w", pady=(6, 0))

    def _build_header_controls(self, parent):
        self.play_audio_button = ttk.Button(
            parent,
            text="🔊",
            style="Icon.TButton",
            command=self.play_selected_audio,
        )
        self.play_audio_button.pack(anchor="e")

    def _populate_sections(self):
        self._refresh_sections()

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection or not self.filtered_sections:
            return

        section = self.filtered_sections[selection[0]]
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

    def _on_search_changed(self, event=None):
        self._refresh_sections()

    def _refresh_sections(self):
        selected_filename = (
            self.current_section.get("filename") if self.current_section else None
        )
        query = self.search_var.get().strip().casefold()
        self.filtered_sections = [
            section
            for section in self.sections
            if self._section_matches_query(section, query)
        ]

        self.section_listbox.delete(0, tk.END)
        for section in self.filtered_sections:
            self.section_listbox.insert(tk.END, section["title"])

        self._update_results_label()

        if not self.filtered_sections:
            self.current_section = None
            self._show_empty_state(
                title="Нічого не знайдено" if query else None,
                message=(
                    "Спробуйте інший запит або очистьте пошук."
                    if query
                    else self.empty_message
                ),
            )
            self._update_audio_controls(None)
            return

        selected_index = 0
        if selected_filename:
            for index, section in enumerate(self.filtered_sections):
                if section.get("filename") == selected_filename:
                    selected_index = index
                    break

        self.section_listbox.selection_set(selected_index)
        self.section_listbox.activate(selected_index)
        self.section_listbox.see(selected_index)
        self.show_section()

    def _section_matches_query(self, section, query):
        if not query:
            return True

        searchable_content = " ".join(
            [
                str(section.get("title", "")),
                str(section.get("body", "")),
                str(section.get("filename", "")),
            ]
        ).casefold()
        return query in searchable_content

    def _update_results_label(self):
        if not self.results_label:
            return

        total = len(self.sections)
        visible = len(self.filtered_sections)
        self.results_label.config(text=f"Показано: {visible} з {total}")

    def _on_close(self):
        AudioPlayer.stop()
        self.window.destroy()
