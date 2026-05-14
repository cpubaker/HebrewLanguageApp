# Verb Content Instructions

## Scope
- Canonical verb lessons for the Flutter client.

## File Rules
- Use stable numbered filenames such as `31_work.md`; do not rename unless requested.
- Use UTF-8 without BOM, start with a heading, and avoid empty files.
- The first heading is the displayed title.
- Use simple Markdown: headings and bullet lists.

## Required Section Order
- `## Інфінітив`
- `## Теперішній час`
- `## Минулий час`
- `## Майбутній час`
- `## Наказовий спосіб`

## Canonical Form Order
- Present: masculine singular; feminine singular; masculine plural; feminine plural.
- Past: `я (чол.)`; `я (жін.)`; `ти (чол.)`; `ти (жін.)`; `він`; `вона`; `ми`; `ви (чол./зміш.)`; `ви (жін.)`; `вони`.
- Future: `я`; `ти (чол.)`; `ти (жін.)`; `він`; `вона`; `ми`; `ви (чол./зміш.)`; `ви (жін.)`; `вони`.
- Imperative: `ти (чол.)`; `ти (жін.)`; `ви`.

## Writing Rules
- Keep Hebrew spelling, transliteration, and Ukrainian gloss style consistent inside each file.
- Prefer one canonical form when variants exist unless the task explicitly needs multiple variants.
- If a form is rare, missing, or genuinely exceptional, note that instead of inventing it.
- Favor full morphology over compact summaries.

## Validation
- After verb content changes, run `python scripts/audit_verb_templates.py`.
- If generated lesson catalogs are affected, regenerate them before Flutter tests.
