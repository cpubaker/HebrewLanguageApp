# Flutter Android Client

This folder contains the active Flutter client for the Hebrew learning app.

Flutter is the only supported product surface:

- keep new user-facing work in Flutter
- reuse the existing local learning content instead of inventing a second source of truth

## Current scope

The Flutter app currently provides:

- a shared mobile shell with bottom navigation
- a searchable Words screen loaded from `assets/learning/input/hebrew_words.json`
- a Guide list/detail flow loaded from bundled markdown assets
- a Verbs list/detail flow with bundled verb images when available
- a Reading list/detail flow grouped by lesson level
- lesson discovery based on guide, verb, and reading markdown files

The Flutter client owns the product flow.

## Generate the lesson catalog

The Flutter client uses bundled assets under `flutter_app/assets/learning/`.
After adding, removing, or renaming guide, verb, or reading lesson files,
regenerate the catalog:

```powershell
cd flutter_app
powershell -ExecutionPolicy Bypass -File .\tool\generate_learning_catalog.ps1
```

## Run the Android client

```powershell
cd flutter_app
flutter run
```

## Notes

- The source-of-truth content lives under `assets/learning/input/`.
