# AGENTS.md

## Scope
- This repo is a Hebrew learning app with two clients:
  - `flutter_app/` is the active product.
  - `src/` is the legacy Tkinter app kept as a reference and compatibility target.
- Default to Flutter unless the user explicitly asks for the desktop app, `src/`, DB work, or model experiments.

## Source Of Truth
- Durable learning content lives in `data/input/`.
- `flutter_app/assets/learning/input/` is a synced runtime copy. Do not hand-edit it for permanent changes.
- For content work, prefer the matching source folder under `data/input/` and follow its local `AGENTS.md`:
  - `data/input/AGENTS.md`
  - `data/input/guide/AGENTS.md`
  - `data/input/reading/AGENTS.md`
  - `data/input/verbs/AGENTS.md`

## Working Defaults
- Read the smallest relevant part of the codebase first.
- Keep numbered lesson filenames, media filenames, and stable IDs unchanged unless the task explicitly requires coordinated renaming or migration.
- Preserve UTF-8 for Hebrew content files.
- Do not introduce a second source of truth for learning content unless the task explicitly defines the sync strategy.
- Treat light and night mode as first-class app states for Flutter UI work.
- For theme-related Flutter changes, prefer shared theme tokens and `ThemeData` over screen-local hardcoded light colors.

## Where To Start
- Flutter app entry: `flutter_app/lib/main.dart`
- Flutter app root: `flutter_app/lib/app.dart`
- Flutter asset sync: `flutter_app/tool/sync_learning_assets.ps1`
- Legacy desktop entry: `src/main.py`
- Legacy runtime root: `src/app_runtime.py`

## Task Routing
- Flutter UI or app flow: inspect `flutter_app/AGENTS.md` and then the relevant files under `flutter_app/lib/`.
- Shared content, lessons, vocabulary, verbs, reading, contexts, media: inspect `data/input/` first.
- Legacy desktop work: inspect `src/main.py`, `src/app_runtime.py`, and the relevant `src/` layer before editing.

## Validation
- After Flutter code changes:
  - `cd flutter_app`
  - `flutter analyze`
  - `flutter test`
- After shared content changes:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\sync_learning_assets.ps1`
- After legacy Python code changes:
  - `python -m unittest discover -s tests -v`
- If desktop startup or path wiring changed, also run:
  - `python src/main.py`

## Notes
- Use the Flutter client as the main product surface.
- Use the Tkinter app as a behavior reference when product details are unclear.
- Reuse `src/app_paths.py` for Python-side path handling instead of hardcoding paths.
- Night mode uses a dark earthy palette around deep green, teal, olive, and brown accents; preserve that direction unless the task explicitly redefines the visual system.
