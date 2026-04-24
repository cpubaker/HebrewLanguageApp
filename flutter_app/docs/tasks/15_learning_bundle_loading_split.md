# Task 15: Learning Bundle Loading Split

## Purpose
Refactor app startup loading so content discovery, lightweight catalogs, and progress hydration have clearer boundaries and less unnecessary startup-wide work.

## Why This Task Exists
The current app startup flow still centralizes a lot of work:
- loading words
- loading contexts
- reading guide metadata
- reading lesson catalogs
- scanning assets for lesson entries
- hydrating progress into the full bundle

That is manageable now, but it becomes more expensive and harder to reason about as the content library grows.

## Scope
In scope:
- split loading responsibilities into clearer services
- reduce reliance on global asset-manifest discovery where explicit catalogs already exist
- keep lesson document bodies lazy and cached
- preserve the current user-visible content set and ordering

Out of scope:
- moving content out of assets
- redesigning screens
- changing persistence semantics
- backend sync

## Allowed Files
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/lib/app.dart`
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/services/`
- `flutter_app/lib/models/`
- `flutter_app/test/`

## Forbidden Files
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/theme/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Clear Loading Responsibilities
- separate explicit catalog/index loading from progress hydration concerns
- reduce "everything loads in one place" behavior
- keep document-body parsing in the document loader, not in startup bundle loading

### Discovery Strategy
- do not depend on a full asset manifest scan when a maintained explicit catalog is already available
- preserve current lesson ordering and inclusion behavior
- keep any fallback strategy narrow and documented

### Startup Stability
- current startup flow should remain functionally correct
- the app should still handle loading and retry states cleanly
- do not regress cached document loading behavior

## Acceptance Criteria
1. Startup loading responsibilities are split into clearer services.
2. Lesson discovery no longer relies primarily on full asset-manifest scanning where explicit catalogs exist.
3. User-visible lesson ordering and coverage remain unchanged.
4. Current startup behavior remains stable.
5. Tests cover the updated loading behavior.
6. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This task is about startup structure, not content redesign.
- Do not pull markdown document bodies into a startup preload just to simplify code.
- If content metadata turns out to be incomplete, document the gap and keep the fallback small.

## Suggested Prompt For AI
```text
Implement Task 15 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/15_learning_bundle_loading_split.md.

Goal:
Split startup loading responsibilities so content discovery, catalog loading, and progress hydration are clearer and less coupled.

Allowed files:
- flutter_app/lib/services/*
- flutter_app/lib/models/*
- flutter_app/lib/app.dart
- flutter_app/lib/screens/app_shell_screen.dart
- flutter_app/test/*

Do not modify:
- feature screens except minimal integration if required
- theme
- assets
- content files

Requirements:
- clearer loading service boundaries
- avoid relying primarily on full asset-manifest scanning when explicit catalogs exist
- preserve current lesson ordering and behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
