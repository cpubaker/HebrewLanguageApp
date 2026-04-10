# AGENTS.md

## Scope
- This folder contains the active Flutter client.
- Root `AGENTS.md` still applies.
- Use Flutter as the default implementation target unless the user explicitly asks for the legacy desktop app.

## Source Of Truth
- Runtime assets under `assets/learning/` are generated copies.
- Durable shared content still lives in the repo root under `data/input/`.
- For lesson, vocabulary, verbs, reading, contexts, images, or audio, edit `data/input/` first unless the task is specifically about Flutter asset packaging.
- After source content changes, run:
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\sync_learning_assets.ps1`

## Entry Points
- App bootstrap: `lib/main.dart`
- App root: `lib/app.dart`
- Shared shell: `lib/screens/app_shell_screen.dart`
- Home screen: `lib/screens/home_screen.dart`
- Learning bundle loader: `lib/services/learning_bundle_loader.dart`

## Working Rules
- Preserve coexistence with the Tkinter app.
- Prefer narrow vertical slices over broad refactors.
- Keep UI concerns in `lib/screens/` and `lib/theme/`; keep loading/parsing in `lib/services/`.
- Do not hand-edit synced files under `assets/learning/input/` for permanent changes.
- When adding loadable assets, update `pubspec.yaml` if needed.
- Prefer extending existing models/services before adding a new architectural layer or state-management package.
- Favor touch-friendly mobile patterns over desktop-style UI.

## Validation
- After Flutter code changes:
  - `flutter analyze`
  - `flutter test`
- If asset loading behavior changed, also run:
  - `powershell -ExecutionPolicy Bypass -File .\\tool\\sync_learning_assets.ps1`
- If device/emulator behavior matters, also run:
  - `flutter run`

## Notes
- Use the Tkinter app as a behavior reference when product details are unclear.
- Prefer read-only content flows before persistence-heavy features unless the user asks otherwise.
