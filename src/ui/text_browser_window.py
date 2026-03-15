import tkinter as tk
import re


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
        self.empty_title = empty_title
        self.empty_message = empty_message

        self.window = tk.Toplevel(master)
        self.window.title(window_title)
        self.window.geometry("760x480")
        self.window.minsize(680, 420)

        self._build_layout(list_label)
        self._populate_sections()

    def _build_layout(self, list_label):
        container = tk.Frame(self.window, padx=12, pady=12)
        container.pack(fill="both", expand=True)

        self.left_frame = tk.Frame(container)
        self.left_frame.pack(side="left", fill="y", padx=(0, 12))

        right_frame = tk.Frame(container)
        right_frame.pack(side="right", fill="both", expand=True)

        self._build_sidebar_controls(self.left_frame)

        section_label = tk.Label(
            self.left_frame,
            text=list_label,
            font=("Helvetica", 12, "bold"),
        )
        section_label.pack(anchor="w", pady=(0, 8))

        self.section_listbox = tk.Listbox(
            self.left_frame,
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
        self._configure_text_tags()

    def _build_sidebar_controls(self, parent):
        return None

    def _configure_text_tags(self):
        self.text_widget.tag_configure(
            "heading_1",
            font=("Helvetica", 16, "bold"),
            spacing1=10,
            spacing3=6,
        )
        self.text_widget.tag_configure(
            "heading_2",
            font=("Helvetica", 14, "bold"),
            spacing1=8,
            spacing3=4,
        )
        self.text_widget.tag_configure(
            "heading_3",
            font=("Helvetica", 13, "bold"),
            spacing1=6,
            spacing3=4,
        )
        self.text_widget.tag_configure(
            "paragraph",
            font=("Helvetica", 12),
            spacing1=2,
            spacing3=8,
        )
        self.text_widget.tag_configure(
            "list_item",
            font=("Helvetica", 12),
            lmargin1=18,
            lmargin2=36,
            spacing1=2,
            spacing3=4,
        )
        self.text_widget.tag_configure("bold", font=("Helvetica", 12, "bold"))
        self.text_widget.tag_configure("italic", font=("Helvetica", 12, "italic"))

    def _populate_sections(self):
        section_names = list(self.sections.keys())

        for section_name in section_names:
            self.section_listbox.insert(tk.END, section_name)

        if section_names:
            self.section_listbox.selection_set(0)
            self.show_section()
            return

        self._show_empty_state()

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection:
            return

        selected_section = self.section_listbox.get(selection[0])
        content = self.sections[selected_section]

        self._display_section(selected_section, content)

    def _show_empty_state(self, title=None, message=None):
        self.text_title.config(text=title or self.empty_title)
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
