from ui.text_browser_window import TextBrowserWindow


class ReadingWindow(TextBrowserWindow):
    def __init__(self, master, reading_sections):
        super().__init__(
            master,
            sections=reading_sections,
            window_title="Читання івритом",
            list_label="Тексти",
            empty_title="Розділ читання порожній",
            empty_message="У папці reading поки немає жодного тексту.",
        )
