# Desktop Retirement Completion

## Outcome

The legacy Tkinter desktop client has been retired and removed from the repository.

Flutter in `flutter_app/` is the only supported product surface. Durable learning content remains in `data/input/`, and Flutter runtime assets are generated with `flutter_app/tool/sync_learning_assets.ps1`.

## Removed

- Legacy Python desktop runtime and UI code.
- Bundled Tcl/Tk runtime files.
- Desktop setup script.
- Python tests that existed only to validate desktop runtime, UI widgets, desktop sessions, path wiring, or desktop persistence mechanics.
- Obsolete Python model and database experiments that lived inside the retired desktop tree.

## Kept

- `flutter_app/` as the active app.
- `data/input/` as the learning content source of truth.
- `backend/ai_api/` as optional backend/API support.
- Content and backend validation tests:
  - `tests/test_content_integrity.py`
  - `tests/test_ai_api.py`
- Content generation and audit scripts under `scripts/`.

## Validation

Remaining Python validation:

```powershell
python -m unittest discover -s tests -v
```

Flutter validation:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Follow-Up Cleanup

- Revisit legacy progress fields in `data/input/hebrew_words.json`.
- Revisit fallback fields that were kept only for older consumers.
- Keep generated Flutter asset instructions synchronized through the normal asset sync path.
