# Audio Generation Notes

Use this when generating missing Hebrew pronunciation MP3 files for the
Flutter app.

## Canonical Locations

- Word source data: `flutter_app/assets/learning/input/hebrew_words.json`
- Word audio output: `flutter_app/assets/learning/input/audio/words/`
- Verb lessons: `flutter_app/assets/learning/input/verbs/`
- Verb audio output: `flutter_app/assets/learning/input/audio/verbs/`

Word entries should use:

```json
"audio_file": "words/<word_id>.mp3"
```

Verb audio paths are inferred from lesson filenames by the Flutter UI:

```text
<number>_<stem>.md -> assets/learning/input/audio/verbs/<stem>.mp3
```

## ElevenLabs Settings

The current matching voice is Sarah:

```text
Voice name: Sarah - Mature, Reassuring, Confident
Voice ID: EXAVITQu4vr4xnSDxMaL
Model: eleven_v3
Language code: he
Output format: mp3_44100_128
```

The ElevenLabs generators use this voice by default when
`ELEVENLABS_VOICE_ID` is not set. Pass `--voice-id` only when intentionally
overriding Sarah.

Do not store API keys in the repo. Set the key in the current shell before
generation:

```powershell
$env:ELEVENLABS_API_KEY="..."
```

Note: `eleven_v3` rejected `--language-code heb` with `unsupported_language`.
Use `--language-code he`.

## Audit Missing Audio

Words:

```powershell
python scripts\generate_word_audio_elevenlabs.py --dry-run
```

Verbs:

```powershell
python scripts\generate_verb_audio_elevenlabs.py --dry-run
```

## Generate One Test File

Use one missing word first and listen before doing a batch:

```powershell
python scripts\generate_word_audio_elevenlabs.py `
  --only-word-id word_salary `
  --model eleven_v3 `
  --language-code he
```

For one verb:

```powershell
python scripts\generate_verb_audio_elevenlabs.py `
  --only-stem chase `
  --model eleven_v3 `
  --language-code he
```

## Generate Missing Files

All missing word audio:

```powershell
python scripts\generate_word_audio_elevenlabs.py `
  --model eleven_v3 `
  --language-code he `
  --pause-seconds 0.2
```

All missing verb audio:

```powershell
python scripts\generate_verb_audio_elevenlabs.py `
  --model eleven_v3 `
  --language-code he `
  --pause-seconds 0.2
```

After generating audio assets, run at least:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 content
```

If asset packaging or Flutter behavior changed, also run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 flutter
```
