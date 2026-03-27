# Guide Content Instructions

## Purpose
- This folder contains the active numbered reference articles for the local Hebrew learning app.
- The guide is a reference module: it explains rules, forms, patterns, contrasts, and typical mistakes.
- The guide is not the place for full lesson flow, drills, spaced repetition, or teaching methodology.
- Files here should stay simple for the Tkinter guide viewer to load and render.

## Current Scope
- Active guide content lives directly in this folder as numbered Markdown files from `01_...` onward.
- This folder should contain only:
  - active numbered guide articles;
  - this helper file `AGENTS.md`.
- Do not keep temporary merge files, split drafts, lesson candidates, or archived guide versions inside `data/input/guide/`.
- If archival material is ever needed again, keep it outside the active guide directory.

## What Counts As A Guide Article
- Guide files should use numbered names such as `01_intro_alphabet.md` or `23_basic_prepositions.md`.
- Keep existing lesson numbers and filenames stable unless a structural change explicitly requires renumbering.
- Use UTF-8 encoding.

## Required File Shape
- Start the file with a Markdown heading like `# Topic Title`.
- The first heading is used as the displayed section title.
- Put the article content after the title.
- Empty files are treated as missing content and should be avoided.

## Reference-First Writing Style
- Write in clear Ukrainian for a learner who may rely heavily on this app as a reference.
- Optimize for clarity, consistency, and quick lookup rather than for motivational teaching flow.
- Prefer short sections with `##` and `###` headings, short paragraphs, and simple bullet lists.
- Lead with the rule, model, or contrast first; then show short examples.
- When useful, introduce Hebrew examples together with transliteration and Ukrainian meaning.
- Keep examples concrete and compact. Prefer examples that demonstrate one pattern at a time.

## Recommended Article Template
- A guide article should usually follow this shape:
- `# Назва теми`
- `Коротко`:
  1-3 речення про те, що це за явище і навіщо воно потрібне.
- `## Основна модель`:
  базове правило, шаблон, або центральна ідея теми.
- `## Форми / варіанти`:
  форми, контрасти, типові конструкції, або часті винятки.
- `## Приклади`:
  короткі приклади з послідовною подачею.
- `## Типові помилки`:
  особливо цінно для тем, де україномовний користувач легко калькує рідну мову.
- `## Пов’язані теми`:
  коротке завершення з посиланням за змістом на інші теми.

## What Belongs Outside The Guide
- Do not turn guide articles into full lessons with multi-step learning flow.
- Do not add blocks like `Як краще це вчити`, `Добра вправа`, `Після цього уроку...`, or mini-dialogue sections unless the user explicitly asks for a lesson-style format.
- Avoid building the article around drills, memorization routines, or homework-style tasks.
- Future `Lessons` should carry integrated practice and learning progression.
- Future `Exercises` should carry drills, review, and active recall tasks.

## Formatting Rules
- Use only simple Markdown that the app already renders well: headings, paragraphs, and lists.
- Avoid HTML, tables, and complex Markdown features.
- Keep spacing clean and readable.
- Keep list formatting consistent inside one file.
- Keep Hebrew, transliteration, and Ukrainian gloss formatting consistent inside one file.

## Consistency Rules
- Stay aligned with neighboring guide files in tone and difficulty.
- Do not turn one file into several unrelated topics.
- Prefer one central topic per file.
- If a topic is broad, organize it into tightly-scoped subsections instead of mixing separate grammar themes.
- If you add examples, keep Hebrew spelling, transliteration, and Ukrainian glosses consistent inside the file.
- If a topic contains forms, prefer a stable order when possible: masculine singular, feminine singular, masculine plural, feminine plural; or `я / ти / він / вона / ми / ви / вони`, depending on the topic.

## Editorial Priorities
- Favor correctness over stylistic flourish.
- Favor short, retrievable explanations over repeated paraphrasing.
- Favor comparison and contrast where learners commonly confuse forms.
- Explicitly point out common Ukrainian-to-Hebrew interference when it helps prevent mistakes.
- Treat the guide as a durable reference map of the language, not as a lesson script.

## Support Files
- This folder may contain helper files like this `AGENTS.md`.
- Helper files are for contributors and should not be treated as lessons.
