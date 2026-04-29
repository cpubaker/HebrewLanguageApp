# Verb Content Instructions

## Scope
- This folder contains source-of-truth verb lessons.
- `flutter_app/assets/learning/input/verbs/` is a synced copy. Do not hand-edit it for durable changes.

## File Rules
- Use stable numbered filenames such as `31_work.md` or `101_believe.md`.
- Do not rename files unless the task explicitly requires it.
- Use UTF-8 without BOM.
- Start each file with a heading. The first heading is the displayed title.
- Avoid empty files.

## Required Section Order
- `## Інфінітив`
- `## Теперішній час`
- `## Минулий час`
- `## Майбутній час`
- `## Наказовий спосіб`

## Canonical Form Order
- Present:
  - masculine singular
  - feminine singular
  - masculine plural
  - feminine plural
- Past:
  - `я (чол.)`
  - `я (жін.)`
  - `ти (чол.)`
  - `ти (жін.)`
  - `він`
  - `вона`
  - `ми`
  - `ви (чол./зміш.)`
  - `ви (жін.)`
  - `вони`
- Future:
  - `я`
  - `ти (чол.)`
  - `ти (жін.)`
  - `він`
  - `вона`
  - `ми`
  - `ви (чол./зміш.)`
  - `ви (жін.)`
  - `вони`
- Imperative:
  - `ти (чол.)`
  - `ти (жін.)`
  - `ви`

## Writing Rules
- Use simple Markdown: headings and bullet lists.
- Keep Hebrew spelling, transliteration, and Ukrainian gloss style consistent inside each file.
- Prefer one canonical form when several variants exist, unless the task explicitly needs multiple variants.
- If a form is rare, missing, or genuinely exceptional, note that explicitly instead of inventing it.
- Favor full morphology over compact summaries.

## Validation
- After verb content changes, run:
  - `python scripts/audit_verb_templates.py`
- Then sync Flutter assets:
  - `powershell -ExecutionPolicy Bypass -File .\\flutter_app\\tool\\sync_learning_assets.ps1`
