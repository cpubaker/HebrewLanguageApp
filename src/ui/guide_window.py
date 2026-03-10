from ui.text_browser_window import TextBrowserWindow


class GuideWindow(TextBrowserWindow):
    def __init__(self, master, guide_sections):
        super().__init__(
            master,
            sections=guide_sections,
            window_title="Довідник з івриту",
            list_label="Розділи",
            empty_title="Довідник порожній",
            empty_message="У папці guide поки немає жодного розділу.",
        )
