import tkinter as tk


class GuideWindow:
    def __init__(self, master, guide_sections):
        self.guide_sections = guide_sections
        self.window = tk.Toplevel(master)
        self.window.title("Довідник з івриту")
        self.window.geometry("760x480")
        self.window.minsize(680, 420)

        self._build_layout()
        self._populate_sections()

    def _build_layout(self):
        container = tk.Frame(self.window, padx=12, pady=12)
        container.pack(fill="both", expand=True)

        left_frame = tk.Frame(container)
        left_frame.pack(side="left", fill="y", padx=(0, 12))

        right_frame = tk.Frame(container)
        right_frame.pack(side="right", fill="both", expand=True)

        section_label = tk.Label(
            left_frame,
            text="Розділи",
            font=("Helvetica", 12, "bold"),
        )
        section_label.pack(anchor="w", pady=(0, 8))

        self.section_listbox = tk.Listbox(
            left_frame,
            width=28,
            height=18,
            font=("Helvetica", 11),
            exportselection=False,
        )
        self.section_listbox.pack(fill="y")
        self.section_listbox.bind("<<ListboxSelect>>", self.show_section)

        self.text_title = tk.Label(
            right_frame,
            text="",
            font=("Helvetica", 14, "bold"),
            anchor="w",
        )
        self.text_title.pack(fill="x", pady=(0, 8))

        text_container = tk.Frame(right_frame)
        text_container.pack(fill="both", expand=True)

        text_scrollbar = tk.Scrollbar(text_container, orient="vertical")
        text_scrollbar.pack(side="right", fill="y")

        self.text_widget = tk.Text(
            text_container,
            wrap="word",
            font=("Helvetica", 12),
            padx=10,
            pady=10,
            yscrollcommand=text_scrollbar.set,
        )
        self.text_widget.pack(side="left", fill="both", expand=True)

        text_scrollbar.config(command=self.text_widget.yview)

    def _populate_sections(self):
        section_names = list(self.guide_sections.keys())

        for section_name in section_names:
            self.section_listbox.insert(tk.END, section_name)

        if section_names:
            self.section_listbox.selection_set(0)
            self.show_section()
            return

        self.text_title.config(text="Довідник порожній")
        self.text_widget.insert("1.0", "У папці guide поки немає жодного розділу.")
        self.text_widget.config(state="disabled")

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection:
            return

        selected_section = self.section_listbox.get(selection[0])
        content = self.guide_sections[selected_section]

        self.text_title.config(text=selected_section)
        self.text_widget.config(state="normal")
        self.text_widget.delete("1.0", tk.END)
        self.text_widget.insert(tk.END, content)
        self.text_widget.config(state="disabled")
        self.text_widget.yview_moveto(0)
