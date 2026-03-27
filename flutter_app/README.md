# Flutter Android Client

This folder contains the new Flutter client for the Hebrew learning app.

The current migration goal is simple:

- keep the Tkinter desktop app working as-is
- start a parallel Android UI in Flutter
- reuse the existing local learning content instead of inventing a second source of truth

## Current scope

The Flutter app currently provides:

- a migration dashboard with counts for vocabulary, guide lessons, verbs, and reading lessons
- a vocabulary preview loaded from the existing `data/input/hebrew_words.json`
- lesson discovery based on synced guide, verb, and reading markdown files

The Flutter client is intentionally read-only for now. Progress persistence and feature parity will come in later steps.

## Sync content from the desktop app

The Flutter client uses bundled assets under `flutter_app/assets/learning/`.
To refresh them from the existing desktop source data, run:

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

- `src/main.py` remains the desktop entry point.
- The source-of-truth content still lives under `data/input/`.
- Audio and image migration are intentionally postponed until the mobile content flow is stable.
