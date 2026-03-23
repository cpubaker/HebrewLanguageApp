# AGENTS.md

## Purpose
- This repository contains a desktop Hebrew learning app.
- The current lightweight app is a Tkinter UI that loads local learning content from `data/input/`.
- When making changes, prefer preserving the existing local-file workflow unless the task explicitly targets database or model integrations.

## Primary Entry Point
- Main app entry point: `src/main.py`
- Expected behavior: the app should start without errors when launched from the project root.
- Typical launch command from the repository root:
  - `python src/main.py`

## Project Layout
- `src/main.py` - Tkinter bootstrap and main loop.
- `src/ui/` - UI windows and application screens.
- `src/data_service.py` - loading and saving local JSON/TXT content.
- `src/app_paths.py` - path resolution for project data and assets.
- `tests/` - automated test suite for path resolution, data loading, and content integrity checks.
- `data/input/hebrew_words.json` - core vocabulary data.
- `data/input/contexts/` - shared sentence contexts and word-to-context links for flashcards.
- `data/input/contexts/sentences.json` - shared context bank stored once per sentence.
- `data/input/contexts/word_context_links.json` - mapping from stable word ids to reusable context sentence ids.
- `data/input/guide/` - guide sections stored as numbered `.md` files.
- `data/input/guide/AGENTS.md` - local instructions for guide lesson structure, formatting, and writing style.
- `data/input/audio/` - local learning audio grouped by content type.
- `data/input/audio/verbs/` - verb pronunciations stored as `.mp3` files.
- `data/input/images/` - local learning images grouped by content type.
- `data/input/images/verbs/` - verb illustrations stored as `.png` files.
- `data/input/images/words/` - word illustrations stored as `.png` files.
- `data/input/images/reading/` - reading illustrations stored as `.png` files.
- `data/input/reading/` - reading lessons stored as numbered `.md` files.
- `data/input/verbs/` - verb lessons stored as numbered `.md` files.
- `data/output/` - generated or model output artifacts; avoid treating this as source of truth.
- `src/models/` - model-specific experiments and integrations.
- `src/database/` - SQL scripts and database-related assets.

## Tests
- Automated tests live in `tests/`.
- Run the full test suite from the repository root with:
  - `python -m unittest discover -s tests -v`
- After finishing any code or content change, prefer running the full test suite as a final verification step.
- If a change affects startup, UI wiring, file loading, or path resolution, run both:
  - `python -m unittest discover -s tests -v`
  - `python src/main.py`

## Working Rules
- Read the smallest relevant part of the codebase first. Do not rescan the whole repository if the task is clearly limited to one area.
- For verb-content tasks, inspect `data/input/verbs/` first and only open code files if format or behavior is unclear.
- For guide-content tasks, inspect `data/input/guide/` first.
- When editing files under `data/input/guide/`, follow the local `data/input/guide/AGENTS.md` instructions as well.
- For reading-content tasks, inspect `data/input/reading/` first and only open code files if format or behavior is unclear.
- For image-related tasks, inspect the matching folder under `data/input/images/` first and only open code files if naming or loading behavior is unclear.
- For audio-related tasks, inspect the matching folder under `data/input/audio/` first and only open code files if naming or playback behavior is unclear.
- For flashcard-context tasks, inspect `data/input/contexts/` first and only open code files if context resolution or rendering behavior is unclear.
- For startup, file-loading, or missing-path issues, inspect `src/main.py`, `src/app_paths.py`, and `src/data_service.py` first.
- Preserve UTF-8 encoding for all Hebrew content files.
- Reading lessons under `data/input/reading/beginner/` must use Hebrew diacritics (nikkud) in the Hebrew body text and in Hebrew vocabulary/verb entries unless the task explicitly says otherwise.
- Keep numbered lesson filenames stable unless the task explicitly requires renaming.
- Keep image filenames stable when they are used for loader-based matching.
- Do not change lesson file structure casually; UI logic expects either:
  - first Markdown heading = section title
  - or first non-empty line = section title
  - remaining content = section body rendered with basic Markdown support
- If changing file paths or data-loading behavior, verify that `python src/main.py` still works.

## Data Conventions
- Verb, guide, and reading `.md` files are ordered by filename prefix such as `01_`, `02_`, `03_`.
- Empty lesson files are ignored by the loader.
- Non-lesson files in guide/reading/verb directories are ignored by the loader.
- Images for learning content live under `data/input/images/`.
- Audio for learning content lives under `data/input/audio/`.
- Shared flashcard contexts live under `data/input/contexts/`.
- Verb images are currently expected in `data/input/images/verbs/` as `.png` files.
- Verb audio is currently expected in `data/input/audio/verbs/` as `.mp3` files.
- Flashcard contexts are normalized as shared sentences plus a separate word-to-context mapping; do not duplicate full sentence text inside each word record unless the task explicitly requires that structure.
- Verb image matching currently follows the lesson filename stem without the numeric prefix:
  - `01_walk.md` -> `walk.png`
  - `06_give.md` -> `give.png`
- Verb audio matching follows the same lesson filename stem without the numeric prefix:
  - `01_walk.md` -> `walk.mp3`
  - `06_give.md` -> `give.mp3`
- Missing matching images should not break loading; the lesson should still remain available without an illustration.
- Missing matching audio should not break loading; the lesson should still remain available without pronunciation playback.
- Missing matching contexts should not break loading; a flashcard should still remain usable even if no linked context is found.
- In lesson files, the first Markdown heading is preferred as the displayed title.
- If no Markdown heading exists, the first non-empty line is used as the displayed title.

## Safe Defaults For AI Agents
- Assume the user's main working mode is the local Tkinter app unless they explicitly mention database, OpenAI, or local model experiments.
- Prefer fixes that keep the app runnable with existing local data files.
- Prefer narrow edits over cross-project refactors.
- When unsure about data format, inspect an adjacent example file in the same folder before editing.

## Validation
- Preferred final validation after any change:
  - run `python -m unittest discover -s tests -v`
- Minimum validation after code changes affecting startup, UI wiring, or file loading:
  - run `python -m unittest discover -s tests -v`
  - run `python src/main.py`
- Minimum validation after changing local data files:
  - run `python -m unittest discover -s tests -v`
  - confirm the target file still follows the title/body text format
  - for `guide`, `reading`, or `verbs` content-only edits, running `python src/main.py` is optional unless loading behavior was changed
  - if relevant, run `python src/main.py`

## Known Notes
- Path handling is centralized in `src/app_paths.py`; reuse it instead of hardcoding relative paths in multiple places.

