import math
import re
import tkinter as tk
from tkinter import ttk

from ui.theme import AppTheme


class TextBrowserWindow:
    def __init__(
        self,
        master,
        *,
        sections,
        window_title,
        list_label,
        empty_title,
        empty_message,
    ):
        self.sections = sections
        self.section_items = []
        self.empty_title = empty_title
        self.empty_message = empty_message

        self.window = tk.Toplevel(master)
        AppTheme.apply(self.window)
        self.window.title(window_title)
        self.window.geometry("960x620")
        self.window.minsize(800, 520)
        self.section_image = None

        self._build_layout(window_title, list_label)
        self._populate_sections()

    def _build_layout(self, window_title, list_label):
        container = ttk.Frame(self.window, style="App.TFrame", padding=20)
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(1, weight=1)

        header_card = ttk.Frame(container, style="Hero.TFrame", padding=(20, 18))
        header_card.grid(row=0, column=0, sticky="ew", pady=(0, 16))
        header_card.columnconfigure(0, weight=1)

        ttk.Label(
            header_card,
            text=window_title,
            style="HeroTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            header_card,
            text="Browse lessons on the left and read the full content on the right.",
            style="HeroBody.TLabel",
            wraplength=760,
            justify="left",
        ).grid(row=1, column=0, sticky="w", pady=(8, 0))

        content = ttk.Frame(container, style="App.TFrame")
        content.grid(row=1, column=0, sticky="nsew")
        content.columnconfigure(0, weight=0)
        content.columnconfigure(1, weight=1)
        content.rowconfigure(0, weight=1)

        sidebar_card = ttk.Frame(content, style="Card.TFrame", padding=(16, 16))
        sidebar_card.grid(row=0, column=0, sticky="ns", padx=(0, 16))

        content_card = ttk.Frame(content, style="Card.TFrame", padding=(20, 18))
        content_card.grid(row=0, column=1, sticky="nsew")
        content_card.columnconfigure(0, weight=1)
        content_card.rowconfigure(2, weight=1)

        self.left_frame = ttk.Frame(sidebar_card, style="Card.TFrame")
        self.left_frame.pack(fill="both", expand=True)

        self._build_sidebar_controls(self.left_frame)

        ttk.Label(
            self.left_frame,
            text=list_label,
            style="SectionTitle.TLabel",
        ).pack(anchor="w", pady=(0, 8))

        list_container = ttk.Frame(self.left_frame, style="Card.TFrame")
        list_container.pack(fill="both", expand=True)

        self.section_listbox = tk.Listbox(
            list_container,
            width=28,
            height=18,
            font=(AppTheme.FONT_FAMILY, 11),
            exportselection=False,
        )
        AppTheme.style_listbox(self.section_listbox)

        section_scrollbar = ttk.Scrollbar(
            list_container,
            orient="vertical",
            style="App.Vertical.TScrollbar",
        )
        section_scrollbar.config(command=self.section_listbox.yview)
        self.section_listbox.config(yscrollcommand=section_scrollbar.set)

        section_scrollbar.pack(side="right", fill="y")
        self.section_listbox.pack(side="left", fill="both", expand=True)
        self.section_listbox.bind("<<ListboxSelect>>", self.show_section)

        title_row = ttk.Frame(content_card, style="Card.TFrame")
        title_row.grid(row=0, column=0, sticky="ew")
        title_row.columnconfigure(0, weight=1)

        self.text_title = ttk.Label(
            title_row,
            text="",
            style="Title.TLabel",
            anchor="w",
        )
        self.text_title.grid(row=0, column=0, sticky="ew")

        self.header_controls_frame = ttk.Frame(title_row, style="Card.TFrame")
        self.header_controls_frame.grid(row=0, column=1, sticky="e", padx=(12, 0))
        self._build_header_controls(self.header_controls_frame)

        self.media_frame = ttk.Frame(content_card, style="Card.TFrame")
        self.media_frame.grid(row=1, column=0, sticky="ew", pady=(12, 0))

        self.image_label = ttk.Label(self.media_frame, style="CardBody.TLabel")

        text_container = ttk.Frame(content_card, style="Card.TFrame")
        text_container.grid(row=2, column=0, sticky="nsew", pady=(12, 0))
        text_container.columnconfigure(0, weight=1)
        text_container.rowconfigure(0, weight=1)

        text_scrollbar = ttk.Scrollbar(
            text_container,
            orient="vertical",
            style="App.Vertical.TScrollbar",
        )
        text_scrollbar.grid(row=0, column=1, sticky="ns", padx=(12, 0))

        self.text_widget = tk.Text(
            text_container,
            wrap="word",
            font=(AppTheme.FONT_FAMILY, 12),
            padx=10,
            pady=10,
            yscrollcommand=text_scrollbar.set,
        )
        AppTheme.style_text_widget(self.text_widget)
        self.text_widget.grid(row=0, column=0, sticky="nsew")

        text_scrollbar.config(command=self.text_widget.yview)
        self._configure_text_tags()

    def _build_sidebar_controls(self, parent):
        return None

    def _build_header_controls(self, parent):
        return None

    def _configure_text_tags(self):
        self.text_widget.tag_configure(
            "heading_1",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 16, "bold"),
            spacing1=10,
            spacing3=6,
        )
        self.text_widget.tag_configure(
            "heading_2",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 14, "bold"),
            spacing1=8,
            spacing3=4,
        )
        self.text_widget.tag_configure(
            "heading_3",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 13, "bold"),
            spacing1=6,
            spacing3=4,
        )
        self.text_widget.tag_configure(
            "paragraph",
            font=(AppTheme.FONT_FAMILY, 12),
            spacing1=2,
            spacing3=8,
        )
        self.text_widget.tag_configure(
            "list_item",
            font=(AppTheme.FONT_FAMILY, 12),
            lmargin1=18,
            lmargin2=36,
            spacing1=2,
            spacing3=4,
        )
        self.text_widget.tag_configure(
            "bold",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 12, "bold"),
        )
        self.text_widget.tag_configure(
            "italic",
            font=(AppTheme.FONT_FAMILY, 12, "italic"),
        )

    def _populate_sections(self):
        if isinstance(self.sections, dict):
            self.section_items = [
                {"title": title, "body": body}
                for title, body in self.sections.items()
            ]
        else:
            self.section_items = list(self.sections)

        for section in self.section_items:
            self.section_listbox.insert(tk.END, self._get_section_list_label(section))

        if self.section_items:
            self.section_listbox.selection_set(0)
            self.show_section()
            return

        self._show_empty_state()

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection:
            return

        section = self.section_items[selection[0]]
        self._display_section(
            self._get_section_title(section),
            self._get_section_body(section),
        )

    def _get_section_list_label(self, section):
        return self._get_section_title(section)

    def _get_section_title(self, section):
        return section["title"]

    def _get_section_body(self, section):
        return section["body"]

    def _show_empty_state(self, title=None, message=None):
        self.text_title.config(text=title or self.empty_title)
        self._clear_section_image()
        self.text_widget.config(state="normal")
        self.text_widget.delete("1.0", tk.END)
        self.text_widget.insert("1.0", message or self.empty_message)
        self.text_widget.config(state="disabled")
        self.text_widget.yview_moveto(0)

    def _display_section(self, title, content):
        self.text_title.config(text=title)
        self.text_widget.config(state="normal")
        self.text_widget.delete("1.0", tk.END)
        self._render_markdown(content)
        self.text_widget.config(state="disabled")
        self.text_widget.yview_moveto(0)

    def _render_markdown(self, content):
        lines = content.splitlines()

        for line in lines:
            stripped_line = line.strip()

            if not stripped_line:
                self.text_widget.insert(tk.END, "\n")
                continue

            if stripped_line.startswith("### "):
                self._insert_inline_markdown(stripped_line[4:], "heading_3")
                self.text_widget.insert(tk.END, "\n")
                continue

            if stripped_line.startswith("## "):
                self._insert_inline_markdown(stripped_line[3:], "heading_2")
                self.text_widget.insert(tk.END, "\n")
                continue

            if stripped_line.startswith("# "):
                self._insert_inline_markdown(stripped_line[2:], "heading_1")
                self.text_widget.insert(tk.END, "\n")
                continue

            unordered_match = re.match(r"^[-*]\s+(.*)$", stripped_line)
            if unordered_match:
                self.text_widget.insert(tk.END, "- ", ("list_item",))
                self._insert_inline_markdown(unordered_match.group(1), "list_item")
                self.text_widget.insert(tk.END, "\n")
                continue

            ordered_match = re.match(r"^(\d+)\.\s+(.*)$", stripped_line)
            if ordered_match:
                self.text_widget.insert(
                    tk.END,
                    f"{ordered_match.group(1)}. ",
                    ("list_item",),
                )
                self._insert_inline_markdown(ordered_match.group(2), "list_item")
                self.text_widget.insert(tk.END, "\n")
                continue

            self._insert_inline_markdown(stripped_line, "paragraph")
            self.text_widget.insert(tk.END, "\n")

    def _insert_inline_markdown(self, text, block_tag):
        parts = re.split(r"(\*\*.*?\*\*|\*.*?\*)", text)

        for part in parts:
            if not part:
                continue

            tags = [block_tag]
            if part.startswith("**") and part.endswith("**") and len(part) >= 4:
                part = part[2:-2]
                tags.append("bold")
            elif part.startswith("*") and part.endswith("*") and len(part) >= 2:
                part = part[1:-1]
                tags.append("italic")

            self.text_widget.insert(tk.END, part, tuple(tags))

    def _set_section_image(self, image_path):
        if not image_path:
            self._clear_section_image()
            return

        try:
            image = tk.PhotoImage(file=image_path)
        except tk.TclError:
            self._clear_section_image()
            return

        scale_factor = max(
            1,
            math.ceil(max(image.width() / 260, image.height() / 220)),
        )
        if scale_factor > 1:
            image = image.subsample(scale_factor, scale_factor)

        self.section_image = image
        self.image_label.config(image=self.section_image)

        if not self.image_label.winfo_manager():
            self.image_label.pack(anchor="center", pady=(0, 10))

    def _clear_section_image(self):
        self.section_image = None
        self.image_label.config(image="")

        if self.image_label.winfo_manager():
            self.image_label.pack_forget()
