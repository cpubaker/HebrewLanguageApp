# Hebrew Language App

This repository contains a Hebrew learning app for individual study.

## Product Surface

- `flutter_app/` is the active Flutter Android client.
- `data/input/` contains the durable learning content.
- `flutter_app/assets/learning/input/` contains generated runtime copies of that content.
- `backend/ai_api/` contains optional backend/API support code.

The legacy Tkinter desktop client has been removed. New user-facing work should target Flutter.

## Content Sync

After changing source learning content under `data/input/`, refresh Flutter assets:

```powershell
cd flutter_app
powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1
```

## Run The Flutter App

```powershell
cd flutter_app
flutter run
```

## Validation

After Flutter code changes:

```powershell
cd flutter_app
flutter analyze
flutter test
```

After backend, content tooling, or content validation changes:

```powershell
python -m unittest discover -s tests -v
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
