# Hebrew Language App

This repository contains a Hebrew learning app for individual study.

## Product Surface

- `flutter_app/` is the active Flutter Android client.
- `flutter_app/assets/learning/input/` contains the durable learning content.
- `backend/ai_api/` contains optional backend/API support code.

New user-facing work should target Flutter.

## Learning Catalog

After adding, removing, or renaming guide, verb, or reading lesson files,
regenerate the Flutter lesson catalog and compact content index:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 content
```

## Run The Flutter App

```powershell
cd flutter_app
flutter run
```

## Validation

After Flutter code changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 flutter
```

After shared content changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 content
```

After backend, Python tooling, or content validation changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 python
```

Before a broad handoff or PR:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 all
```

## OpenAI API Key

The optional backend/API tooling reads `OPENAI_API_KEY` from the environment.

Windows:

```powershell
setx OPENAI_API_KEY "your_api_key_here"
```

macOS/Linux:

```bash
export OPENAI_API_KEY="your_api_key_here"
```
