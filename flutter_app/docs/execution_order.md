# Mobile UX Replatform Execution Order

## Purpose
This document defines the execution order for the mobile UX replatform tasks in `flutter_app/docs/tasks/`.

Use this file to avoid running AI tasks in the wrong order or combining dependent tasks too early.

## Rule
Execute tasks in order unless a task explicitly says otherwise.

Do not skip foundation tasks and jump directly into screen refactors.

## Task Order

### Wave 1: Shared Foundation
1. `flutter_app/docs/tasks/01_shared_ux_foundation.md`
2. `flutter_app/docs/tasks/02_app_shell_refactor.md`
3. `flutter_app/docs/tasks/03_home_dashboard_refactor.md`

Why this order:
- shared UI primitives should exist before shell and screen refactors
- shell should be stabilized before home is redesigned in the new IA

### Wave 2: Learn Area
4. `flutter_app/docs/tasks/04_words_catalog_refactor.md`
5. `flutter_app/docs/tasks/05_verbs_catalog_refactor.md`

Why this order:
- words becomes the first strong learn-catalog pattern
- verbs then adapts that pattern while preserving lesson-oriented behavior

### Wave 3: Materials Area
6. `flutter_app/docs/tasks/06_guide_catalog_refactor.md`
7. `flutter_app/docs/tasks/07_reading_catalog_refactor.md`

Why this order:
- guide establishes the first materials-catalog pattern
- reading then aligns with it while preserving level-based reading structure

### Wave 4: Practice Area
8. `flutter_app/docs/tasks/08_practice_foundation.md`
9. `flutter_app/docs/tasks/09_flashcards_refactor.md`
10. `flutter_app/docs/tasks/10_writing_refactor.md`

Why this order:
- shared practice primitives should exist before full exercise-screen refactors
- flashcards proves the pattern
- writing follows while preserving its recall-specific flow

### Wave 5: Shared Progress Semantics
11. `flutter_app/docs/tasks/11_unified_progress_layer.md`

Why this comes last:
- progress semantics are easier to unify after screen-level structures are clearer
- this avoids redesigning summary logic twice

## Hard Dependencies
- Task 02 depends on Task 01
- Task 03 depends on Task 02
- Task 05 depends on Task 04
- Task 07 depends on Task 06
- Task 09 depends on Task 08
- Task 10 depends on Task 08
- Task 11 depends on Tasks 03 through 10 being mostly complete

## Recommended Checkpoints

### Checkpoint A
After Tasks 01-03:
- run `flutter analyze`
- run `flutter test`
- manually verify shell navigation and home entry flow

### Checkpoint B
After Tasks 04-07:
- run `flutter analyze`
- run `flutter test`
- manually verify learn/materials navigation and screen consistency

### Checkpoint C
After Tasks 08-10:
- run `flutter analyze`
- run `flutter test`
- manually verify flashcards and writing session flows

### Checkpoint D
After Task 11:
- run `flutter analyze`
- run `flutter test`
- manually verify progress summaries across home, catalogs, and practice entry points

## Execution Guidance For AI
- One task per PR is preferred.
- Do not combine adjacent tasks unless explicitly decided.
- If a task starts requiring forbidden files, stop and split the work.
- If a task makes the next task much smaller by extracting shared primitives, that is good.
- If a task starts drifting into product decisions not covered by the task spec, stop and ask for clarification.

## Planning Close
Planning is complete once this document, the roadmap, and all current task specs are committed.
