# Task 11: Unified Progress Layer

## Purpose
Create a shared progress-summary layer so the app can describe user progress consistently across home, catalogs, and practice-related entry points without duplicating status logic in each screen.

This task should unify semantics and aggregation logic, not redesign storage or exercise behavior.

## Why This Task Exists
Progress is currently derived in multiple places with screen-local logic:
- home derives word progress summary on its own
- flashcards and writing expose session stats independently
- guide and reading rely on `GuideLessonStatus`

This is acceptable for a smaller app, but not for a growing product. As the app expands, progress language must become more consistent and reusable.

## Scope
In scope:
- create shared progress-summary helpers or services
- centralize reusable progress/status aggregation logic
- define consistent progress semantics where current data allows
- update screens to consume shared summary logic where practical

Out of scope:
- storage redesign
- persistence schema changes
- model changes
- changes to scoring rules in flashcards or writing
- navigation changes
- content changes

## Allowed Files
- `flutter_app/lib/services/*`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/services/`
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

Do not modify:
- persistence store formats
- `FlashcardSession` behavior
- `WritingSession` behavior

## Requirements

### Core Goal
The app should stop recomputing equivalent progress semantics independently in multiple screens when the same summary can be shared.

This task should introduce a common layer that supports:
- word-learning summaries
- materials status summaries
- compact progress metrics for home and catalogs

### Progress Semantics
Use the current data model to define consistent semantics where possible.

At minimum, the layer should support app-wide concepts such as:
- new / unseen
- in progress / studying
- needs review
- completed / known / read

These semantics do not need to collapse unlike domains into one identical enum if that would hide real differences. The important part is consistent meaning and reusable aggregation.

### Domain-Specific Reality
Respect the fact that the app currently has more than one kind of progress source:
- word practice progress from correct/wrong and writing counters
- materials progress from `GuideLessonStatus`
- live session state from flashcards and writing sessions

The shared layer should unify summary language where practical, without pretending these domains are identical.

### Integration Direction
At minimum, update the screens that currently derive repeated progress summaries locally if they can safely adopt the new layer.

Likely candidates:
- `HomeScreen`
- `WordsScreen`
- `GuideScreen`
- `ReadingScreen`

Flashcards and writing may adopt shared semantic labels or summary helpers where useful, but this task should not force a deep rewrite of session-specific UI.

### Technical Constraints
- Prefer plain Dart helpers/services over heavy abstraction.
- Prefer immutable summary objects over dynamic maps.
- Do not introduce a new package.
- Do not change persistence data shape.
- Do not move screen-specific UI state into the progress layer.

## Acceptance Criteria
1. Shared progress-summary code exists in `lib/services/`.
2. Repeated summary logic is reduced in at least the main screens that currently derive it locally.
3. Progress semantics are clearer and more consistent across words and materials.
4. No persistence format, model, or session-rule changes were introduced.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This is a semantic and aggregation task, not a storage rewrite.
- Avoid forcing one universal progress model if it makes the code less honest.
- Favor small, explicit summary classes over “helper soup”.
- If a screen needs to keep local session state, let it keep local session state.

## Suggested Prompt For AI
```text
Implement Task 11 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/11_unified_progress_layer.md.

Goal:
Create a shared progress-summary layer so Home, catalogs, and related screens use more consistent progress semantics and aggregation logic.

Allowed files:
- flutter_app/lib/services/*
- flutter_app/lib/screens/home_screen.dart
- flutter_app/lib/screens/words_screen.dart
- flutter_app/lib/screens/guide_screen.dart
- flutter_app/lib/screens/reading_screen.dart
- flutter_app/lib/screens/flashcards_screen.dart
- flutter_app/lib/screens/writing_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- models
- assets
- content files
- persistence store formats
- FlashcardSession behavior
- WritingSession behavior

Requirements:
- Introduce shared progress-summary helpers/services
- Reduce duplicated summary logic in screens
- Keep semantics consistent where current data allows
- Do not redesign storage or scoring rules

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
