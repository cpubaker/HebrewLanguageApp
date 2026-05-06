# AGENTS.md

## Scope
- This repo is a Hebrew learning app whose active product is the Flutter client in `flutter_app/`.
- Python code in the repo is backend, content tooling, validation, or generation code.

## Source Of Truth
- Durable learning content lives in `flutter_app/assets/learning/input/`.
- For content work, follow the matching local `AGENTS.md`:
  - `flutter_app/assets/learning/input/AGENTS.md`
  - `flutter_app/assets/learning/input/guide/AGENTS.md`
  - `flutter_app/assets/learning/input/reading/AGENTS.md`
  - `flutter_app/assets/learning/input/verbs/AGENTS.md`

## Working Defaults
- Read the smallest relevant part of the codebase first.
- Keep numbered lesson filenames, media filenames, and stable IDs unchanged unless the task explicitly requires coordinated renaming or migration.
- Preserve UTF-8 for Hebrew content files.
- Do not introduce a second source of truth for learning content unless the task explicitly defines the sync strategy.
- Treat light and night mode as first-class app states for Flutter UI work.
- For theme-related Flutter changes, prefer shared theme tokens and `ThemeData` over screen-local hardcoded light colors.
- In Flutter night mode, avoid pure white text; use shared warm muted theme tokens for foreground colors.

## Where To Start
- AI navigation map: `docs/ai_map.md`
- Generated content index: `docs/content_index.json`
- Flutter app entry: `flutter_app/lib/main.dart`
- Flutter app root: `flutter_app/lib/app.dart`
- Learning catalog generation: `flutter_app/tool/generate_learning_catalog.ps1`

## Local Flutter Environment
- On this workstation, Flutter SDK lives at `C:\src\Flutter\flutter`.
- Prefer the explicit Flutter command path when automation might have a different PATH:
  `C:\src\Flutter\flutter\bin\flutter.bat`.
- In Codex, Flutter commands may need elevated permission because Flutter writes to
  SDK cache/lock files outside the repo, especially
  `C:\src\Flutter\flutter\bin\cache\lockfile`.
- If `flutter --version`, `flutter analyze`, or `flutter test` time out inside
  Codex, first suspect sandbox access to the SDK cache, not a project failure.
- An Android emulator is often already running locally; that is expected.

## Task Routing
- Flutter UI or app flow: inspect `flutter_app/AGENTS.md` and then the relevant files under `flutter_app/lib/`.
- Shared content, lessons, vocabulary, verbs, reading, contexts, media: inspect `flutter_app/assets/learning/input/` first.
- Backend/API work: inspect `backend/` first.

## Validation
- After Flutter code changes:
  - `cd flutter_app`
  - `C:\src\Flutter\flutter\bin\flutter.bat analyze`
  - `C:\src\Flutter\flutter\bin\flutter.bat test`
- After shared content changes:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\generate_learning_catalog.ps1`
  - `cd ..`
  - `python scripts\\generate_content_index.py`
  - `python -m unittest discover -s tests -v`
- After Python tooling, backend, or content validation changes:
  - `python -m unittest discover -s tests -v`

## Notes
- Use the Flutter client as the main product surface.
- Night mode uses a dark earthy palette around deep green, teal, olive, and brown accents; preserve that direction unless the task explicitly redefines the visual system.
