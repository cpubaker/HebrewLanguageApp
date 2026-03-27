# Reading Content Instructions

## Purpose
- This folder contains numbered reading lessons for the local Hebrew learning app.
- Lessons should stay easy for the Tkinter reading viewer to load and render.
- Keep changes narrow and aligned with the neighboring lessons in the same level folder.

## What Counts As A Lesson
- Lesson files should use numbered names such as `01_yosi_goes_to_school.md` or `03_fish_market.md`.
- Keep existing lesson numbers and filenames stable unless a rename is explicitly required.
- Use UTF-8 encoding.

## Required File Shape
- Start each lesson with a Markdown heading like `# Lesson Title`.
- The first heading is used as the displayed lesson title.
- Put the reading text directly after the title.
- After the reading text, add supporting sections only when they match the local pattern already used in that level.
- Empty lesson files are treated as missing content and should be avoided.

## Formatting Rules
- Use simple Markdown only: headings, paragraphs, and lists.
- Avoid HTML, tables, and complex Markdown features.
- Keep spacing clean and readable.
- Do not rename helper files like this `AGENTS.md` into numbered lesson files.

## Level Guidance
- `beginner/`: keep sentences short, concrete, and highly frequent in vocabulary and grammar.
- `pre-intermediate/`: allow longer sentences and more topic-specific vocabulary, but keep the text readable without advanced syntax.
- `intermediate/` and above: vocabulary may be broader and the text may contain denser descriptions, but it should still read naturally and stay focused on one main topic.

## Hebrew Text Rules
- Preserve natural, correct Hebrew.
- Stay consistent inside each file with spelling, terminology, and translation style.
- Reading lessons under `beginner/` must use Hebrew diacritics (nikkud) in the Hebrew body text.
- Reading lessons under `beginner/` must also use nikkud in Hebrew vocabulary items and Hebrew verb entries when such sections are present.
- For `pre-intermediate/` and higher levels, nikkud is optional unless the task explicitly asks for it.

## Supporting Sections
- Follow adjacent files before inventing a new lesson shape.
- If the level commonly uses sections like `## Основні слова` or `## Нові дієслова`, keep those headings and keep the list focused on the text.
- Do not overload one lesson with too many unrelated glossary items.

## Content Safety
- Keep one lesson centered on one clear situation, topic, or scene.
- Do not mix multiple unrelated themes into one reading.
- Prefer vocabulary and grammar that match the intended level rather than forcing advanced wording.

## Support Files
- This folder may also contain helper files like this `AGENTS.md`.
- Helper files are for contributors and should not be treated as lessons.
