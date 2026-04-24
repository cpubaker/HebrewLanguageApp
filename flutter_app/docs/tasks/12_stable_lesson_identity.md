# Task 12: Stable Lesson Identity

## Purpose
Refactor lesson identity so guide and reading progress no longer depend primarily on `assetPath`.

The app already has `lessonId` in `LessonEntry`. This task makes that identity durable enough to become the source of truth for lesson progress.

## Why This Task Exists
The current guide progress store already contains a large manual renamed-path map. That is a warning sign.

If lesson progress keeps depending on file paths:
- content reordering stays expensive
- file renames remain risky
- future content expansion will accumulate migration debt

This task creates a stable identity layer before deeper persistence work happens.

## Scope
In scope:
- make lesson progress read and write by stable lesson identity
- preserve backward compatibility with existing stored path-based progress
- centralize any path-to-ID migration logic
- keep guide and reading behavior unchanged from the user's point of view

Out of scope:
- moving word progress out of `shared_preferences`
- redesigning guide or reading screens
- adding backend sync
- changing content files unless absolutely required

## Allowed Files
- `flutter_app/lib/models/*`
- `flutter_app/lib/services/learning_bundle_loader.dart`
- `flutter_app/lib/services/guide_progress_store.dart`
- `flutter_app/lib/services/reading_progress_store.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/models/`
- `flutter_app/lib/services/`
- `flutter_app/test/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/theme/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Stable Identity
- lesson progress should use stable IDs where they exist
- the read/write API should no longer treat raw asset paths as the primary durable key
- `LessonEntry.lessonId` should become the preferred identity for guide and reading items

### Backward Compatibility
- existing users must not lose stored guide or reading progress
- previously stored path-based progress should migrate forward automatically
- migration should be deterministic and covered by tests

### Centralized Mapping
- migration logic should not remain scattered across UI code
- if any path compatibility remains temporarily necessary, keep it centralized behind one service boundary
- do not keep growing a giant path-rename map in multiple places

### Behavior Preservation
- guide and reading screens should still show the same effective statuses after migration
- status writes should still support unread, studying, and read semantics

## Acceptance Criteria
1. Guide and reading progress use stable lesson identity as the durable key.
2. Existing stored path-based progress is migrated or resolved without user-visible loss.
3. Migration logic is centralized instead of screen-local.
4. Existing status behavior remains unchanged.
5. Tests cover the migration path and current read/write semantics.
6. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Prefer using existing metadata and `lessonId` rather than inventing a second identity field.
- If some lessons lack stable IDs, define a narrow fallback strategy and document it in code.
- Do not solve word progress in this task.

## Suggested Prompt For AI
```text
Implement Task 12 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/12_stable_lesson_identity.md.

Goal:
Move guide and reading progress away from asset-path identity toward stable lesson identity, while preserving backward compatibility for existing stored progress.

Allowed files:
- flutter_app/lib/models/*
- flutter_app/lib/services/learning_bundle_loader.dart
- flutter_app/lib/services/guide_progress_store.dart
- flutter_app/lib/services/reading_progress_store.dart
- flutter_app/lib/screens/guide_screen.dart
- flutter_app/lib/screens/reading_screen.dart
- flutter_app/test/*

Do not modify:
- app shell
- home screen
- words/flashcards/writing screens
- theme
- assets
- content files

Requirements:
- use stable lesson identity as the durable key
- preserve existing stored progress
- keep migration logic centralized
- preserve current status behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
