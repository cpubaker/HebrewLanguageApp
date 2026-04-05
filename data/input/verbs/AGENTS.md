# Verb Content Instructions

## Purpose
- This folder contains the source-of-truth verb lessons for the Hebrew learning app.
- Verb files here are durable learning content, not generated runtime copies.
- Keep changes narrow and aligned with the canonical full-form verb template.

## What Counts As A Verb Lesson
- Verb files should use stable numbered names such as `31_work.md` or `101_believe.md`.
- Keep existing lesson numbers and filenames stable unless a rename is explicitly required.
- Use UTF-8 encoding without BOM.

## Source Of Truth
- Edit files in `data/input/verbs/` for durable content changes.
- Treat `flutter_app/assets/learning/input/verbs/` as synced copies created by the asset sync script.
- Do not hand-edit the Flutter asset copies for permanent verb content updates.

## Required File Shape
- Start each file with a Markdown heading like `# Працювати`.
- The first heading is used as the displayed lesson title.
- Use this section order for every durable verb lesson:
- `## Інфінітив`
- `## Теперішній час`
- `## Минулий час`
- `## Майбутній час`
- `## Наказовий спосіб`
- Do not replace the full template with compact sections such as `## Часті форми` or `## Короткі приклади`.
- Empty files are treated as missing content and should be avoided.

## Canonical Form Order
- In `## Теперішній час`, keep this order:
- чоловічий рід, однина
- жіночий рід, однина
- чоловічий рід, множина
- жіночий рід, множина
- In `## Минулий час`, keep this order:
- я (чол.)
- я (жін.)
- ти (чол.)
- ти (жін.)
- він
- вона
- ми
- ви (чол./зміш.)
- ви (жін.)
- вони
- In `## Майбутній час`, keep this order:
- я
- ти (чол.)
- ти (жін.)
- він
- вона
- ми
- ви (чол./зміш.)
- ви (жін.)
- вони
- In `## Наказовий спосіб`, keep this order:
- (ти, чол.)
- (ти, жін.)
- (ви)

## Formatting Rules
- Use simple Markdown only: headings and bullet lists.
- Keep one blank line between headings and lists for readability.
- Keep Hebrew spelling, transliteration, and Ukrainian gloss style consistent inside each file.
- Use the stress mark consistently and avoid mechanical apostrophes when the vowel sequence is already clear in Ukrainian transliteration.
- Do not add extra narrative sections unless the task explicitly asks for them.
- If a form is rare, irregular, or has multiple acceptable variants, prefer one canonical form and stay consistent.

## Content Priorities
- Favor morphological completeness over short example-driven summaries.
- Preserve the full table-like structure even for very common or irregular verbs.
- When reconstructing a verb entry, verify forms against a reliable conjugation source before editing.
- If a verb is genuinely missing an imperative or has a special-case paradigm, note that explicitly instead of silently inventing a form.

## Validation
- After changing verb content, run:
- `python scripts/audit_verb_templates.py`
- If verb source files changed, also sync Flutter assets:
- `powershell -ExecutionPolicy Bypass -File .\flutter_app\tool\sync_learning_assets.ps1`

## Support Files
- This folder may also contain helper files like this `AGENTS.md`.
- Helper files are for contributors and should not be treated as lessons.
