# Task 01: Shared UX Foundation

## Purpose
Create the reusable UI foundation for the mobile UX restructuring without changing app architecture, navigation model, content loading, or persistence.

This is the first implementation task after the planning phase.

## Why This Task Exists
The current app already has a coherent visual style, but repeated UI patterns are implemented locally inside screens. Before changing navigation and screen concepts, the app needs shared primitives that future refactors can reuse.

This task should:
- preserve the current color palette and visual tone
- reduce duplicated styling
- establish reusable building blocks for the next phases

## Scope
In scope:
- theme extensions or shared design tokens
- shared reusable widgets for repeated screen patterns
- minimal adoption of the new primitives on the home screen

Out of scope:
- navigation restructuring
- new root tabs
- data model changes
- service or persistence changes
- content changes
- broad redesign of list screens

## Allowed Files
- `flutter_app/lib/theme/app_theme.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/widgets/*`

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

### Visual Constraints
- Keep the existing palette and general feel.
- Keep the app calm, readable, and touch-friendly.
- Do not introduce a new visual style.
- Do not replace the current design language with generic Material defaults.

### Shared Primitives To Introduce
Add reusable building blocks for the most repeated mobile patterns. The exact API is up to the implementer, but the set should cover at least:
- page section container/card
- page header block with title and subtitle
- search field styling wrapper or reusable search widget
- compact status/stat chip or pill
- reusable action button row or action cluster helper

The shared widgets should be practical, not abstract for the sake of abstraction.

### Theme Work
Expand `app_theme.dart` so future screens can rely on shared values instead of repeating raw styling constants.

This may include:
- component themes
- input decoration theme
- shared button styling
- color role helpers
- reusable shape/radius conventions

Do not over-engineer this into a large design-system framework.

### Minimal Adoption
Refactor `home_screen.dart` to use the new shared primitives in a limited but real way.

Required:
- the home screen must visibly use the new shared UI primitives
- callbacks and existing behavior must remain intact
- current content sections may stay functionally the same

Not required:
- full home dashboard redesign
- changes to product IA

## Acceptance Criteria
1. New shared widgets exist under `lib/screens/widgets/`.
2. `app_theme.dart` contains reusable UI configuration beyond the current minimal setup.
3. `home_screen.dart` uses shared primitives instead of relying only on local ad hoc styling.
4. No navigation logic changes were introduced.
5. No services, models, or persistence logic were changed.
6. The app still builds cleanly.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Prefer a narrow, reusable solution over a broad refactor.
- If a shared widget starts needing screen-specific conditionals, stop and simplify it.
- If the task begins to require changes in `app_shell_screen.dart`, that means scope is drifting and should be split.

## Suggested Prompt For AI
```text
Implement Task 01 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/01_shared_ux_foundation.md.

Goal:
Create shared UX primitives and theme improvements for the Flutter mobile app while keeping the current visual style intact.

Allowed files:
- flutter_app/lib/theme/app_theme.dart
- flutter_app/lib/screens/home_screen.dart
- flutter_app/lib/screens/widgets/*

Do not modify:
- app shell/navigation
- services
- models
- assets
- content files
- any other screens

Requirements:
- Keep the current palette and tone
- Add reusable widgets for repeated screen patterns
- Expand the theme in a pragmatic way
- Refactor HomeScreen to use the new shared primitives
- Preserve existing callbacks and behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
