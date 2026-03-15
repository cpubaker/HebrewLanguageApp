import tkinter as tk

from reading_levels import READING_LEVEL_LABELS, READING_LEVELS
from ui.text_browser_window import TextBrowserWindow


class ReadingWindow(TextBrowserWindow):
    def __init__(self, master, reading_sections):
        self.level_vars = {}
        self.filtered_sections = []
        self.selected_section_key = None

        super().__init__(
            master,
            sections=reading_sections,
            window_title="Читання івритом",
            list_label="Тексти",
            empty_title="Розділ читання порожній",
            empty_message="У папці reading поки немає жодного тексту.",
        )

    def _build_sidebar_controls(self, parent):
        filters_label = tk.Label(
            parent,
            text="Рівні",
            font=("Helvetica", 11, "bold"),
        )
        filters_label.pack(anchor="w", pady=(0, 6))

        for level in READING_LEVELS:
            level_var = tk.BooleanVar(value=True)
            self.level_vars[level] = level_var

            checkbox = tk.Checkbutton(
                parent,
                text=READING_LEVEL_LABELS[level],
                variable=level_var,
                anchor="w",
                command=self._apply_filters,
            )
            checkbox.pack(anchor="w")

        tk.Frame(parent, height=12).pack()

    def _populate_sections(self):
        self._apply_filters()

    def _apply_filters(self):
        active_levels = {
            level for level, level_var in self.level_vars.items() if level_var.get()
        }

        self.filtered_sections = [
            section
            for section in self.sections
            if section["level"] in active_levels
        ]

        previous_key = self.selected_section_key

        self.section_listbox.delete(0, tk.END)
        for section in self.filtered_sections:
            self.section_listbox.insert(tk.END, self._format_section_label(section))

        if not self.filtered_sections:
            self.selected_section_key = None
            self._show_empty_state(
                title="Немає текстів для вибраних рівнів",
                message="Оберіть інший рівень або додайте тексти у відповідну папку.",
            )
            return

        selected_index = 0
        if previous_key is not None:
            for index, section in enumerate(self.filtered_sections):
                if self._get_section_key(section) == previous_key:
                    selected_index = index
                    break

        self.section_listbox.selection_clear(0, tk.END)
        self.section_listbox.selection_set(selected_index)
        self.show_section()

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection or not self.filtered_sections:
            return

        section = self.filtered_sections[selection[0]]
        self.selected_section_key = self._get_section_key(section)

        self._display_section(
            f"{section['title']} ({READING_LEVEL_LABELS[section['level']]})",
            section["body"],
        )

    def _format_section_label(self, section):
        return f"{section['title']} [{READING_LEVEL_LABELS[section['level']]}]"

    def _get_section_key(self, section):
        return (section["level"], section["filename"])
