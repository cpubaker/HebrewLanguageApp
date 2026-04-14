# Task 03: Home Dashboard Refactor

## Purpose
Refactor the mobile home screen so it works as a dashboard-oriented landing page inside the new app architecture.

The home screen should stop behaving like an inventory overview and start guiding the user toward the next useful learning action.

## Why This Task Exists
The current home screen is visually solid, but its first priority is still broad content counts and section previews. That is acceptable for an early app, but not for a growing learning product.

After the app shell is restructured, the home screen should become the main decision point for the user:
- continue active work
- see what is recommended next
- understand compact progress
- jump into the most relevant action

## Scope
In scope:
- restructure `HomeScreen`
- reorder content hierarchy
- introduce a more action-oriented first viewport
- reuse shared UI primitives from Task 01 where practical

Out of scope:
- shell/navigation changes
- redesign of words/verbs/guide/reading/flashcards/writing screens
- service/model changes
- persistence changes
- new data sources

## Allowed Files
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/verbs_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Core Home Role
The first viewport of the home screen must answer:
- what can I continue right now?
- what is the next recommended action?
- what is my current progress in compact form?

The home screen should feel like a landing dashboard, not a catalog browser.

### Content Priorities
The home screen should prioritize, in this order:
1. continue learning / resume action
2. recommended next step
3. quick actions
4. compact progress summary
5. supporting inventory or preview sections

Broad counts may remain, but they must no longer dominate the first screen.

### Interaction Constraints
- Preserve existing callbacks:
  - `onOpenWords`
  - `onOpenFlashcards`
  - `onOpenWriting`
  - `onOpenGuide`
  - `onOpenVerbs`
  - `onOpenReading`
- Preserve current derived progress logic unless a clearer local presentation requires small refactoring.
- Do not introduce new loading or persistence behavior.

### Visual Constraints
- Keep the current palette and general tone.
- Keep the screen calm and readable.
- Avoid “dashboard clutter”.
- Use shared widgets and shared theme patterns where practical.

### Suggested Direction
The exact layout is up to the implementer, but the resulting home screen should likely include:
- a top hero or top summary block with stronger action framing
- a continue/recommendation section near the top
- a compact quick-actions area
- a progress summary block
- optional supporting previews lower on the page

The home screen should not try to expose every part of the product equally.

## Acceptance Criteria
1. `HomeScreen` is visibly restructured around action and progress, not content inventory.
2. The first viewport emphasizes continue/recommendation over broad counts.
3. Existing callbacks and functional behavior are preserved.
4. No shell/navigation logic is changed.
5. No services, models, or persistence logic are changed.
6. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This is a home-screen task, not a full app redesign.
- Do not solve missing product features by inventing new backend state.
- If a desired UI depends on data that does not yet exist, use the best available derived summary from the current bundle.
- Keep the layout practical for future growth.

## Suggested Prompt For AI
```text
Implement Task 03 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/03_home_dashboard_refactor.md.

Goal:
Refactor HomeScreen into a dashboard-oriented landing page that prioritizes continue learning, recommended next actions, quick actions, and compact progress.

Allowed files:
- flutter_app/lib/screens/home_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- services
- models
- assets
- content files
- other feature screens

Requirements:
- Preserve the current palette and tone
- Keep existing callbacks and behavior
- Make the first viewport action-oriented
- Demote broad inventory counts to a secondary role
- Reuse shared primitives where practical

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
