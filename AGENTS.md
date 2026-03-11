# AGENTS.md

## Purpose
- This repository contains a desktop Hebrew learning app.
- The current lightweight app is a Tkinter UI that loads local learning content from `data/input/`.
- When making changes, prefer preserving the existing local-file workflow unless the task explicitly targets database or model integrations.

## Primary Entry Point
- Main app entry point: `src/Main.py`
- Expected behavior: the app should start without errors when launched from the project root.
- Typical launch command from the repository root:
  - `python src/Main.py`

## Project Layout
- `src/Main.py` - Tkinter bootstrap and main loop.
- `src/ui/` - UI windows and application screens.
- `src/data_service.py` - loading and saving local JSON/TXT content.
- `src/app_paths.py` - path resolution for project data and assets.
- `data/input/hebrew_words.json` - core vocabulary data.
- `data/input/guide/` - guide sections stored as numbered `.txt` files.
- `data/input/verbs/` - verb lessons stored as numbered `.txt` files.
- `data/output/` - generated or model output artifacts; avoid treating this as source of truth.
- `src/models/` - model-specific experiments and integrations.
- `src/database/` - SQL scripts and database-related assets.

## Working Rules
- Read the smallest relevant part of the codebase first. Do not rescan the whole repository if the task is clearly limited to one area.
- For verb-content tasks, inspect `data/input/verbs/` first and only open code files if format or behavior is unclear.
- For guide-content tasks, inspect `data/input/guide/` first.
- For startup, file-loading, or missing-path issues, inspect `src/Main.py`, `src/app_paths.py`, and `src/data_service.py` first.
- Preserve UTF-8 encoding for all Hebrew content files.
- Keep numbered lesson filenames stable unless the task explicitly requires renaming.
- Do not change text-file structure casually; UI logic depends on simple parsing:
  - first line = section title
  - remaining lines = section body
- If changing file paths or data-loading behavior, verify that `python src/Main.py` still works.

## Data Conventions
- Verb and guide `.txt` files are ordered by filename prefix such as `01_`, `02_`, `03_`.
- Empty `.txt` files are ignored by the loader.
- Non-`.txt` files in guide/verb directories are ignored by the loader.
- In text section files, the first non-empty line acts as the displayed title.

## Safe Defaults For AI Agents
- Assume the user's main working mode is the local Tkinter app unless they explicitly mention database, OpenAI, or local model experiments.
- Prefer fixes that keep the app runnable with existing local data files.
- Prefer narrow edits over cross-project refactors.
- When unsure about data format, inspect an adjacent example file in the same folder before editing.

## Validation
- Minimum validation after code changes affecting startup, UI wiring, or file loading:
  - run `python src/Main.py`
- Minimum validation after changing local data files:
  - confirm the target file still follows the title/body text format
  - if relevant, run `python src/Main.py`

## Known Notes
- The user refers to the entry point as `main.py`, but in this repository the actual file is `src/Main.py`.
- Path handling is centralized in `src/app_paths.py`; reuse it instead of hardcoding relative paths in multiple places.
