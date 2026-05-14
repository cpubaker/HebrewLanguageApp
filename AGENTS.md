# AGENTS.md

## Scope
- Active product: Flutter client in `flutter_app/`.
- Python code is backend, content tooling, validation, or generation.
- Durable learning content lives in `flutter_app/assets/learning/input/`.

## Routing
- Flutter UI/app flow: read `flutter_app/AGENTS.md`, then relevant files under `flutter_app/lib/`.
- Learning content: read `flutter_app/assets/learning/input/AGENTS.md`, then local `guide/`, `reading/`, or `verbs/` `AGENTS.md` only when editing that area.
- Backend/API: start in `backend/`.
- Navigation aids: `docs/ai_map.md`, `docs/content_index.json`.

## Defaults
- Read the smallest relevant slice first.
- Keep numbered lesson filenames, media filenames, and stable IDs unchanged unless migration is explicit.
- Preserve UTF-8 for Hebrew/Ukrainian content.
- Do not add a second source of truth for learning content without a sync strategy.
- Treat light and night mode as first-class Flutter states; use shared theme tokens/`ThemeData`, not screen-local hardcoded light colors.
- In night mode, avoid pure white text; use shared warm muted foreground tokens.

## Validation
- Preferred entrypoint: `powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 <flutter|content|python|all>`.
- After Flutter, content, or Python/backend changes, run the matching mode when feasible.
- Flutter SDK: `C:\src\Flutter\flutter`; prefer `C:\src\Flutter\flutter\bin\flutter.bat` in automation.
- Flutter commands in Codex may need elevated permission because SDK cache/lock files live outside the repo.
