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
