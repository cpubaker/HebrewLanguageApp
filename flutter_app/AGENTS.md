# AGENTS.md

## Scope
- This folder contains the active Flutter client.
- Root `AGENTS.md` still applies.
- Use Flutter as the implementation target for product behavior.

## Source Of Truth
- Durable shared content lives under `assets/learning/input/`.
- For lesson, vocabulary, verbs, reading, contexts, images, or audio, edit `assets/learning/input/`.
- After lesson file additions, removals, or renames, run:
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\generate_learning_catalog.ps1`

## Entry Points
- App bootstrap: `lib/main.dart`
- App root: `lib/app.dart`
- Shared shell: `lib/screens/app_shell_screen.dart`
- Home screen: `lib/screens/home_screen.dart`
- Home dashboard sections/cards: `lib/screens/widgets/home/`
- Sprint practice: `lib/screens/sprint_screen.dart`
- Learning bundle loader: `lib/services/learning_bundle_loader.dart`

## Working Rules
- Prefer narrow vertical slices over broad refactors.
- Keep UI concerns in `lib/screens/` and `lib/theme/`; keep loading/parsing in `lib/services/`.
- When adding loadable assets, update `pubspec.yaml` if needed.
- Prefer extending existing models/services before adding a new architectural layer or state-management package.
- Favor touch-friendly mobile patterns over desktop-style UI.
- Treat light mode and night mode as equally supported mobile experiences.
- For colors, surfaces, borders, and text contrast, extend `lib/theme/` tokens first and consume them from screens instead of hardcoding per-screen light values.
- When adjusting learning or materials UI, verify that cards, pills, sheets, markdown/text bodies, and headers stay readable in both themes.
- Keep the current night palette in the same family: deep green base, muted teal support, olive transitions, and restrained warm brown/bronze accents.

## Validation
- After Flutter code changes:
  - `flutter analyze`
  - `flutter test`
- If asset loading behavior changed, also run:
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\generate_learning_catalog.ps1`
- If device/emulator behavior matters, also run:
  - `flutter run`

## Notes
- Prefer read-only content flows before persistence-heavy features unless the user asks otherwise.
- The Flutter practice area currently includes flashcards, writing, constructor, and sprint modes.
