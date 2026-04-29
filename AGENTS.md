# AGENTS.md

## Scope
- This repo is a Hebrew learning app whose active product is the Flutter client in `flutter_app/`.
- `src/` is the frozen legacy Tkinter app. Keep it only as a temporary behavior reference while the desktop retirement work is in progress.
- Do not add new product behavior to the desktop app. If a user explicitly asks for desktop work, clarify whether it is a critical retirement blocker before editing `src/`.
- Python DB work, backend tooling, content tooling, and model experiments may still be maintained when they are independent of the Tkinter UI.

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
- In Flutter night mode, avoid pure white text; use shared warm muted theme tokens for foreground colors.

## Where To Start
- Flutter app entry: `flutter_app/lib/main.dart`
- Flutter app root: `flutter_app/lib/app.dart`
- Flutter asset sync: `flutter_app/tool/sync_learning_assets.ps1`
- Desktop retirement plan: `docs/desktop_retirement_plan.md`
- Legacy desktop reference entry: `src/main.py`
- Legacy desktop reference runtime root: `src/app_runtime.py`

## Task Routing
- Flutter UI or app flow: inspect `flutter_app/AGENTS.md` and then the relevant files under `flutter_app/lib/`.
- Shared content, lessons, vocabulary, verbs, reading, contexts, media: inspect `data/input/` first.
- Desktop behavior research: inspect `src/main.py`, `src/app_runtime.py`, and the relevant `src/` layer, but prefer implementing any needed product behavior in Flutter.
- Desktop retirement work: follow `docs/desktop_retirement_plan.md`.

## Validation
- After Flutter code changes:
  - `cd flutter_app`
  - `flutter analyze`
  - `flutter test`
- After shared content changes:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\sync_learning_assets.ps1`
- After Python tooling, backend, or content validation changes:
  - `python -m unittest discover -s tests -v`
- If frozen desktop startup or path wiring changed for a retirement blocker, also run:
  - `python src/main.py`

## Notes
- Use the Flutter client as the main product surface.
- Use the Tkinter app only as a temporary behavior reference when product details are unclear.
- Reuse `src/app_paths.py` for Python-side path handling instead of hardcoding paths.
- Night mode uses a dark earthy palette around deep green, teal, olive, and brown accents; preserve that direction unless the task explicitly redefines the visual system.
