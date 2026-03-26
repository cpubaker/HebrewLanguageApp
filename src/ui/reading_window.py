import re
import tkinter as tk
from tkinter import ttk

from reading_levels import READING_LEVEL_LABELS, READING_LEVELS
from ui.markdown_utils import parse_inline_markdown, render_markdown_content
from ui.text_browser_window import TextBrowserWindow
from ui.theme import AppTheme


class ReadingWindow(TextBrowserWindow):
    DEFAULT_FONT_SIZE = 17
    MIN_FONT_SIZE = 14
    MAX_FONT_SIZE = 23

    def __init__(self, master, reading_sections):
        self.level_vars = {}
        self.filtered_sections = []
        self.selected_section_key = None
        self.search_var = tk.StringVar()
        self.reading_font_size = self.DEFAULT_FONT_SIZE
        self.results_value_label = None
        self.filters_value_label = None
        self.sidebar_count_label = None
        self.text_meta_label = None
        self.level_badge_label = None
        self.preview_label = None
        self.font_size_label = None
        self.decrease_font_button = None
        self.increase_font_button = None
        self.level_filter_button = None
        self.level_filter_popup = None
        self.level_filter_popup_body = None
        self.text_scrollbar = None

        super().__init__(
            master,
            sections=reading_sections,
            window_title="Читання івритом",
            list_label="Тексти",
            empty_title="Розділ читання порожній",
            empty_message="У папці reading поки немає жодного тексту.",
        )

        self.search_var.trace_add("write", self._on_search_changed)

    def _build_layout(self, window_title, list_label):
        self._configure_local_styles()
        self.window.geometry("1120x760")
        self.window.minsize(920, 620)

        container = ttk.Frame(self.window, style="App.TFrame", padding=20)
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(1, weight=1)

        top_bar = ttk.Frame(container, style="Hero.TFrame", padding=(22, 18))
        top_bar.grid(row=0, column=0, sticky="ew", pady=(0, 14))
        top_bar.columnconfigure(0, weight=1)
        top_bar.columnconfigure(1, weight=0)

        heading_frame = ttk.Frame(top_bar, style="Hero.TFrame")
        heading_frame.grid(row=0, column=0, sticky="w")

        ttk.Label(
            heading_frame,
            text="Reader",
            style="Pill.TLabel",
        ).pack(anchor="w")
        ttk.Label(
            heading_frame,
            text=window_title,
            style="HeroTitle.TLabel",
        ).pack(anchor="w", pady=(10, 0))
        ttk.Label(
            heading_frame,
            text="Менше шуму, більше фокусу на тексті.",
            style="HeroBody.TLabel",
        ).pack(anchor="w", pady=(6, 0))

        metrics_frame = ttk.Frame(top_bar, style="Hero.TFrame")
        metrics_frame.grid(row=0, column=1, sticky="e")
        metrics_frame.columnconfigure(0, weight=1)
        metrics_frame.columnconfigure(1, weight=1)

        self.results_value_label = self._build_metric_card(
            metrics_frame,
            column=0,
            title="Тексти",
        )
        self.filters_value_label = self._build_metric_card(
            metrics_frame,
            column=1,
            title="Фільтр",
        )

        content = ttk.Frame(container, style="App.TFrame")
        content.grid(row=1, column=0, sticky="nsew")
        content.columnconfigure(0, weight=0, minsize=300)
        content.columnconfigure(1, weight=1)
        content.rowconfigure(0, weight=1)

        sidebar_card = ttk.Frame(content, style="Card.TFrame", padding=(18, 18))
        sidebar_card.grid(row=0, column=0, sticky="nsew", padx=(0, 14))
        sidebar_card.columnconfigure(0, weight=1)
        sidebar_card.rowconfigure(3, weight=1)

        sidebar_header = ttk.Frame(sidebar_card, style="Card.TFrame")
        sidebar_header.grid(row=0, column=0, sticky="ew")
        sidebar_header.columnconfigure(0, weight=1)

        ttk.Label(
            sidebar_header,
            text="Бібліотека",
            style="SectionTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")

        self.sidebar_count_label = ttk.Label(
            sidebar_header,
            text=list_label,
            style="SurfaceMuted.TLabel",
            padding=(10, 4),
        )
        self.sidebar_count_label.grid(row=0, column=1, sticky="e")

        search_frame = ttk.Frame(sidebar_card, style="Card.TFrame")
        search_frame.grid(row=1, column=0, sticky="ew", pady=(16, 0))
        search_frame.columnconfigure(0, weight=1)

        ttk.Label(
            search_frame,
            text="Пошук",
            style="Muted.TLabel",
        ).grid(row=0, column=0, sticky="w", pady=(0, 6))

        search_input_row = ttk.Frame(search_frame, style="Card.TFrame")
        search_input_row.grid(row=1, column=0, sticky="ew")
        search_input_row.columnconfigure(0, weight=1)

        self.search_entry = ttk.Entry(
            search_input_row,
            textvariable=self.search_var,
        )
        self.search_entry.grid(row=0, column=0, sticky="ew")

        ttk.Button(
            search_input_row,
            text="Очистити",
            style="Secondary.TButton",
            command=self._clear_search,
        ).grid(row=0, column=1, sticky="e", padx=(8, 0))

        filters_row = ttk.Frame(sidebar_card, style="Card.TFrame")
        filters_row.grid(row=2, column=0, sticky="ew", pady=(14, 0))
        filters_row.columnconfigure(0, weight=1)

        ttk.Label(
            filters_row,
            text="Рівні",
            style="Muted.TLabel",
        ).grid(row=0, column=0, sticky="w", pady=(0, 6))

        self.level_filter_button = ttk.Button(
            filters_row,
            text="Усі рівні ▾",
            style="Secondary.TButton",
            command=self._open_level_filter_menu,
        )
        self.level_filter_button.grid(row=1, column=0, sticky="ew")

        for level in READING_LEVELS:
            level_var = tk.BooleanVar(value=True)
            self.level_vars[level] = level_var

        list_frame = ttk.Frame(sidebar_card, style="Card.TFrame")
        list_frame.grid(row=3, column=0, sticky="nsew", pady=(14, 0))
        list_frame.columnconfigure(0, weight=1)
        list_frame.rowconfigure(0, weight=1)

        self.section_listbox = tk.Listbox(
            list_frame,
            font=(AppTheme.FONT_FAMILY, 11),
            activestyle="none",
            exportselection=False,
            height=20,
            width=30,
        )
        AppTheme.style_listbox(self.section_listbox)
        self.section_listbox.configure(selectborderwidth=0)
        self.section_listbox.grid(row=0, column=0, sticky="nsew")
        self.section_listbox.bind("<<ListboxSelect>>", self.show_section)

        section_scrollbar = ttk.Scrollbar(
            list_frame,
            orient="vertical",
            style="App.Vertical.TScrollbar",
            command=self.section_listbox.yview,
        )
        section_scrollbar.grid(row=0, column=1, sticky="ns", padx=(10, 0))
        self.section_listbox.config(yscrollcommand=section_scrollbar.set)

        content_card = ttk.Frame(content, style="Card.TFrame", padding=(18, 18))
        content_card.grid(row=0, column=1, sticky="nsew")
        content_card.columnconfigure(0, weight=1)
        content_card.rowconfigure(1, weight=1)

        reader_header = ttk.Frame(content_card, style="Card.TFrame")
        reader_header.grid(row=0, column=0, sticky="ew")
        reader_header.columnconfigure(0, weight=1)
        reader_header.columnconfigure(1, weight=0)

        header_copy = ttk.Frame(reader_header, style="Card.TFrame")
        header_copy.grid(row=0, column=0, sticky="ew")

        self.text_title = ttk.Label(
            header_copy,
            text="",
            style="Title.TLabel",
            anchor="w",
        )
        self.text_title.pack(anchor="w")

        self.text_meta_label = ttk.Label(
            header_copy,
            text="",
            style="Muted.TLabel",
            justify="left",
        )
        self.text_meta_label.pack(anchor="w", pady=(6, 0))

        self.preview_label = ttk.Label(
            header_copy,
            text="",
            style="SurfaceMuted.TLabel",
            wraplength=520,
            justify="left",
        )
        self.preview_label.pack(anchor="w", pady=(10, 0))

        toolbar = ttk.Frame(reader_header, style="Card.TFrame")
        toolbar.grid(row=0, column=1, sticky="ne", padx=(16, 0))

        self.level_badge_label = ttk.Label(
            toolbar,
            text="",
            style="Pill.TLabel",
        )
        self.level_badge_label.grid(row=0, column=0, columnspan=3, sticky="e")

        self.decrease_font_button = ttk.Button(
            toolbar,
            text="A-",
            style="Secondary.TButton",
            command=lambda: self._change_font_size(-1),
        )
        self.decrease_font_button.grid(row=1, column=0, sticky="e", pady=(12, 0))

        self.font_size_label = ttk.Label(
            toolbar,
            text="",
            style="Muted.TLabel",
        )
        self.font_size_label.grid(row=1, column=1, padx=10, pady=(12, 0))

        self.increase_font_button = ttk.Button(
            toolbar,
            text="A+",
            style="Secondary.TButton",
            command=lambda: self._change_font_size(1),
        )
        self.increase_font_button.grid(row=1, column=2, sticky="e", pady=(12, 0))

        reader_stage = ttk.Frame(content_card, style="Muted.TFrame", padding=(14, 14))
        reader_stage.grid(row=1, column=0, sticky="nsew", pady=(18, 0))
        reader_stage.columnconfigure(0, weight=1)
        reader_stage.rowconfigure(0, weight=1)

        reader_column = tk.Frame(
            reader_stage,
            bg="#FBFCF8",
            highlightbackground=AppTheme.BORDER,
            highlightthickness=1,
            bd=0,
        )
        reader_column.pack(fill="both", expand=True, pady=2)

        self.media_frame = ttk.Frame(reader_column, style="Card.TFrame")
        self.image_label = ttk.Label(self.media_frame, style="CardBody.TLabel")

        text_frame = tk.Frame(reader_column, bg="#FBFCF8")
        text_frame.pack(fill="both", expand=True)
        text_frame.grid_columnconfigure(0, weight=1)
        text_frame.grid_rowconfigure(0, weight=1)

        self.text_widget = tk.Text(
            text_frame,
            wrap="word",
            height=28,
            font=(AppTheme.FONT_FAMILY, self.reading_font_size),
            padx=34,
            pady=28,
            cursor="arrow",
            yscrollcommand=None,
        )
        AppTheme.style_text_widget(self.text_widget)
        self.text_widget.configure(
            bg="#FBFCF8",
            highlightthickness=0,
            spacing1=0,
            spacing2=0,
            spacing3=0,
        )
        self.text_widget.grid(row=0, column=0, sticky="nsew")

        self.text_scrollbar = ttk.Scrollbar(
            text_frame,
            orient="vertical",
            style="App.Vertical.TScrollbar",
            command=self.text_widget.yview,
        )
        self.text_scrollbar.grid(row=0, column=1, sticky="ns", padx=(10, 10), pady=10)
        self.text_widget.config(yscrollcommand=self.text_scrollbar.set)

        self._configure_text_tags()
        self._update_font_controls()

    def _configure_local_styles(self):
        style = ttk.Style(self.window)
        style.configure(
            "ReadingFilterCard.TFrame",
            background=AppTheme.SURFACE,
        )
        style.configure(
            "ReadingFilterTitle.TLabel",
            background=AppTheme.SURFACE,
            foreground=AppTheme.TEXT,
            font=(AppTheme.DISPLAY_FONT_FAMILY, 13, "bold"),
        )
        style.configure(
            "ReadingFilterBody.TLabel",
            background=AppTheme.SURFACE,
            foreground=AppTheme.MUTED_TEXT,
            font=(AppTheme.FONT_FAMILY, 12),
        )
        style.configure(
            "ReadingFilter.TCheckbutton",
            background=AppTheme.SURFACE,
            foreground=AppTheme.TEXT,
            font=(AppTheme.FONT_FAMILY, 12),
            padding=(2, 4),
        )
        style.map(
            "ReadingFilter.TCheckbutton",
            background=[("active", AppTheme.SURFACE)],
            foreground=[("disabled", AppTheme.MUTED_TEXT)],
        )

    def _build_metric_card(self, parent, *, column, title):
        card = ttk.Frame(parent, style="Card.TFrame", padding=(14, 10))
        card.grid(row=0, column=column, sticky="ew", padx=(0, 10) if column == 0 else 0)

        ttk.Label(
            card,
            text=title,
            style="Muted.TLabel",
        ).pack(anchor="w")

        value_label = ttk.Label(
            card,
            text="0",
            style="SectionTitle.TLabel",
            font=(AppTheme.DISPLAY_FONT_FAMILY, 17, "bold"),
        )
        value_label.pack(anchor="w", pady=(4, 0))
        return value_label

    def _populate_sections(self):
        self._apply_filters()

    def _on_search_changed(self, *_args):
        self._apply_filters()

    def _clear_search(self):
        self.search_var.set("")
        self.search_entry.focus_set()

    def _open_level_filter_menu(self):
        if not self.level_filter_button:
            return

        if self.level_filter_popup and self.level_filter_popup.winfo_exists():
            self._close_level_filter_popup()
            return

        self.level_filter_popup = tk.Toplevel(self.window)
        self.level_filter_popup.withdraw()
        self.level_filter_popup.overrideredirect(True)
        self.level_filter_popup.transient(self.window)
        self.level_filter_popup.configure(bg=AppTheme.BORDER)

        popup_card = ttk.Frame(
            self.level_filter_popup,
            style="ReadingFilterCard.TFrame",
            padding=(14, 14),
        )
        popup_card.pack(fill="both", expand=True, padx=1, pady=1)
        popup_card.columnconfigure(0, weight=1)

        ttk.Label(
            popup_card,
            text="Рівні складності",
            style="ReadingFilterTitle.TLabel",
        ).grid(row=0, column=0, sticky="w")
        ttk.Label(
            popup_card,
            text="Можна обрати кілька пунктів підряд.",
            style="ReadingFilterBody.TLabel",
        ).grid(row=1, column=0, sticky="w", pady=(4, 10))

        self.level_filter_popup_body = ttk.Frame(
            popup_card,
            style="ReadingFilterCard.TFrame",
        )
        self.level_filter_popup_body.grid(row=2, column=0, sticky="ew")
        self.level_filter_popup_body.columnconfigure(0, weight=1)

        for index, level in enumerate(READING_LEVELS):
            ttk.Checkbutton(
                self.level_filter_popup_body,
                text=READING_LEVEL_LABELS[level],
                variable=self.level_vars[level],
                command=self._apply_filters,
                style="ReadingFilter.TCheckbutton",
            ).grid(row=index, column=0, sticky="w")

        actions_row = ttk.Frame(popup_card, style="ReadingFilterCard.TFrame")
        actions_row.grid(row=3, column=0, sticky="ew", pady=(12, 0))
        actions_row.columnconfigure(0, weight=1)
        actions_row.columnconfigure(1, weight=1)

        ttk.Button(
            actions_row,
            text="Усі рівні",
            style="Secondary.TButton",
            command=self._toggle_all_levels,
        ).grid(row=0, column=0, sticky="ew", padx=(0, 6))
        ttk.Button(
            actions_row,
            text="Готово",
            style="Secondary.TButton",
            command=self._close_level_filter_popup,
        ).grid(row=0, column=1, sticky="ew", padx=(6, 0))

        self.level_filter_popup.update_idletasks()

        popup_width = max(
            self.level_filter_button.winfo_width(),
            self.level_filter_popup.winfo_reqwidth(),
        )
        popup_height = self.level_filter_popup.winfo_reqheight()
        popup_x = self.level_filter_button.winfo_rootx()
        popup_y = (
            self.level_filter_button.winfo_rooty()
            + self.level_filter_button.winfo_height()
            + 4
        )

        self.level_filter_popup.geometry(f"{popup_width}x{popup_height}+{popup_x}+{popup_y}")
        self.level_filter_popup.deiconify()
        self.level_filter_popup.lift()
        self.level_filter_popup.focus_force()
        self.level_filter_popup.bind("<FocusOut>", self._on_level_filter_focus_out)
        self.level_filter_popup.bind("<Escape>", lambda _event: self._close_level_filter_popup())

    def _close_level_filter_popup(self):
        if self.level_filter_popup and self.level_filter_popup.winfo_exists():
            self.level_filter_popup.destroy()
        self.level_filter_popup = None
        self.level_filter_popup_body = None

    def _on_level_filter_focus_out(self, _event):
        self.window.after(10, self._close_level_filter_popup)

    def _toggle_all_levels(self):
        should_select_all = not all(
            level_var.get() for level_var in self.level_vars.values()
        )

        for level_var in self.level_vars.values():
            level_var.set(should_select_all)

        self._apply_filters()

    def _apply_filters(self):
        active_levels = [
            level for level, level_var in self.level_vars.items() if level_var.get()
        ]
        query = self.search_var.get().strip().lower()
        previous_key = self.selected_section_key

        self.filtered_sections = [
            section
            for section in self.sections
            if section["level"] in active_levels and self._matches_query(section, query)
        ]

        self.section_listbox.delete(0, tk.END)
        for section in self.filtered_sections:
            self.section_listbox.insert(tk.END, self._format_section_label(section))

        self._update_metrics(active_levels)

        if not self.filtered_sections:
            self.selected_section_key = None
            self._show_empty_state(
                title="Нічого не знайдено",
                message=(
                    "Змініть пошук або рівні, щоб побачити доступні тексти для читання."
                ),
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
        self.section_listbox.activate(selected_index)
        self.show_section()

    def _matches_query(self, section, query):
        if not query:
            return True

        haystacks = (
            section["title"].lower(),
            section["body"].lower(),
            READING_LEVEL_LABELS[section["level"]].lower(),
        )
        return any(query in haystack for haystack in haystacks)

    def _update_metrics(self, active_levels):
        total = len(self.filtered_sections)
        all_total = len(self.sections)

        if self.results_value_label:
            self.results_value_label.config(text=f"{total}/{all_total}")

        if self.filters_value_label:
            if len(active_levels) == len(READING_LEVELS):
                filter_text = "Усі"
            elif len(active_levels) == 1:
                filter_text = READING_LEVEL_LABELS[active_levels[0]]
            elif not active_levels:
                filter_text = "0 рівнів"
            else:
                filter_text = f"{len(active_levels)} рівні"
            self.filters_value_label.config(text=filter_text)
            if self.level_filter_button:
                self.level_filter_button.config(text=f"{filter_text} ▾")

        if self.sidebar_count_label:
            noun = "текст" if total == 1 else "текстів"
            self.sidebar_count_label.config(text=f"{total} {noun}")

    def show_section(self, event=None):
        selection = self.section_listbox.curselection()
        if not selection or not self.filtered_sections:
            return

        section = self.filtered_sections[selection[0]]
        self.selected_section_key = self._get_section_key(section)
        self._display_section(
            section["title"],
            section["body"],
            section=section,
        )

    def _display_section(self, title, content, section=None):
        current_section = section
        if current_section is None and self.filtered_sections:
            selection = self.section_listbox.curselection()
            if selection:
                current_section = self.filtered_sections[selection[0]]

        self.text_title.config(text=title)

        if current_section:
            self.level_badge_label.config(
                text=READING_LEVEL_LABELS[current_section["level"]]
            )
            self.text_meta_label.config(text=self._build_content_meta(current_section))
            self.preview_label.config(text=self._build_preview_text(current_section["body"]))
        else:
            self.level_badge_label.config(text="")
            self.text_meta_label.config(text="")
            self.preview_label.config(text="")

        self.text_widget.config(state="normal")
        self.text_widget.delete("1.0", tk.END)
        self._render_markdown(content)
        self.text_widget.config(state="disabled")
        self.text_widget.yview_moveto(0)

    def _show_empty_state(self, title=None, message=None):
        self.text_title.config(text=title or self.empty_title)
        self.text_meta_label.config(text="")
        self.level_badge_label.config(text="")
        self.preview_label.config(text="Пошук і фільтри тепер керують бібліотекою ліворуч.")
        self._clear_section_image()
        self.text_widget.config(state="normal")
        self.text_widget.delete("1.0", tk.END)
        self.text_widget.insert("1.0", message or self.empty_message, ("paragraph",))
        self.text_widget.config(state="disabled")
        self.text_widget.yview_moveto(0)

    def _build_content_meta(self, section):
        paragraph_count = self._count_paragraphs(section["body"])
        line_count = self._count_content_lines(section["body"])
        reading_time = max(1, round(line_count / 11))
        return (
            f"{READING_LEVEL_LABELS[section['level']]} • "
            f"{paragraph_count} абзаців • {reading_time} хв читання"
        )

    def _build_preview_text(self, content):
        normalized_lines = []
        for raw_line in content.splitlines():
            stripped = re.sub(r"^#{1,6}\s+", "", raw_line).strip()
            stripped = re.sub(r"^[-*]\s+", "", stripped)
            stripped = re.sub(r"^\d+\.\s+", "", stripped)
            if stripped:
                normalized_lines.append(stripped)

        preview = " ".join(normalized_lines[:2]).strip()
        if len(preview) > 120:
            preview = f"{preview[:117].rstrip()}..."
        return self._format_bidi_text(preview)

    def _count_content_lines(self, content):
        return sum(1 for line in content.splitlines() if line.strip())

    def _count_paragraphs(self, content):
        return sum(
            1
            for line in content.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )

    def _format_bidi_text(self, text):
        if not self._contains_hebrew(text):
            return text
        return f"\u202B{text}\u202C"

    def _is_glossary_item(self, text):
        if " - " not in text or not self._contains_hebrew(text):
            return False
        hebrew_part, translation_part = text.split(" - ", 1)
        return bool(hebrew_part.strip()) and bool(translation_part.strip())

    def _format_glossary_item(self, text):
        hebrew_part, translation_part = text.split(" - ", 1)
        return f"{self._format_bidi_text(hebrew_part.strip())} - {translation_part.strip()}"

    def _should_wrap_rtl_run(self, block_tag, text):
        return block_tag.endswith("_rtl") or (
            block_tag.startswith("heading_") and self._contains_hebrew(text)
        )

    def _insert_inline_markdown(self, text, block_tag):
        wrap_rtl_run = self._should_wrap_rtl_run(block_tag, text)
        if wrap_rtl_run:
            self.text_widget.insert(tk.END, "\u202B", (block_tag,))

        for segment in parse_inline_markdown(text):
            tags = (block_tag, *segment.tags)
            self.text_widget.insert(tk.END, segment.text, tags)

        if wrap_rtl_run:
            self.text_widget.insert(tk.END, "\u202C", (block_tag,))

    def _change_font_size(self, delta):
        next_size = max(
            self.MIN_FONT_SIZE,
            min(self.MAX_FONT_SIZE, self.reading_font_size + delta),
        )
        if next_size == self.reading_font_size:
            return

        self.reading_font_size = next_size
        self._configure_text_tags()
        self._update_font_controls()

    def _update_font_controls(self):
        if self.font_size_label:
            self.font_size_label.config(text=f"{self.reading_font_size} pt")
        if self.decrease_font_button:
            self.decrease_font_button.config(
                state="disabled" if self.reading_font_size <= self.MIN_FONT_SIZE else "normal"
            )
        if self.increase_font_button:
            self.increase_font_button.config(
                state="disabled" if self.reading_font_size >= self.MAX_FONT_SIZE else "normal"
            )

    def _configure_text_tags(self):
        base_size = self.reading_font_size

        self.text_widget.tag_configure(
            "heading_1",
            font=(AppTheme.DISPLAY_FONT_FAMILY, base_size + 6, "bold"),
            spacing1=8,
            spacing3=10,
            lmargin1=0,
            lmargin2=0,
        )
        self.text_widget.tag_configure(
            "heading_2",
            font=(AppTheme.DISPLAY_FONT_FAMILY, base_size + 2, "bold"),
            spacing1=6,
            spacing3=8,
            lmargin1=0,
            lmargin2=0,
        )
        self.text_widget.tag_configure(
            "heading_3",
            font=(AppTheme.DISPLAY_FONT_FAMILY, base_size + 1, "bold"),
            spacing1=6,
            spacing3=6,
            lmargin1=0,
            lmargin2=0,
        )
        self.text_widget.tag_configure(
            "paragraph",
            font=(AppTheme.FONT_FAMILY, base_size),
            spacing1=2,
            spacing3=14,
            lmargin1=2,
            lmargin2=2,
            rmargin=2,
            justify="left",
        )
        self.text_widget.tag_configure(
            "paragraph_rtl",
            font=(AppTheme.FONT_FAMILY, base_size),
            spacing1=2,
            spacing3=14,
            lmargin1=20,
            lmargin2=20,
            rmargin=20,
            justify="right",
        )
        self.text_widget.tag_configure(
            "list_item",
            font=(AppTheme.FONT_FAMILY, max(base_size - 1, 11)),
            spacing1=2,
            spacing3=8,
            lmargin1=18,
            lmargin2=36,
            rmargin=2,
            justify="left",
        )
        self.text_widget.tag_configure(
            "list_item_rtl",
            font=(AppTheme.FONT_FAMILY, max(base_size - 1, 11)),
            spacing1=2,
            spacing3=8,
            lmargin1=18,
            lmargin2=36,
            rmargin=18,
            justify="right",
        )
        self.text_widget.tag_configure(
            "definition_item",
            font=(AppTheme.FONT_FAMILY, max(base_size - 1, 11)),
            spacing1=2,
            spacing3=8,
            lmargin1=18,
            lmargin2=18,
            rmargin=18,
            justify="right",
        )
        self.text_widget.tag_configure(
            "bold",
            font=(AppTheme.DISPLAY_FONT_FAMILY, base_size, "bold"),
        )
        self.text_widget.tag_configure(
            "italic",
            font=(AppTheme.FONT_FAMILY, base_size, "italic"),
        )

    def _render_markdown(self, content):
        render_markdown_content(
            self.text_widget,
            content,
            render_heading=self._render_heading_block,
            render_unordered_list_item=self._render_unordered_list_item_block,
            render_ordered_list_item=self._render_ordered_list_item_block,
            render_paragraph=self._render_paragraph_block,
        )

    def _render_heading_block(self, block):
        self._insert_inline_markdown(block.text, block.kind)

    def _render_unordered_list_item_block(self, block):
        item_text = block.text
        if self._is_glossary_item(item_text):
            self._insert_inline_markdown(
                self._format_glossary_item(item_text),
                "definition_item",
            )
            return

        tag_name = (
            "list_item_rtl"
            if self._contains_hebrew(item_text)
            else "list_item"
        )
        self.text_widget.insert(tk.END, "- ", (tag_name,))
        self._insert_inline_markdown(item_text, tag_name)

    def _render_ordered_list_item_block(self, block):
        tag_name = (
            "list_item_rtl"
            if self._contains_hebrew(block.text)
            else "list_item"
        )
        self.text_widget.insert(
            tk.END,
            f"{block.ordinal}. ",
            (tag_name,),
        )
        self._insert_inline_markdown(block.text, tag_name)

    def _render_paragraph_block(self, block):
        paragraph_tag = (
            "paragraph_rtl" if self._contains_hebrew(block.text) else "paragraph"
        )
        self._insert_inline_markdown(block.text, paragraph_tag)

    def _contains_hebrew(self, text):
        return bool(re.search(r"[\u0590-\u05FF]", text))

    def _format_section_label(self, section):
        title = section["title"]
        if len(title) > 28:
            title = f"{title[:25].rstrip()}..."
        return f"{title}  ·  {READING_LEVEL_LABELS[section['level']]}"

    def _get_section_key(self, section):
        return (section["level"], section["filename"])
