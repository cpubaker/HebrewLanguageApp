# Task 13: Progress Repository Boundary

## Purpose
Introduce an app-level progress boundary so UI code stops depending directly on multiple concrete persistence stores.

This task is about architecture, not storage migration yet.

## Why This Task Exists
`AppShellScreen` currently knows too much about:
- loading bundle data
- hydrating word progress
- loading guide and reading statuses
- saving updates back to different stores
- retry and rollback behavior

That coupling makes future changes to storage, sync, migrations, and tests harder than they should be.

## Scope
In scope:
- introduce a progress-focused repository or coordinator boundary
- move hydration and persistence orchestration out of `AppShellScreen`
- preserve current app behavior and current concrete stores
- keep theme persistence unchanged unless needed for composition

Out of scope:
- changing the underlying word storage engine
- redesigning screens
- adding remote sync
- changing lesson content

## Allowed Files
- `flutter_app/lib/app.dart`
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/services/`
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

### Boundary Shape
- UI should depend on one app-level boundary for loading and saving learning progress concerns
- the boundary may be a repository, coordinator, or facade, but its role must be clear
- concrete `shared_preferences` stores should no longer be orchestrated directly from `AppShellScreen`

### Hydration Ownership
- bundle hydration should move behind the new boundary
- screen code should receive already prepared data or simple update callbacks
- rollback/error behavior should remain intact

### No Behavior Regression
- preserve current loading flow
- preserve current save timing
- preserve current snackbar-style persistence failure feedback
- preserve current retry behavior

### Testability
- the new boundary should be straightforward to fake in tests
- add or update tests around hydration and persistence orchestration

## Acceptance Criteria
1. `AppShellScreen` no longer orchestrates multiple concrete progress stores directly.
2. Hydration and save orchestration live behind one app-level boundary.
3. Current progress behavior remains unchanged for users.
4. Tests cover the new orchestration layer.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Keep the abstraction pragmatic. Do not build a generic enterprise repository tree.
- The main goal is to remove persistence orchestration from root UI code.
- This task should make Task 14 smaller.

## Suggested Prompt For AI
```text
Implement Task 13 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/13_progress_repository_boundary.md.

Goal:
Introduce an app-level progress boundary so AppShellScreen no longer coordinates multiple concrete persistence stores directly.

Allowed files:
- flutter_app/lib/app.dart
- flutter_app/lib/screens/app_shell_screen.dart
- flutter_app/lib/services/*
- flutter_app/lib/models/*
- flutter_app/test/*

Do not modify:
- home screen
- feature screens except where integration absolutely requires it
- theme
- assets
- content files

Requirements:
- move hydration and save orchestration behind one boundary
- preserve current behavior and error handling
- keep the abstraction pragmatic

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
