# Mobile UX Replatform Plan

## Status
- Drafted on 2026-04-14.
- This document is the working contract for the mobile UX restructuring in `flutter_app/`.
- Visual language stays intact unless explicitly revised later.

## Context
- The current mobile app already has a coherent visual style.
- The current information architecture does not scale well for future growth in exercises, modules, and learning flows.
- The main UX problem is structural, not visual.

## Fixed Constraints
- Keep the current color palette and overall visual tone.
- Keep the current calm, readable, touch-friendly style.
- Do not redesign for novelty.
- Do not introduce a second source of truth for learning content.
- Do not mix UX restructuring with content migration.
- Prefer narrow vertical slices over broad refactors.

## Product Goal
Restructure the mobile app so it can grow from a set of separate sections into a scalable learning product with:
- clear top-level navigation
- consistent learning and practice flows
- reusable UI patterns for future modules
- predictable places for progress, recommendations, and new exercise types

## Current Problems To Solve
1. Bottom navigation is overloaded and already at scaling limit.
2. Content types and exercise modes are mixed at the same navigation level.
3. Home screen emphasizes inventory counts more than user action.
4. List screens use similar visual language but do not share a strict interaction model.
5. Practice screens work, but they are not yet built as one extensible exercise system.

## Product Principles
1. Navigation should reflect user intent, not internal data categories.
2. Root navigation must remain stable as the product grows.
3. New modules should fit existing patterns instead of creating new UI logic.
4. Home must answer "what should I do next?"
5. Progress should be readable across content, practice, and sessions.
6. Shared widgets and theme tokens must be preferred over per-screen styling.

## Target Information Architecture
The mobile app should move to five top-level areas:

1. `Головна`
   - continue learning
   - today's recommended actions
   - compact progress overview
   - quick entry into active work

2. `Вчити`
   - words
   - verbs
   - guided learning modules
   - future structured learning content

3. `Практика`
   - flashcards
   - writing
   - future exercises: quizzes, listening, matching, review drills

4. `Матеріали`
   - reading
   - guide/reference
   - searchable study materials

5. `Ще`
   - settings
   - future stats and utility screens
   - overflow actions that do not belong in the core learning loop

## Mapping From Current Screens
- `HomeScreen` -> remains root `Головна`, but changes role to dashboard
- `WordsScreen` -> moves under `Вчити`
- `VerbsScreen` -> moves under `Вчити`
- `GuideScreen` -> moves under `Матеріали`
- `ReadingScreen` -> moves under `Матеріали`
- `FlashcardsScreen` -> moves under `Практика`
- `WritingScreen` -> moves under `Практика`
- `AppShellScreen` -> becomes the main navigation orchestration point for the new IA

## UX Requirements

### Navigation
- Bottom navigation must have no more than 5 root destinations.
- Root destinations must remain stable when new modules are added.
- No new exercise type should require a new bottom-nav item.
- Root labels should describe user intent, not implementation detail.

### Home
- The first visible section must guide action, not show broad inventory stats.
- Home should prioritize:
  - continue current work
  - recommended next step
  - compact progress
  - quick actions
- Summary counts may remain, but only as supporting information.

### Learn Area
- Learning catalogs should follow one shared structure:
  - title
  - short explanation
  - search
  - filters/status
  - item list
  - empty state
- Item density must support larger datasets than the app has today.

### Practice Area
- All practice modes should share one conceptual skeleton:
  - session header
  - progress
  - task
  - answer/control area
  - feedback
  - session summary
- New exercise types must be able to reuse this skeleton.

### Materials Area
- Reading and guide/reference should use compatible list behavior and status logic.
- Large material collections must support grouping, filtering, and future recommendations.

### Progress
- Progress semantics should be unified across screens where possible.
- At minimum, the system should consistently support:
  - new
  - in progress
  - review
  - completed
- Progress summaries should not be recomputed differently on each screen without reason.

## Non-Goals For This Phase
- No content-model rewrite.
- No data sync redesign.
- No backend or storage migration.
- No visual rebrand.
- No major typography experiment.

## Implementation Strategy For AI Work
All AI work should be split into narrow tasks with explicit file boundaries.

