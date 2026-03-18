from ui.text_browser_window import TextBrowserWindow


class VerbsWindow(TextBrowserWindow):
    def __init__(self, master, verbs):
        super().__init__(
            master,
            sections=verbs,
            window_title="Дієслова",
            list_label="Дієслова",
            empty_title="Список дієслів порожній",
            empty_message="У папці verbs поки немає жодного дієслова.",
        )

    def _populate_sections(self):
        for section in self.sections:
            self.section_listbox.insert("end", section["title"])

        if self.sections:
            self.section_listbox.selection_set(0)
            self.show_section()
            return

        self._show_empty_state()

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection or not self.sections:
            return

        section = self.sections[selection[0]]
        self._set_section_image(section.get("image_path"))
        self._display_section(section["title"], section["body"])
