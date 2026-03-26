from dataclasses import dataclass
import re
import tkinter as tk


INLINE_MARKDOWN_PATTERN = re.compile(r"(\*\*.*?\*\*|\*.*?\*)")
UNORDERED_LIST_PATTERN = re.compile(r"^[-*]\s+(.*)$")
ORDERED_LIST_PATTERN = re.compile(r"^(\d+)\.\s+(.*)$")


@dataclass(frozen=True)
class InlineMarkdownSegment:
    text: str
    tags: tuple[str, ...] = ()


@dataclass(frozen=True)
class MarkdownBlock:
    kind: str
    text: str = ""
    ordinal: str | None = None


def parse_inline_markdown(text):
    segments = []

    for part in INLINE_MARKDOWN_PATTERN.split(text):
        if not part:
            continue

        tags = ()
        if part.startswith("**") and part.endswith("**") and len(part) >= 4:
            part = part[2:-2]
            tags = ("bold",)
        elif part.startswith("*") and part.endswith("*") and len(part) >= 2:
            part = part[1:-1]
            tags = ("italic",)

        if part:
            segments.append(InlineMarkdownSegment(text=part, tags=tags))

    return segments


def parse_markdown_block(line):
    stripped_line = line.strip()
    if not stripped_line:
        return MarkdownBlock(kind="blank")

    if stripped_line.startswith("### "):
        return MarkdownBlock(kind="heading_3", text=stripped_line[4:])

    if stripped_line.startswith("## "):
        return MarkdownBlock(kind="heading_2", text=stripped_line[3:])

    if stripped_line.startswith("# "):
        return MarkdownBlock(kind="heading_1", text=stripped_line[2:])

    unordered_match = UNORDERED_LIST_PATTERN.match(stripped_line)
    if unordered_match:
        return MarkdownBlock(kind="unordered_list_item", text=unordered_match.group(1))

    ordered_match = ORDERED_LIST_PATTERN.match(stripped_line)
    if ordered_match:
        return MarkdownBlock(
            kind="ordered_list_item",
            text=ordered_match.group(2),
            ordinal=ordered_match.group(1),
        )

    return MarkdownBlock(kind="paragraph", text=stripped_line)


def render_markdown_content(
    text_widget,
    content,
    *,
    render_heading,
    render_unordered_list_item,
    render_ordered_list_item,
    render_paragraph,
):
    for line in content.splitlines():
        block = parse_markdown_block(line)

        if block.kind == "blank":
            text_widget.insert(tk.END, "\n")
            continue

        if block.kind in {"heading_1", "heading_2", "heading_3"}:
            render_heading(block)
            text_widget.insert(tk.END, "\n")
            continue

        if block.kind == "unordered_list_item":
            render_unordered_list_item(block)
            text_widget.insert(tk.END, "\n")
            continue

        if block.kind == "ordered_list_item":
            render_ordered_list_item(block)
            text_widget.insert(tk.END, "\n")
            continue

        render_paragraph(block)
        text_widget.insert(tk.END, "\n")
