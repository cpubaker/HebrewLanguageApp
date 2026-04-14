# Task 04: Words Catalog Refactor

## Purpose
Refactor `WordsScreen` into the first scalable catalog screen for the `Вчити` area.

This task should establish the interaction pattern for large learning catalogs:
- clear header
- strong search
- compact status/filter controls
- scalable list density
- predictable item interactions

The result should serve as the reference pattern for future learn-area catalogs such as verbs.

## Why This Task Exists
The current words screen is already functional and readable, but it is still tuned for the app's current size rather than for future growth.

As the product expands, the words catalog must support:
- larger datasets
- clearer list hierarchy
- more structured filtering/status views
- better repeatability across other learn catalogs

## Scope
In scope:
- refactor `WordsScreen`
- improve the top section structure
- standardize search and status/filter presentation
- tune list density for scaling
- preserve current word details and audio behavior

Out of scope:
- navigation changes
- redesign of home
- redesign of verbs, guide, reading, flashcards, or writing
- service/model changes
- persistence changes
- content changes

## Allowed Files
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
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

### Catalog Role
`WordsScreen` should behave like a scalable learning catalog, not just a searchable dump of cards.

The screen should make it easy to:
- search quickly
- understand the current visible slice
- scan many items efficiently
- open word details without friction

### Header And Search
The top area should follow a strong, reusable catalog pattern:
- title
- short supporting explanation
- search input
- compact stats/status controls

The screen should feel ready to accommodate richer filtering later, even if this task only introduces a minimal initial version.

### Status / Filter Direction
Use the best available current data to expose useful catalog slices.

At minimum, the screen should support a compact way to distinguish between:
- all words
- unseen/new words
- reviewed words or known words
- words that need review

Exact labels may vary if the current data semantics require better phrasing.

Do not introduce new backend state just to support filtering.

### List Density
The current word cards are readable, but the long-term catalog needs better scanning efficiency.

Refine the list so that:
- cards remain touch-friendly
- the list feels lighter and faster to scan
- the most important information remains obvious:
  - translation
  - transcription
  - Hebrew
  - compact progress/audio signals

### Preserve Existing Functional Behavior
- keep search behavior working
- keep details bottom sheet working
- keep audio actions working
- keep scroll-to-top behavior unless there is a strong reason to simplify it

### Reuse Direction
Where practical, extract reusable catalog primitives that later tasks can reuse for verbs and other learn screens.

Do not over-abstract if the pattern is not yet proven.

## Acceptance Criteria
1. `WordsScreen` has a clearer scalable catalog structure.
2. The top section uses a reusable search/header/status pattern.
3. The screen exposes useful status-based slicing using current progress data.
4. The list is more scan-friendly than before while keeping touch usability.
5. Existing details, audio, and search behavior still work.
6. No shell, services, models, or persistence logic were changed.
7. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This task should create the first strong catalog pattern for the `Вчити` area.
- Prefer practical status slices over fake complexity.
- If richer filtering requires model changes, stop and keep the filter layer derived from existing data only.
- Keep the screen visually aligned with the current palette and tone.

## Suggested Prompt For AI
```text
Implement Task 04 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/04_words_catalog_refactor.md.

Goal:
Refactor WordsScreen into a scalable learn-catalog screen that can act as the pattern for future learn-area modules.

Allowed files:
- flutter_app/lib/screens/words_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- other feature screens
- services
- models
- assets
- content files

Requirements:
- Keep the current palette and tone
- Strengthen the header/search/status structure
- Add useful status-based catalog slicing from existing progress data
- Make the list more scan-friendly
- Preserve search, audio, word details, and scroll behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
