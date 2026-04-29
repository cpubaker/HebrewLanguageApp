# Desktop Retirement Plan

## Goal

Retire the legacy Tkinter desktop client without losing learning content, learner progress behavior, or validation coverage that is still useful for the Flutter product.

## Current Policy

- `flutter_app/` is the only active product surface.
- `src/` is frozen and should be used only as a temporary behavior reference.
- New user-facing behavior belongs in Flutter unless a critical retirement blocker requires a short-lived desktop fix.
- Durable learning content remains in `data/input/`.
- Synced Flutter runtime assets under `flutter_app/assets/learning/input/` are generated copies and must not become a second source of truth.

## Phase 1: Freeze And Document

- [x] Mark Flutter as the only active product in repo instructions.
- [x] Mark the Tkinter app as frozen legacy reference.
- [x] Stop documenting Tkinter as the primary interface.
- [x] Remove remaining desktop-first wording from content folder instructions.
- [x] Categorize Python tests as keep, migrate, or delete.

## Phase 2: Parity Audit

Use this table before deleting desktop code.

| Area | Flutter status | Desktop reference | Decision |
| --- | --- | --- | --- |
| Home and navigation | Present | `src/ui/main_window.py` | Verify mobile flow covers expected entry points. |
| Vocabulary browsing | Present | `src/infrastructure/content_repository.py` | Verify lexical fields and context links. |
| Flashcards | Present | `src/application/flashcard_session.py` | Compare scoring and queue behavior. |
| Writing practice | Present | `src/application/writing_session.py` | Compare answer normalization and progress updates. |
| Constructor practice | Present | No direct desktop parity confirmed | Treat Flutter as source of truth after tests pass. |
| Sprint practice | Present | `src/application/sprint_session.py` | Compare timing, scoring, and result persistence. |
| Reading | Present | `src/ui/reading_window.py` | Verify lesson discovery, ordering, and markdown rendering. |
| Guide | Present | `src/ui/guide_window.py` | Verify article discovery, ordering, and markdown rendering. |
| Verbs | Present | `src/ui/verbs_window.py` | Verify markdown loading and image handling. |
| Audio playback | Present in both stacks, needs audit | `src/ui/audio_player.py` | Confirm Flutter asset coverage before desktop removal. |
| Progress persistence | Present | `src/infrastructure/progress_repository.py` | Confirm migrations and storage keys are tested in Dart. |
| Content integrity checks | Python tests/scripts | `tests/`, `scripts/` | Keep useful content validation outside the desktop app. |
| DB and model experiments | Python-side | `src/database/`, `src/models/` | Move or keep only if independent of Tkinter. |

## Phase 3: Test Migration

Most Python tests import `src/` through `tests/test_support.py`. Remove that shared dependency before deleting `src/`.

| Test file | Category | Retirement action |
| --- | --- | --- |
| `tests/test_ai_api.py` | Keep | Backend/API validation independent of Tkinter. |
| `tests/test_content_integrity.py` | Keep | Refactored to read `data/input/` directly without `src/` imports. |
| `tests/test_data_service.py` | Keep temporarily | Useful coverage for content/progress parsing; migrate useful assertions to Flutter or standalone content tooling. |
| `tests/test_app_content_loader.py` | Migrate | Product loader behavior should be covered by Flutter bundle/document loader tests. |
| `tests/test_domain_models.py` | Migrate | Product model behavior should live in Dart tests if Flutter consumes it. |
| `tests/test_flashcard_session.py` | Migrate/delete | Dart flashcard session tests already exist; compare gaps before deleting. |
| `tests/test_vocabulary_session.py` | Migrate/delete | Covered conceptually by Flutter words/repetition tests; compare gaps before deleting. |
| `tests/test_writing_session.py` | Migrate/delete | Dart writing and constructor tests already exist; compare answer-normalization gaps. |
| `tests/test_sprint_session.py` | Migrate/delete | Dart sprint tests already exist; compare scoring gaps. |
| `tests/test_progress_service.py` | Migrate/delete | Flutter progress repository/store tests should own product progress behavior. |
| `tests/test_progress_repository.py` | Migrate/delete | Keep only until Flutter persistence coverage is confirmed. |
| `tests/test_word_of_day_service.py` | Migrate/delete | Migrate if Flutter keeps word-of-day behavior; otherwise drop. |
| `tests/test_app_paths.py` | Delete/replace | Tied to `src/` layout; replace only if Python tooling still needs path helpers. |
| `tests/test_app_runtime.py` | Delete | Desktop runtime wiring test. |
| `tests/test_main.py` | Delete | Desktop entry smoke test. |
| `tests/test_tk_env.py` | Delete | Tcl/Tk runtime setup test. |
| `tests/test_markdown_utils.py` | Delete | Tk text-widget markdown formatting. |
| `tests/test_reading_window.py` | Delete | Tk reading window formatting. |
| `tests/test_text_browser_window.py` | Delete | Tk text browser adapter. |

