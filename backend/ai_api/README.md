# AI Content API

Small stdlib Python backend for generated Hebrew learning content. It keeps the
OpenAI API key server-side and exposes the endpoints expected by the Flutter
client.

## Run

```powershell
$env:OPENAI_API_KEY="..."
python -m backend.ai_api.server --host 127.0.0.1 --port 8787
```

Flutter dev wiring:

```powershell
cd flutter_app
flutter run `
  --dart-define=AI_CONTEXTS_ENDPOINT=http://127.0.0.1:8787/ai/word-contexts `
  --dart-define=AI_PRACTICE_TEXTS_ENDPOINT=http://127.0.0.1:8787/ai/practice-texts
```

## Endpoints

- `GET /health`
- `POST /ai/word-contexts`
- `POST /ai/practice-texts`

Both POST endpoints accept the same word shape sent by Flutter:

```json
{
  "prompt_version": "word-contexts-v1",
  "target_language": "uk",
  "words": [
    {
      "word_id": "word_book",
      "hebrew": "ספר",
      "transcription": "sefer",
      "translation": "книга",
      "english": "book"
    }
  ]
}
```

The server uses a local JSON cache at `.cache/ai_api_cache.json` by default.

