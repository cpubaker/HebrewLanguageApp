# Technical Refactor Execution Order

## Purpose
This document defines the execution order for the technical refactor tasks in `flutter_app/docs/tasks/`.

Use this file to prevent AI agents from starting storage or platform work before the codebase has the right seams.

## Rule
Execute tasks in order unless a task explicitly says otherwise.

Do not start a later task early just because it looks more interesting. The early tasks reduce migration risk for the later ones.

## Task Order

### Wave 1: Identity And Persistence Foundations
1. `flutter_app/docs/tasks/12_stable_lesson_identity.md`
2. `flutter_app/docs/tasks/13_progress_repository_boundary.md`
3. `flutter_app/docs/tasks/14_word_progress_store_migration.md`

Why this order:
- lesson identity should stabilize before persistence abstractions depend on it
- repository boundaries should exist before changing storage engines
- word progress migration is safer after the UI no longer depends directly on concrete stores

### Wave 2: Loading And Root Architecture
4. `flutter_app/docs/tasks/15_learning_bundle_loading_split.md`
5. `flutter_app/docs/tasks/16_app_shell_composition_refactor.md`

Why this order:
- loading responsibilities should be clarified before reorganizing the root shell around them
- shell refactoring is easier once loaders and hydrators are cleaner

### Wave 3: Product Readiness
6. `flutter_app/docs/tasks/17_entitlements_foundation.md`
7. `flutter_app/docs/tasks/18_ios_readiness_baseline.md`

Why this order:
- entitlement seams should exist before future premium work lands
- iOS readiness should happen after the app core is less coupled

## Hard Dependencies
- Task 13 depends on Task 12
- Task 14 depends on Task 13
- Task 16 depends on Tasks 13 and 15
- Task 17 depends on Task 16 being reasonably stable
- Task 18 should not start until Tasks 12 through 17 are complete or explicitly frozen

## Recommended Checkpoints

### Checkpoint A
After Tasks 12-14:
- run `flutter analyze`
- run `flutter test`
- manually verify that word, guide, and reading progress still load correctly

### Checkpoint B
After Tasks 15-16:
- run `flutter analyze`
- run `flutter test`
- manually verify startup, shell navigation, reload, and persistence error handling

### Checkpoint C
After Tasks 17-18:
- run `flutter analyze`
- run `flutter test`
- manually verify settings and any gated UI entry points
- if on macOS, validate iOS project generation and an iOS simulator build

## Execution Guidance For AI
- One task per PR is preferred.
- Do not merge storage migration and shell restructuring into one change.
- If a task starts requiring a content rewrite in `data/input/`, stop and split it.
- Preserve user progress as a release-blocking concern.
- Prefer repository and service seams over screen-local patches.

## Planning Close
Planning is complete once this document, the roadmap, and all current task specs are committed.
