# Input Content Instructions

## Scope
- Canonical learning content packaged by the Flutter client.
- Vocabulary source: `hebrew_words.json`; reusable contexts: `contexts/sentences.json`; word links: `contexts/word_context_links.json`.
- For guide, reading, or verb lessons, also follow the local `AGENTS.md`.

## Vocabulary Rules
- Treat `hebrew_words.json` and `contexts/` as one connected content set.
- Inspect adjacent entries before changing vocabulary structure or style.
- Keep `word_id` stable unless a migration updates linked context data too.
- Preserve UTF-8 Hebrew/Ukrainian text and match neighboring spelling, gloss, transliteration, and optional `audio_file` style.
- The deck mixes everyday words, function words, and grammar-facing entries; not every item is a one-word translation pair.
- Keep `english` as a compatibility fallback unless all consumers are migrated.
- Avoid accidental duplicates where Hebrew, transliteration, and meaning overlap unless the gloss documents the distinction.
- Do not add runtime progress fields such as `correct`, `wrong`, `last_correct`, `last_reviewed_at`, `last_review_correct`, `writing_correct`, `writing_wrong`, or `writing_last_correct`.

## Context Rules
- `sentences.json` is the canonical registry; `word_context_links.json` must reference existing sentence IDs.
- Prefer linking one sentence to multiple relevant words over duplicating near-identical sentences.
- Missing coverage should not break loaders, but new vocabulary work should keep links valid when relevant.

## Editorial Rules
- Keep Ukrainian glosses concise for plain vocabulary; explanatory glosses are acceptable for function or grammar-facing entries.
- Prefer durable content edits over embedding personal study progress in source files.
- If a change materially affects search, flashcards, loading, or deck composition, inspect the relevant Flutter loader/screens.

## Validation
- After shared vocabulary/context changes, run root `scripts/validate.ps1 content` when feasible.
- If loading or presentation changed, also run Flutter validation.
