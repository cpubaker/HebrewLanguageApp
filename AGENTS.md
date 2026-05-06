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
- Flutter app entry: `flutter_app/lib/main.dart`
- Flutter app root: `flutter_app/lib/app.dart`
- Learning catalog generation: `flutter_app/tool/generate_learning_catalog.ps1`

## Task Routing
- Flutter UI or app flow: inspect `flutter_app/AGENTS.md` and then the relevant files under `flutter_app/lib/`.
- Shared content, lessons, vocabulary, verbs, reading, contexts, media: inspect `flutter_app/assets/learning/input/` first.
- Backend/API work: inspect `backend/` first.

## Validation
- After Flutter code changes:
  - `cd flutter_app`
  - `flutter analyze`
  - `flutter test`
- After shared content changes:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\generate_learning_catalog.ps1`
  - `flutter test`
- After Python tooling, backend, or content validation changes:
  - `python -m unittest discover -s tests -v`

## Notes
- Use the Flutter client as the main product surface.
- Night mode uses a dark earthy palette around deep green, teal, olive, and brown accents; preserve that direction unless the task explicitly redefines the visual system.
