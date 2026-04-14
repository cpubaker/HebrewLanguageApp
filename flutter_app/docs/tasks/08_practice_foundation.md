# Task 08: Practice Foundation

## Purpose
Create the shared UI foundation for the `Практика` area before refactoring individual exercise screens.

This task should identify and extract the common session structure already visible in `FlashcardsScreen` and `WritingScreen`, so later practice refactors can reuse one coherent pattern instead of duplicating layout logic.

## Why This Task Exists
The current flashcards and writing screens already share a similar exercise rhythm:
- section header
- active task area
- answer controls
- feedback/result state
- session summary

However, that structure is implemented independently in each screen. Before refactoring the practice screens themselves, the app needs shared practice primitives.

## Scope
In scope:
- introduce reusable practice-area widgets and layout primitives
- define a shared practice skeleton for session-based exercises
- apply the new primitives in a minimal but real way to one or both practice screens if needed
- preserve existing exercise logic and user flows

Out of scope:
- redesign of flashcards session behavior
- redesign of writing session behavior
- changes to exercise scoring logic
- changes to services or models
- navigation changes
- broad visual redesign

## Allowed Files
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/verbs_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Practice Role
The `Практика` area should be built around a recognizable session structure that future exercise types can reuse.

This shared structure should support screens such as:
- flashcards
- writing
- future quizzes
- future listening tasks
- future review drills

### Shared Practice Skeleton
Introduce reusable building blocks for the common session flow. The exact API is up to the implementer, but the foundation should cover most of these concepts:
- practice page header
- active exercise container/scaffold
- progress/session summary block
- stats pill row
- answer feedback/result block
- supporting helper/hint area where relevant

The goal is not to force identical screens, but to make the common structure explicit and reusable.

### Minimal Adoption
This task may include limited adoption in `FlashcardsScreen` and/or `WritingScreen`, but only at the layout primitive level.

Allowed:
- replace duplicated structural widgets with shared ones
- align repeated section patterns
- reduce repeated presentation logic

Not allowed:
- change exercise rules
- change session sequencing behavior
- redesign the full UX of each practice screen beyond what is needed for the shared foundation

### Technical Constraints
- Do not change `FlashcardSession`.
- Do not change `WritingSession`.
- Do not change progress persistence behavior.
- Do not introduce a new state-management package.
- Prefer practical widget extraction over abstract framework building.

### Visual Constraints
- Keep the current palette and tone.
- Keep practice screens readable and calm.
- Avoid turning shared practice UI into generic boilerplate.
- Preserve enough flexibility so flashcards and writing can still feel distinct.

## Acceptance Criteria
1. Shared practice-area widgets or layout primitives exist under `lib/screens/widgets/`.
2. The common session structure between flashcards and writing is explicitly represented in reusable code.
3. Existing exercise behavior is preserved.
4. No services, models, scoring logic, or persistence logic were changed.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Think in terms of a reusable session framework, not just visual cleanup.
- Extract only proven common structure. Do not invent abstraction for pieces that are still very different.
- If a widget starts accumulating exercise-specific conditionals, stop and split it into smaller primitives.
- This task should make the next two tasks easier:
  - flashcards refactor
  - writing refactor

## Suggested Prompt For AI
```text
Implement Task 08 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/08_practice_foundation.md.

Goal:
Create shared UI primitives for the Practice area by extracting the common session structure used by FlashcardsScreen and WritingScreen.

Allowed files:
- flutter_app/lib/screens/flashcards_screen.dart
- flutter_app/lib/screens/writing_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- words screen
- verbs screen
- guide screen
- reading screen
- services
- models
- assets
- content files

Requirements:
- Keep the current palette and tone
- Create reusable practice-area widgets
- Preserve existing exercise logic and session behavior
- Keep adoption limited to shared structural patterns
- Do not change FlashcardSession or WritingSession

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
