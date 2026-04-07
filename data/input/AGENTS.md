# Input Content Instructions

## Purpose
- This folder contains the source-of-truth learning content shared by the Flutter client and the legacy desktop app.
- For vocabulary work, treat `hebrew_words.json` plus `contexts/` as one connected content set.
- Prefer content edits here over edits to synced Flutter asset copies.

## Vocabulary Scope
- The active vocabulary source file is `data/input/hebrew_words.json`.
- Shared example sentences live in `data/input/contexts/sentences.json`.
- Word-to-context mapping lives in `data/input/contexts/word_context_links.json`.
- The current vocabulary deck is intentionally mixed:
  - concrete nouns and everyday words;
  - functional words such as prepositions and particles;
  - some grammar-facing entries whose English gloss is explanatory rather than dictionary-short.
- Do not assume every entry is a simple one-word translation pair.

## Working Rules
- Inspect adjacent entries before changing vocabulary structure or style.
- Keep `word_id` values stable unless the task explicitly requires a migration and the linked context data is updated in the same change.
- Preserve UTF-8 encoding for Hebrew text.
- Keep Hebrew spelling, English gloss style, and transliteration style consistent with neighboring entries unless the task is a deliberate normalization pass.
- When editing or adding words, update context links and context sentences together when needed so the deck stays internally consistent.
- Prefer durable content edits over embedding personal study progress in source files.

## Data Shape
- Vocabulary entries currently include:
  - `word_id`
  - `hebrew`
  - `english`
  - `transcription`
  - legacy progress-style fields such as `correct`, `wrong`, `last_correct`, `writing_correct`, `writing_wrong`, and `writing_last_correct`
- Flutter currently relies on the lexical fields plus `correct`, `wrong`, and string `last_correct`.
- Flutter does not currently use the writing-progress fields, so treat them as legacy unless a task explicitly revives writing-mode behavior.
- Some existing source entries still contain seeded progress values. Do not add new progress noise unless the task explicitly concerns migrations or cleanup of that model.

## Context Rules
- `sentences.json` is the canonical registry of reusable context sentences.
- `word_context_links.json` should reference sentence IDs that exist in `sentences.json`.
- Prefer linking one sentence to multiple relevant words rather than duplicating near-identical sentences.
- Missing or partial context coverage should not break the loaders, but new vocabulary work should preserve valid links whenever possible.

## Editorial Guidance
- Keep English glosses concise when the entry is plain vocabulary.
- For function words or grammar-facing entries, a longer explanatory gloss is acceptable when it clarifies usage.
- Avoid creating accidental duplicates where the Hebrew form, transliteration, and meaning overlap with an existing entry unless the distinction is intentional and documented by the gloss.
- If a change materially affects search, flashcards, or deck composition, inspect the Flutter loaders and screens before finalizing the content update.

## Validation
- After changing shared vocabulary or contexts, refresh Flutter assets:
  - `cd flutter_app`
  - `powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`
- If the change affects loading or presentation, also run:
  - `cd flutter_app`
  - `flutter analyze`
  - `flutter test`
