# AGENTS.md

## Purpose
- This repository contains a Hebrew learning app that is now primarily being developed in Flutter.
- The active mobile client lives in `flutter_app/`.
- The legacy Tkinter desktop app in `src/` still exists as a reference implementation and compatibility target for some flows.
- Prefer preserving the local-file content workflow unless a task explicitly targets database or model integrations.

## Primary Working Mode
- Default to the Flutter client unless the user explicitly mentions the desktop app, Tkinter, `src/`, database work, or model experiments.
- For work inside `flutter_app/`, also follow the local instructions in `flutter_app/AGENTS.md`.
- Treat `data/input/` as the durable source of truth for learning content.
- Treat `flutter_app/assets/learning/input/` as synced runtime copies unless the task explicitly targets Flutter asset packaging.

## Primary Entry Points
- Flutter bootstrap: `flutter_app/lib/main.dart`
- Flutter app root: `flutter_app/lib/app.dart`
- Flutter home screen: `flutter_app/lib/screens/home_screen.dart`
- Flutter asset sync script: `flutter_app/tool/sync_learning_assets.ps1`
- Legacy desktop entry point: `src/main.py`
- Legacy runtime composition root: `src/app_runtime.py`

## Project Layout
- `flutter_app/` - primary Flutter client under active development.
- `flutter_app/lib/` - Flutter app code: screens, services, models, theme, and app shell.
- `flutter_app/test/` - Flutter widget and behavior tests.
- `flutter_app/assets/learning/` - bundled learning assets copied from the root content folders for runtime use.
- `data/input/` - source-of-truth learning content shared across app variants.
- `data/input/guide/AGENTS.md` - local instructions for guide lesson structure and writing style.
- `data/input/reading/AGENTS.md` - local instructions for reading lesson content.
- `data/input/verbs/AGENTS.md` - local instructions for verb lesson structure and canonical form order.
- `src/` - legacy Tkinter app and related Python application layers.
- `tests/` - legacy Python tests for path resolution, data loading, and content integrity.
- `src/models/` - model-specific experiments and integrations.
- `src/database/` - SQL scripts and database-related assets.

## Working Rules
- Read the smallest relevant part of the codebase first.
- For Flutter UI or app-flow tasks, inspect `flutter_app/AGENTS.md` and the relevant files under `flutter_app/lib/` first.
- For Flutter loading or persistence tasks, inspect the matching files under `flutter_app/lib/services/` and `flutter_app/lib/models/` first.
- For lesson, vocabulary, verb, reading, context, image, or audio content tasks, inspect `data/input/` first and only edit synced Flutter assets when the task is specifically about asset packaging or temporary debugging.
- When editing files under `data/input/guide/`, follow `data/input/guide/AGENTS.md`.
- When editing files under `data/input/reading/`, follow `data/input/reading/AGENTS.md`.
- When editing files under `data/input/verbs/`, follow `data/input/verbs/AGENTS.md`.
- Do not hand-edit `flutter_app/assets/learning/input/` for durable product changes; the sync script may overwrite those files.
- Preserve UTF-8 encoding for all Hebrew content files.
- Keep numbered lesson filenames stable unless the task explicitly requires renaming.
- Keep image and audio filenames stable when they are used for loader-based matching.
- For legacy desktop tasks, inspect `src/main.py`, `src/app_runtime.py`, and the relevant files under `src/application/`, `src/domain/`, `src/infrastructure/`, or `src/ui/` before editing.
- Prefer business-rule changes in service/model layers before changing UI code in either app.

## Data Conventions
- Learning content source of truth lives under `data/input/`.
- Flutter runtime content under `flutter_app/assets/learning/input/` is a generated copy of the root content.
- Verb, guide, and reading `.md` files are ordered by numeric filename prefixes such as `01_`, `02_`, `03_`.
- Empty lesson files are ignored by the loaders.
- Non-lesson files in guide, reading, and verbs directories are ignored by the loaders.
- Shared flashcard contexts are normalized through `contexts/sentences.json` plus `contexts/word_context_links.json`.
- Missing matching images, audio, or contexts should not break content loading unless the task explicitly changes that behavior.
- In lesson files, the first Markdown heading is preferred as the displayed title.
- If no Markdown heading exists, the first non-empty line is used as the displayed title.

## Validation
- Preferred validation after Flutter code changes:
  - `cd flutter_app`
  - `flutter analyze`
  - `flutter test`
- If Flutter asset loading behavior or shared content changed, also run:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`
- If the task affects on-device or emulator behavior, also run:
  - `cd flutter_app`
  - `flutter run`
- Preferred validation after legacy Python code changes:
  - `python -m unittest discover -s tests -v`
- If a legacy desktop startup, UI wiring, or file-loading path changed, also run:
  - `python src/main.py`
- If `python src/main.py` is blocked by the local Tk/Tcl environment rather than by app code, report that explicitly.

## Safe Defaults For AI Agents
- Assume the user's main working mode is Flutter.
- Assume content should continue to come from synced local assets, not from live services.
- Prefer narrow, vertical Flutter slices over broad refactors.
- Preserve coexistence between the Flutter client and the legacy Tkinter app.
- When unsure about data format, inspect an adjacent example file in the same folder before editing.

## Known Notes
- Use `flutter_app/AGENTS.md` as the detailed operating guide for Flutter work.
- Use the legacy Tkinter app as a behavior reference when product details are unclear.
- Path handling for the Python app remains centralized in `src/app_paths.py`; reuse it instead of hardcoding relative paths.
