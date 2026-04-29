# Flutter Android Client

This folder contains the new Flutter client for the Hebrew learning app.

The current migration goal is to make Flutter the only supported product surface:

- keep new user-facing work in Flutter
- use the frozen Tkinter app only as a temporary behavior reference
- reuse the existing local learning content instead of inventing a second source of truth

## Current scope

The Flutter app currently provides:

- a shared mobile shell with bottom navigation
- a searchable Words screen loaded from the existing `data/input/hebrew_words.json`
- a Guide list/detail flow loaded from synced markdown assets
- a Verbs list/detail flow with synced verb images when available
- a Reading list/detail flow grouped by lesson level
- lesson discovery based on synced guide, verb, and reading markdown files

The Flutter client now owns the mobile product flow. Remaining desktop retirement work is tracked in `../docs/desktop_retirement_plan.md`.

## Sync content from source data

The Flutter client uses bundled assets under `flutter_app/assets/learning/`.
To refresh them from the repository source data, run:

```powershell
cd flutter_app
powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1
```

This copies the text-based learning content from the main repository data folder into Flutter assets.

## Run the Android client

```powershell
cd flutter_app
flutter run
```

## Notes

- `src/main.py` is a frozen legacy reference entry point while desktop retirement is in progress.
- The source-of-truth content still lives under `data/input/`.
- Audio and image migration are intentionally postponed until the mobile content flow is stable.