Phase checklist:

- [x] Refactor keepers so they do not import `src/` through `tests/test_support.py`.
- [ ] Compare migrate/delete tests against existing Flutter tests.
- [ ] Add missing Flutter tests for any product behavior gaps.
- [ ] Delete Tkinter-only tests after parity is confirmed.
- [ ] Remove `tests/test_support.py` once no remaining tests import `src/`.

Remaining `src/`-dependent Python tests:

- Product behavior to compare with Flutter tests: `test_app_content_loader.py`, `test_domain_models.py`, `test_flashcard_session.py`, `test_progress_repository.py`, `test_progress_service.py`, `test_sprint_session.py`, `test_vocabulary_session.py`, `test_word_of_day_service.py`, `test_writing_session.py`.
- Desktop/runtime tests to delete after parity: `test_app_paths.py`, `test_app_runtime.py`, `test_main.py`, `test_tk_env.py`, `test_markdown_utils.py`, `test_reading_window.py`, `test_text_browser_window.py`.
- Temporary broad repository tests: `test_data_service.py`, until useful parser/content assertions are migrated to Flutter or standalone content tooling.

Flutter coverage notes:

- `test_flashcard_session.py`: Core deck behavior is covered by `flutter_app/test/flashcard_session_test.dart`. Added `currentWordStats` snapshot coverage there. Python-only repeated context rotation is not a current Flutter requirement because Flutter completes a flashcard deck after each word is seen once.
- `test_writing_session.py`: Core prompt, blank answer, correct/wrong answer, constructor, and unknown-answer behavior are covered by `flutter_app/test/writing_session_test.dart`. Added writing stats snapshot coverage there.
- `test_sprint_session.py`: Covered by `flutter_app/test/sprint_session_test.dart`.
- `test_app_content_loader.py`: Covered conceptually by Flutter bundle/document loader tests; confirm no missing aggregate bundle expectation before deleting.
- `test_domain_models.py`: Covered mostly by `learning_word_test.dart` and `learning_context_test.dart`; confirm no missing transient-field serialization requirement before deleting.
- `test_word_of_day_service.py`: No matching Flutter feature found yet. Decide whether word-of-day is intentionally dropped or should be rebuilt in Flutter before deleting the Python reference.
- `test_vocabulary_session.py`: Legacy desktop quiz flow has no direct Flutter service equivalent. Treat as deprecated unless a Flutter multiple-choice vocabulary mode is still desired.

## Phase 4: Remove Desktop Runtime

Only start this phase after the parity audit is complete and Flutter validation passes.

Candidates for removal:

- `src/ui/`
- `src/legacy_ui/`
- `src/main.py`
- `src/tk_env.py`
- `tk_runtime/`
- `scripts/setup_tk_runtime.ps1`
- Tkinter-only tests under `tests/`

Do not remove automatically:

- `data/input/`
- `flutter_app/tool/sync_learning_assets.ps1`
- Backend/API code used by Flutter or content tooling.
- Content audit scripts.
- Model experiments that are still intentionally maintained outside the product UI.

## Phase 5: Legacy Data Cleanup

After desktop removal, clean up compatibility data in separate changes:

- Revisit legacy progress fields in `data/input/hebrew_words.json`.
- Revisit fallback fields that were kept only for desktop compatibility.
- Remove obsolete generated asset instructions through the normal asset sync path.
- Remove obsolete DB files if they are not used by tooling, backend work, or experiments.

## Validation Gate

Before deleting desktop code:

```powershell
cd flutter_app
powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1
flutter analyze
flutter test
```

After deleting desktop code:

- Run Flutter validation again.
- Run remaining Python tests only for backend, tooling, content integrity, and model experiments that still exist.
- Search for stale desktop references with `rg "Tkinter|desktop|src/main.py|tk_runtime|setup_tk_runtime"`.
