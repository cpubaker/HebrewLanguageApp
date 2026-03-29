# AGENTS.md

## Purpose
- This folder contains the Flutter Android client for the Hebrew learning app.
- The Flutter app currently coexists with the Tkinter desktop app in `src/`.
- Treat this folder as the mobile migration workspace: add new Android/mobile UI here without breaking the desktop app.

## Source Of Truth
- Flutter learning assets under `flutter_app/assets/learning/` are generated copies for runtime use.
- The source-of-truth learning content still lives in the repository root under `data/input/`.
- If a task is about lessons, vocabulary, verbs, reading, contexts, images, or audio content, prefer editing the root `data/input/` files first unless the task explicitly targets Flutter asset packaging.
- After source content changes, refresh Flutter assets with:
  - `powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`

## Primary Entry Points
- Flutter bootstrap: `lib/main.dart`
- App root: `lib/app.dart`
- Current shared shell: `lib/screens/app_shell_screen.dart`
- Current home/dashboard screen: `lib/screens/home_screen.dart`
- Current searchable vocabulary screen: `lib/screens/words_screen.dart`
- Asset loading service: `lib/services/learning_bundle_loader.dart`

## Current Architecture
- `lib/models/` - simple Flutter-side view/data models.
- `lib/services/` - asset-backed loading and app-facing data services.
- `lib/screens/` - top-level mobile screens and flow composition.
- `lib/theme/` - shared Flutter theming.
- `tool/sync_learning_assets.ps1` - copies root learning content into Flutter assets.
- `test/` - Flutter widget tests.

## Working Rules
- Preserve coexistence with the Tkinter app; do not move or replace desktop entry points from within Flutter work.
- Prefer vertical slices: navigation + one real feature screen at a time.
- Keep `LearningBundleLoader` and the mobile shell simple until there is a stronger need for a larger state-management solution.
- Avoid introducing a second source of truth for progress or lesson content unless the task explicitly defines the sync strategy.
- Do not hand-edit synced files under `assets/learning/input/` for durable product changes; they may be overwritten by the sync script.
- When adding new asset folders or files that Flutter must load, update `pubspec.yaml` as needed.
- Keep mobile-specific presentation in `lib/screens/` and `lib/theme/`; keep parsing/loading concerns in `lib/services/`.
- Prefer Android-safe, touch-friendly UI patterns over desktop-style layouts.

## Migration Roadmap
- Current completed slices:
  - shared app shell
  - bottom navigation
  - home/dashboard
  - searchable `Words` screen
  - `Guide` list + detail flow
- Recommended next feature order:
  - `Verbs` list + detail screen
  - `Reading` list + detail screen
  - `Flashcards` as the first full interactive exercise
  - progress persistence for mobile
  - `Sprint` migration
  - audio and image polish
- Prefer finishing one slice end-to-end before starting the next one.
- Use the Tkinter app as the behavior reference when product details are unclear.

## Slice Definition Of Done
- A migrated Flutter feature should usually include:
  - navigation entry point
  - list or overview screen if relevant
  - detail or interaction screen if relevant
  - loading from synced assets or the agreed mobile persistence layer
  - at least one widget test for the new user flow
  - `flutter analyze` and `flutter test` passing
- Do not call a feature "migrated" if it only has mock UI without real app data.

## Validation
- Preferred validation after Flutter code changes:
  - `flutter analyze`
  - `flutter test`
- If asset loading behavior changed, also run:
  - `powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`
- If the task affects real-device or emulator behavior, also run:
  - `flutter run`

## Safe Defaults For AI Agents
- Assume Android is the current Flutter target unless the task explicitly mentions another platform.
- Assume content should continue to come from synced local assets, not from live services.
- Prefer implementing read-only content flows before interactive progress-saving flows unless the user asks otherwise.
- For content-screen migration tasks, prefer this sequence:
  - add list screen
  - add detail screen
  - add media wiring
  - add persistence or progress only after the UI flow is stable

## Notes
- The root repository `AGENTS.md` still applies to the project as a whole.
- This local file exists to speed up Flutter/mobile decisions and reduce accidental edits to generated asset copies.
