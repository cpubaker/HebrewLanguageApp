# AI Map

Use this file to avoid broad repo reads. Start from the smallest route below,
then open only the files needed for the task.

## Product Shape

- Active product: Flutter client in `flutter_app/`.
- Durable learning content: `data/input/`.
- Synced runtime content: `flutter_app/assets/learning/input/`.
- Python code: backend API, content tooling, validation, and generation scripts.

## First Reads

- Flutter app work: read `flutter_app/AGENTS.md`, then the relevant file under
  `flutter_app/lib/`.
- Content work: read `data/input/AGENTS.md`, then the local `AGENTS.md` in
  `guide/`, `reading/`, or `verbs/` if applicable.
- Backend/API work: start in `backend/ai_api/`.
- Repo-wide rules: root `AGENTS.md`.

## Do Not Read First

- Do not inspect `flutter_app/assets/learning/input/` for durable content
  changes. It is a synced runtime copy.
- Do not read all lesson Markdown files to answer a narrow content question.
  Use filenames, local `AGENTS.md`, and adjacent examples first.
- Do not inspect audio/image assets unless the task is specifically about media
  packaging, missing files, or asset references.
- Avoid generated/build/local folders: `.git/`, `.dart_tool/`, `build/`,
  `.pub-cache/`, `flutter_app/android/.gradle/`, local SDK/tool homes, and logs.

## Flutter Map

- App bootstrap: `flutter_app/lib/main.dart`.
- App root and dependencies: `flutter_app/lib/app.dart`,
  `flutter_app/lib/app_dependencies.dart`.
- Shared shell: `flutter_app/lib/screens/app_shell_screen.dart`.
- Navigation/workspace definitions:
  `flutter_app/lib/screens/app_shell_navigation.dart`,
  `flutter_app/lib/screens/app_shell_workspaces.dart`.
- Theme tokens: `flutter_app/lib/theme/app_theme.dart`.
- Shared UI widgets: `flutter_app/lib/screens/widgets/`.

## Main Screens

- Home: `flutter_app/lib/screens/home_screen.dart`.
- Words/vocabulary: `flutter_app/lib/screens/words_screen.dart`.
- Flashcards: `flutter_app/lib/screens/flashcards_screen.dart`.
- Writing/constructor: `flutter_app/lib/screens/writing_screen.dart`.
- Repetition queue: `flutter_app/lib/screens/repetition_screen.dart`.
- Sprint practice: `flutter_app/lib/screens/sprint_screen.dart`.
- Guide lessons: `flutter_app/lib/screens/guide_screen.dart`.
- Reading lessons: `flutter_app/lib/screens/reading_screen.dart`.
- Verb lessons: `flutter_app/lib/screens/verbs_screen.dart`.
- AI practice text UI: `flutter_app/lib/screens/ai_practice_text_screen.dart`.
- Profile/settings: `flutter_app/lib/screens/profile_screen.dart`.

## Service Map

- Learning bundle loading:
  `flutter_app/lib/services/learning_bundle_loader.dart`.
- Lesson document loading:
  `flutter_app/lib/services/lesson_document_loader.dart`.
- Markdown lesson body parsing/render support:
  `flutter_app/lib/services/markdown_lesson_body_parser.dart`,
  `flutter_app/lib/screens/widgets/markdown_lesson_body.dart`.
- Word filtering: `flutter_app/lib/services/word_list_filter.dart`.
- Flashcard session logic:
  `flutter_app/lib/services/flashcard_session.dart`.
- Writing session logic:
  `flutter_app/lib/services/writing_session.dart`.
- Sprint session and stats:
  `flutter_app/lib/services/sprint_session.dart`,
  `flutter_app/lib/services/sprint_stats_store.dart`.
- Repetition logic: `flutter_app/lib/services/repetition_queue.dart`.
- Progress stores:
  `flutter_app/lib/services/word_progress_store.dart`,
  `flutter_app/lib/services/guide_progress_store.dart`,
  `flutter_app/lib/services/reading_progress_store.dart`,
  `flutter_app/lib/services/learning_progress_repository.dart`.
- AI-generated contexts/texts:
  `flutter_app/lib/services/ai_context_service.dart`,
  `flutter_app/lib/services/ai_practice_text_service.dart`,
  `flutter_app/lib/services/ai_learning_helpers.dart`.
- Audio: `flutter_app/lib/services/learning_audio_player.dart`,
  `flutter_app/lib/services/verb_audio_player.dart`,
  `flutter_app/lib/services/audio_playback_awareness.dart`.

## Model Map

- Learning bundle: `flutter_app/lib/models/learning_bundle.dart`.
- Vocabulary word: `flutter_app/lib/models/learning_word.dart`.
- Context sentence: `flutter_app/lib/models/learning_context.dart`.
- Lesson document: `flutter_app/lib/models/lesson_document.dart`.
- Generated AI practice text:
  `flutter_app/lib/models/generated_practice_text.dart`.
- Guide lesson status:
  `flutter_app/lib/models/guide_lesson_status.dart`.

## Content Map

- Vocabulary source: `data/input/hebrew_words.json`.
- Reusable context sentences: `data/input/contexts/sentences.json`.
- Word-to-context links: `data/input/contexts/word_context_links.json`.
- Guide lessons: `data/input/guide/`.
- Guide metadata: `data/input/guide_metadata.json`.
- Reading lessons by level: `data/input/reading/`.
- Verb lessons: `data/input/verbs/`.
- Source audio/images: `data/input/audio/`, `data/input/images/`.
- Runtime sync script:
  `flutter_app/tool/sync_learning_assets.ps1`.

## Backend And Tooling Map

- AI API server: `backend/ai_api/server.py`.
- OpenAI Responses client and prompts:
  `backend/ai_api/openai_client.py`.
- AI request normalization and response shaping:
  `backend/ai_api/content.py`.
- AI disk cache: `backend/ai_api/cache.py`.
- Content integrity tests: `tests/test_content_integrity.py`.
- AI API tests: `tests/test_ai_api.py`.
- Verb audits: `scripts/audit_verb_templates.py`,
  `scripts/audit_verb_duplicates.py`,
  `scripts/audit_verb_transliterations.py`.

## Search Recipes

- Find a screen/widget: `rg -n "class .*Screen|class .*Widget" flutter_app/lib`.
- Find theme usage: `rg -n "appTheme|Color\\(|Theme.of" flutter_app/lib`.
- Find asset paths: `rg -n "assets/learning|rootBundle|loadString" flutter_app/lib flutter_app/test`.
- Find SharedPreferences stores:
  `rg -n "SharedPreferences|getString|setString" flutter_app/lib`.
- Find content IDs: search `data/input/` first, not synced assets.

## Validation Routes

- After Flutter code changes:
  `cd flutter_app; flutter analyze; flutter test`.
- After shared content changes:
  `cd flutter_app; powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`.
- After content sync or asset packaging changes: also run `flutter test`.
- After Python backend/tooling/content validation changes:
  `python -m unittest discover -s tests -v`.
- After verb content changes:
  `python scripts/audit_verb_templates.py`, then sync assets.

## Editing Rules For AI Agents

- Prefer narrow vertical slices and existing local patterns.
- Keep stable filenames, media filenames, lesson numbers, and IDs unchanged
  unless the task explicitly requires migration.
- For durable learning content, edit `data/input/` first.
- For Flutter colors and surfaces, prefer shared theme tokens in
  `flutter_app/lib/theme/app_theme.dart`.
- Treat light and night mode as required states for UI changes.
- Preserve UTF-8 for Hebrew and Ukrainian content.
