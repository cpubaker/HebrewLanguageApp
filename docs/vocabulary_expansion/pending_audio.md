# Pending audio for new vocabulary

Words added to `hebrew_words.json` without an `audio_file` value live here until audio is generated.

## How to use

When adding a frequency-batch entry to `hebrew_words.json`:

1. Add the entry without an `audio_file` field (the field is optional per `flutter_app/assets/learning/input/AGENTS.md`).
2. Append the `word_id` to the **Queue** table below with batch number and date.
3. After running `scripts/generate_word_audio_elevenlabs.py` for the queued ids, move the rows to the **Done** section and add the `audio_file` field to the JSON entries.

## Queue

| Batch | Date added | word_id | Hebrew | Transcription |
|---|---|---|---|---|

## Done

| Batch | Date generated | word_id | audio_file |
|---|---|---|---|
