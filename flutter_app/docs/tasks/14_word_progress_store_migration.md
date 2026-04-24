# Task 14: Word Progress Store Migration

## Purpose
Migrate word progress persistence away from one large `shared_preferences` JSON blob to a structured local store.

This task should happen only after the progress repository boundary exists.

## Why This Task Exists
Right now each word save rewrites one large JSON payload. That does not scale well as the number of studied words grows.

This creates future risks:
- slower writes
- more migration friction
- more fragile corruption handling
- harder future sync work

## Scope
In scope:
- replace the current word-progress blob storage with a structured local store
- preserve the existing word progress data model and behavior
- migrate existing stored word progress forward automatically
- keep current screens unchanged from the user's point of view

Out of scope:
- redesigning word practice logic
- changing lesson progress storage again
- adding cloud sync
- changing content files

## Allowed Files
- `flutter_app/pubspec.yaml`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/lib/app.dart`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/services/`
- `flutter_app/test/`

## Forbidden Files
- `flutter_app/lib/screens/*`
- `flutter_app/lib/theme/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Storage Engine
- use a structured local storage approach suitable for Flutter mobile apps
- the implementation must be realistic for both Android and future iOS use
- do not keep word progress as one monolithic preferences blob

### Migration
- existing users must keep their word progress
- migration from the old preferences payload should happen automatically
- migration should be idempotent and tested
- keep the old payload only as long as needed for safe migration

### Behavioral Stability
- preserve current word progress fields and semantics
- preserve current load and save behavior from the UI point of view
- preserve current error tolerance expectations as much as practical

### Repository Integration
- wire the new storage behind the repository boundary from Task 13
- screen code should not need to know the storage engine changed

## Acceptance Criteria
1. Word progress no longer depends on one large `shared_preferences` JSON blob.
2. Existing word progress migrates forward automatically.
3. The change is hidden behind the repository boundary.
4. Tests cover migration and current persistence semantics.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Prefer a pragmatic mobile-friendly choice over an overengineered abstraction.
- Keep the migration narrow and reversible where possible.
- If a dependency addition is needed, keep it minimal and justify it in code comments or the PR summary.

## Suggested Prompt For AI
```text
Implement Task 14 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/14_word_progress_store_migration.md.

Goal:
Move word progress persistence from a monolithic shared_preferences JSON blob to a structured local store, while preserving existing user progress.

Allowed files:
- flutter_app/pubspec.yaml
- flutter_app/lib/services/*
- flutter_app/lib/models/*
- flutter_app/lib/app.dart
- flutter_app/test/*

Do not modify:
- screens
- theme
- assets
- content files

Requirements:
- structured local storage
- automatic migration from existing stored progress
- preserve current word progress semantics
- hide the storage change behind the repository boundary

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
