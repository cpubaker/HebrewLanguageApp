# AGENTS.md

## Scope
- Active Flutter client; root `AGENTS.md` still applies.
- Implement product behavior in Flutter unless the task explicitly targets tooling/backend.
- Durable shared content lives under `assets/learning/input/`; follow its local `AGENTS.md` for content edits.

## Entry Points
- Bootstrap/root: `lib/main.dart`, `lib/app.dart`.
- Shared shell/navigation: `lib/screens/app_shell_screen.dart`.
- Home: `lib/screens/home_screen.dart`, `lib/screens/widgets/home/`.
- Words: `lib/screens/words_screen.dart`, `lib/screens/widgets/words/`.
- Practice: `lib/screens/flashcards_screen.dart`, `lib/screens/writing_screen.dart`, `lib/screens/sprint_screen.dart`.
- Learning loader: `lib/services/learning_bundle_loader.dart`.

## Working Rules
- Prefer narrow vertical slices over broad refactors.
- Keep UI in `lib/screens/` and `lib/theme/`; keep loading/parsing in `lib/services/`.
- Extend existing models/services before adding architectural layers or state-management packages.
- Favor touch-friendly mobile patterns over desktop-style UI.
- When adding loadable assets, update `pubspec.yaml` if needed.
- Treat light and night mode as equally supported; extend `lib/theme/` tokens before hardcoding per-screen colors.
- Learning/materials UI must keep cards, pills, sheets, markdown/text bodies, and headers readable in both themes.
- Preserve the night palette family: deep green base, muted teal, olive transitions, restrained warm brown/bronze accents.

## Validation
- Preferred: run root `scripts/validate.ps1 flutter`.
- Local equivalent from `flutter_app/`: `flutter analyze` and `flutter test`.
- If lesson files were added/removed/renamed, run `powershell -ExecutionPolicy Bypass -File .\tool\generate_learning_catalog.ps1`.
