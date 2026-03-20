import tkinter as tk
from tkinter import font as tkfont
from tkinter import ttk


class AppTheme:
    BACKGROUND = "#F4F7F1"
    SURFACE = "#FFFFFF"
    SURFACE_ALT = "#ECF3EA"
    SURFACE_MUTED = "#E2EBDE"
    PRIMARY = "#2E7D32"
    PRIMARY_DARK = "#1F5B24"
    PRIMARY_SOFT = "#DCEED8"
    TEXT = "#1E281E"
    MUTED_TEXT = "#5F6B5F"
    BORDER = "#CCD7C8"
    SUCCESS = "#2E7D32"
    DANGER = "#C62828"
    WARNING = "#A56600"
    SUCCESS_SOFT = "#DDEFD8"
    DANGER_SOFT = "#F7DFDF"

    FONT_FAMILY = "Segoe UI"
    DISPLAY_FONT_FAMILY = "Segoe UI Semibold"

    @classmethod
    def apply(cls, widget):
        style = ttk.Style(widget)

        try:
            style.theme_use("clam")
        except tk.TclError:
            pass

        cls._configure_fonts()

        widget.option_add("*tearOff", False)
        widget.configure(bg=cls.BACKGROUND)

        style.configure(
            ".",
            background=cls.BACKGROUND,
            foreground=cls.TEXT,
            font=(cls.FONT_FAMILY, 11),
        )

        style.configure("TFrame", background=cls.BACKGROUND)
        style.configure("App.TFrame", background=cls.BACKGROUND)
        style.configure("Card.TFrame", background=cls.SURFACE)
        style.configure("Hero.TFrame", background=cls.PRIMARY_SOFT)
        style.configure("Muted.TFrame", background=cls.SURFACE_ALT)

        style.configure("TLabel", background=cls.BACKGROUND, foreground=cls.TEXT)
        style.configure("App.TLabel", background=cls.BACKGROUND, foreground=cls.TEXT)
        style.configure(
            "HeroTitle.TLabel",
            background=cls.PRIMARY_SOFT,
            foreground=cls.TEXT,
            font=(cls.DISPLAY_FONT_FAMILY, 21, "bold"),
        )
        style.configure(
            "HeroBody.TLabel",
            background=cls.PRIMARY_SOFT,
            foreground=cls.MUTED_TEXT,
            font=(cls.FONT_FAMILY, 11),
        )
        style.configure(
            "Title.TLabel",
            background=cls.SURFACE,
            foreground=cls.TEXT,
            font=(cls.DISPLAY_FONT_FAMILY, 19, "bold"),
        )
        style.configure(
            "SectionTitle.TLabel",
            background=cls.SURFACE,
            foreground=cls.TEXT,
            font=(cls.DISPLAY_FONT_FAMILY, 14, "bold"),
        )
        style.configure(
            "Display.TLabel",
            background=cls.SURFACE,
            foreground=cls.PRIMARY_DARK,
            font=(cls.DISPLAY_FONT_FAMILY, 28, "bold"),
        )
        style.configure(
            "CardBody.TLabel",
            background=cls.SURFACE,
            foreground=cls.TEXT,
            font=(cls.FONT_FAMILY, 11),
        )
        style.configure(
            "Muted.TLabel",
            background=cls.SURFACE,
            foreground=cls.MUTED_TEXT,
            font=(cls.FONT_FAMILY, 11),
        )
        style.configure(
            "SurfaceMuted.TLabel",
            background=cls.SURFACE_ALT,
            foreground=cls.MUTED_TEXT,
            font=(cls.FONT_FAMILY, 10),
        )
        style.configure(
            "Pill.TLabel",
            background=cls.PRIMARY_SOFT,
            foreground=cls.PRIMARY_DARK,
            font=(cls.DISPLAY_FONT_FAMILY, 9, "bold"),
            padding=(10, 4),
        )
        style.configure(
            "Success.TLabel",
            background=cls.SURFACE_ALT,
            foreground=cls.SUCCESS,
            font=(cls.DISPLAY_FONT_FAMILY, 11, "bold"),
        )
        style.configure(
            "Danger.TLabel",
            background=cls.SURFACE_ALT,
            foreground=cls.DANGER,
            font=(cls.DISPLAY_FONT_FAMILY, 11, "bold"),
        )
        style.configure(
            "Warning.TLabel",
            background=cls.SURFACE_ALT,
            foreground=cls.WARNING,
            font=(cls.DISPLAY_FONT_FAMILY, 11, "bold"),
        )
        style.configure(
            "Footer.TLabel",
            background=cls.BACKGROUND,
            foreground=cls.MUTED_TEXT,
            font=(cls.FONT_FAMILY, 10),
        )

        style.configure(
            "TButton",
            font=(cls.DISPLAY_FONT_FAMILY, 12, "bold"),
            padding=(18, 12),
            borderwidth=0,
        )
        style.map("TButton", relief=[("pressed", "flat"), ("active", "flat")])

        style.configure("Accent.TButton", background=cls.PRIMARY, foreground="#FFFFFF")
        style.map(
            "Accent.TButton",
            background=[
                ("pressed", cls.PRIMARY_DARK),
                ("active", cls.PRIMARY_DARK),
                ("disabled", cls.SURFACE_MUTED),
            ],
            foreground=[("disabled", cls.MUTED_TEXT)],
        )

        style.configure(
            "Secondary.TButton",
            background=cls.SURFACE_ALT,
            foreground=cls.TEXT,
        )
        style.map(
            "Secondary.TButton",
            background=[
                ("pressed", cls.SURFACE_MUTED),
                ("active", cls.SURFACE_MUTED),
                ("disabled", cls.SURFACE_MUTED),
            ],
            foreground=[("disabled", cls.MUTED_TEXT)],
        )

        style.configure(
            "Icon.TButton",
            background=cls.SURFACE_ALT,
            foreground=cls.PRIMARY_DARK,
            font=("Segoe UI Symbol", 13),
            padding=(10, 6),
        )
        style.map(
            "Icon.TButton",
            background=[
                ("pressed", cls.SURFACE_MUTED),
                ("active", cls.SURFACE_MUTED),
                ("disabled", cls.SURFACE_MUTED),
            ],
            foreground=[
                ("disabled", cls.MUTED_TEXT),
            ],
        )

        style.configure(
            "TCheckbutton",
            background=cls.SURFACE,
            foreground=cls.TEXT,
            font=(cls.FONT_FAMILY, 10),
        )
        style.map(
            "TCheckbutton",
            background=[("active", cls.SURFACE)],
            foreground=[("disabled", cls.MUTED_TEXT)],
        )

        style.configure(
            "TEntry",
            fieldbackground=cls.SURFACE,
            foreground=cls.TEXT,
            padding=(10, 10),
        )
        style.map(
            "TEntry",
            fieldbackground=[("disabled", cls.SURFACE_ALT)],
        )

        style.configure(
            "App.Vertical.TScrollbar",
            background=cls.SURFACE_ALT,
            troughcolor=cls.BACKGROUND,
        )

        return style

    @classmethod
    def style_listbox(cls, widget):
        widget.configure(
            bg=cls.SURFACE,
            fg=cls.TEXT,
            selectbackground=cls.PRIMARY_SOFT,
            selectforeground=cls.TEXT,
            highlightbackground=cls.BORDER,
            highlightcolor=cls.PRIMARY,
            highlightthickness=1,
            borderwidth=0,
            relief="flat",
            activestyle="none",
        )

    @classmethod
    def style_text_widget(cls, widget):
        widget.configure(
            bg=cls.SURFACE,
            fg=cls.TEXT,
            insertbackground=cls.TEXT,
            selectbackground=cls.PRIMARY_SOFT,
            selectforeground=cls.TEXT,
            highlightbackground=cls.BORDER,
            highlightcolor=cls.PRIMARY,
            highlightthickness=1,
            borderwidth=0,
            relief="flat",
        )

    @classmethod
    def style_classic_button(cls, button, *, variant="primary"):
        palette = {
            "primary": (cls.PRIMARY, "#FFFFFF", cls.PRIMARY_DARK),
            "secondary": (cls.SURFACE_ALT, cls.TEXT, cls.SURFACE_MUTED),
            "choice": (cls.SURFACE_ALT, cls.TEXT, cls.PRIMARY_SOFT),
        }
        background, foreground, active_background = palette[variant]

        border_width = 0
        highlight_thickness = 0
        highlight_background = background
        highlight_color = active_background

        if variant == "choice":
            border_width = 1
            highlight_thickness = 1
            highlight_background = cls.BORDER
            highlight_color = cls.PRIMARY

        button.configure(
            bg=background,
            fg=foreground,
            activebackground=active_background,
            activeforeground=foreground,
            relief="flat",
            bd=border_width,
            highlightthickness=highlight_thickness,
            highlightbackground=highlight_background,
            highlightcolor=highlight_color,
            padx=18,
            pady=14,
            font=(cls.DISPLAY_FONT_FAMILY, 12, "bold"),
            cursor="hand2",
            disabledforeground=cls.MUTED_TEXT,
        )

    @classmethod
    def style_choice_button_state(cls, button, state="default"):
        styles = {
            "default": {
                "bg": cls.SURFACE_ALT,
                "fg": cls.TEXT,
                "activebackground": cls.PRIMARY_SOFT,
                "activeforeground": cls.TEXT,
                "highlightbackground": cls.BORDER,
                "highlightcolor": cls.PRIMARY,
            },
            "correct": {
                "bg": cls.SUCCESS_SOFT,
                "fg": cls.PRIMARY_DARK,
                "activebackground": cls.SUCCESS_SOFT,
                "activeforeground": cls.PRIMARY_DARK,
                "highlightbackground": cls.PRIMARY,
                "highlightcolor": cls.PRIMARY,
            },
            "wrong": {
                "bg": cls.DANGER_SOFT,
                "fg": cls.DANGER,
                "activebackground": cls.DANGER_SOFT,
                "activeforeground": cls.DANGER,
                "highlightbackground": cls.DANGER,
                "highlightcolor": cls.DANGER,
            },
            "disabled": {
                "bg": cls.SURFACE,
                "fg": cls.MUTED_TEXT,
                "activebackground": cls.SURFACE,
                "activeforeground": cls.MUTED_TEXT,
                "highlightbackground": cls.BORDER,
                "highlightcolor": cls.BORDER,
            },
        }

        button.configure(**styles[state])

    @classmethod
    def _configure_fonts(cls):
        named_fonts = {
            "TkDefaultFont": {"family": cls.FONT_FAMILY, "size": 10},
            "TkTextFont": {"family": cls.FONT_FAMILY, "size": 11},
            "TkHeadingFont": {"family": cls.DISPLAY_FONT_FAMILY, "size": 14},
            "TkMenuFont": {"family": cls.FONT_FAMILY, "size": 10},
            "TkCaptionFont": {"family": cls.FONT_FAMILY, "size": 10},
        }

        for font_name, settings in named_fonts.items():
            try:
                tkfont.nametofont(font_name).configure(**settings)
            except tk.TclError:
                continue
