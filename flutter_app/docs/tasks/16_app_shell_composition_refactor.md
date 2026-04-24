# Task 16: App Shell Composition Refactor

## Purpose
Refactor the app shell so it becomes a composition root instead of a large mixed-responsibility screen.

This task should use the seams introduced by earlier technical refactor tasks.

## Why This Task Exists
`AppShellScreen` currently combines:
- startup loading
- hydrated app state ownership
- persistence callbacks
- navigation entry orchestration
- shell UI state
- retry behavior
- persistence error rollback logic

That makes the shell harder to change safely and harder for AI agents to work in without accidental regressions.

## Scope
In scope:
- refactor `AppShellScreen` into smaller collaborators
- extract shell-local concerns into well-named helpers, widgets, or controllers
- preserve current UX and navigation behavior
- keep root responsibilities legible

Out of scope:
- redesigning shell IA
- changing feature-screen UX
- introducing a new state-management package
- changing storage engines again

## Allowed Files
- `flutter_app/lib/app.dart`
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/services/*`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/screens/`
- `flutter_app/lib/screens/widgets/`
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

### Composition Root Behavior
- `AppShellScreen` should primarily compose collaborators and route user actions
- persistence orchestration should not live directly in the shell widget
- loading state ownership should be easy to trace

### Maintain Current UX
- preserve current root navigation behavior
- preserve current fullscreen module launches
- preserve current loading, retry, and persistence error feedback
- preserve bottom-nav hide/show behavior

### Refactor Shape
- prefer extracting cohesive collaborators over splitting into many tiny wrappers
- name extracted pieces by responsibility, not by generic patterns
- do not introduce a heavy architectural framework

## Acceptance Criteria
1. `AppShellScreen` is noticeably smaller and more composition-oriented.
2. Persistence and hydration details are no longer mixed directly into shell UI code.
3. Current shell behavior and navigation remain unchanged.
4. Tests continue to cover shell-critical behavior.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Keep this task practical. The goal is not perfect purity.
- If a refactor requires changing feature-screen contracts substantially, stop and split that work.
- Use the earlier repository/loading seams instead of duplicating logic in new helpers.

## Suggested Prompt For AI
```text
Implement Task 16 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/16_app_shell_composition_refactor.md.

Goal:
Refactor AppShellScreen into a composition-oriented shell that delegates loading and persistence concerns to earlier extracted collaborators, while preserving current UX behavior.

Allowed files:
- flutter_app/lib/app.dart
- flutter_app/lib/screens/app_shell_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/services/*
- flutter_app/test/*

Do not modify:
- feature screens beyond minimal integration
- theme
- assets
- content files

Requirements:
- preserve current shell UX
- remove mixed persistence/hydration logic from shell UI code
- keep the architecture pragmatic

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