Each AI task must define:
- objective
- allowed files
- forbidden files
- acceptance criteria
- validation commands

Preferred task size:
- one architectural slice or one screen
- roughly 3-6 touched files
- avoid mixing shell/navigation changes with deep screen redesign unless required

Execution order:
- `flutter_app/docs/execution_order.md`

## Work Plan

### Phase 0. Architecture Contract
Goal:
- lock the target structure before UI refactors begin

Outputs:
- this document
- future follow-up task specs derived from it

### Phase 1. Shared UX Foundation
Goal:
- create reusable theme and widget primitives for the new structure

Expected work:
- expand `lib/theme/app_theme.dart`
- add shared widgets for page headers, section cards, search bars, status chips, and action blocks

Done when:
- at least one screen uses shared primitives instead of local styling only
- new widgets cover the repeated patterns used by the next phases

### Phase 2. App Shell Refactor
Goal:
- replace the overloaded root navigation with the new 5-area model

Expected work:
- refactor `lib/screens/app_shell_screen.dart`
- introduce container screens if needed for `Вчити`, `Практика`, `Матеріали`, `Ще`
- task spec: `flutter_app/docs/tasks/02_app_shell_refactor.md`

Done when:
- root navigation has at most 5 destinations
- all current user flows remain reachable
- flashcards and writing are no longer root destinations

### Phase 3. Home Refactor
Goal:
- turn home into a dashboard-oriented landing screen

Expected work:
- rewrite `lib/screens/home_screen.dart`
- prioritize continue/recommendation/progress over inventory cards
- task spec: `flutter_app/docs/tasks/03_home_dashboard_refactor.md`

Done when:
- first viewport is action-oriented
- summary metrics are demoted to supporting role

### Phase 4. Learn Catalog Standardization
Goal:
- align learning catalogs under one scalable interaction model

Expected work:
- refactor `WordsScreen`
- refactor `VerbsScreen`
- optionally introduce shared catalog widgets before refactoring both
- first task spec: `flutter_app/docs/tasks/04_words_catalog_refactor.md`
- follow-up task spec: `flutter_app/docs/tasks/05_verbs_catalog_refactor.md`

Done when:
- learn screens share a common list/search/filter structure
- list density supports larger datasets

### Phase 5. Materials Standardization
Goal:
- align reading and reference under one scalable catalog model

Expected work:
- refactor `GuideScreen`
- refactor `ReadingScreen`
- first task spec: `flutter_app/docs/tasks/06_guide_catalog_refactor.md`
- follow-up task spec: `flutter_app/docs/tasks/07_reading_catalog_refactor.md`

Done when:
- both screens share status and list interaction patterns

### Phase 6. Practice System Foundation
Goal:
- make practice screens extensions of one exercise framework

Expected work:
- extract shared practice layout primitives
- refactor `FlashcardsScreen`
- refactor `WritingScreen`
- first task spec: `flutter_app/docs/tasks/08_practice_foundation.md`
- follow-up task spec: `flutter_app/docs/tasks/09_flashcards_refactor.md`
- follow-up task spec: `flutter_app/docs/tasks/10_writing_refactor.md`

Done when:
- both practice screens share a visible common skeleton
- a future exercise mode can be added without inventing a new page structure

### Phase 7. Unified Progress Layer
Goal:
- align progress language across home, catalogs, and practice

Expected work:
- create shared progress summary helpers/services
- reduce duplicated progress logic in screens
- task spec: `flutter_app/docs/tasks/11_unified_progress_layer.md`

Done when:
- progress states are consistent across the app
- screens rely on shared logic where practical

## Execution Rules
1. Finish shell architecture before broad screen-by-screen polish.
2. Do not redesign individual screens against the old IA.
3. Introduce shared primitives before repeated refactors.
4. Validate after every code phase with:
   - `flutter analyze`
   - `flutter test`
5. If a task starts requiring model/service changes, stop and split it.

## Immediate Next Step
Create the first implementation task for Phase 1:
- define shared UX primitives and theme extensions without changing app logic
- task spec: `flutter_app/docs/tasks/01_shared_ux_foundation.md`
