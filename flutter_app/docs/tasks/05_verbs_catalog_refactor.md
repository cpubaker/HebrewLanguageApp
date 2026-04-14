# Task 05: Verbs Catalog Refactor

## Purpose
Refactor `VerbsScreen` so it follows the scalable learn-catalog pattern established by `WordsScreen`, while preserving the fact that verbs are presented as lesson-like entries rather than simple vocabulary cards.

This task extends the `Вчити` area pattern without forcing unlike content into the exact same UI.

## Why This Task Exists
After `WordsScreen` becomes the first strong learn-area catalog, `VerbsScreen` should align with the same structural logic:
- clear header
- strong search/discovery
- scalable list behavior
- reusable top-of-screen patterns

At the same time, verbs are not identical to words. The screen needs to keep its own lesson-oriented interaction model.

## Scope
In scope:
- refactor `VerbsScreen`
- align its top structure with the learn-catalog pattern
- improve scanability and discovery
- preserve lesson-entry behavior and verb-specific context

Out of scope:
- navigation changes
- redesign of home
- redesign of words, guide, reading, flashcards, or writing
- service/model changes
- persistence changes
- content changes

## Allowed Files
- `flutter_app/lib/screens/verbs_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Catalog Role
`VerbsScreen` should behave like a scalable learn catalog for verb lessons.

The screen should make it easy to:
- understand what the section contains
- search or discover lessons quickly
- scan a large lesson list efficiently
- open a lesson with minimal friction

### Alignment With Learn Pattern
The screen should visibly align with the learn-area catalog pattern introduced in `WordsScreen`, especially in:
- page header structure
- search/discovery area
- stats/status presentation
- overall rhythm and spacing

It should feel like part of the same product area, not an unrelated screen.

### Preserve Verbs-Specific Nature
Do not flatten verbs into a words-style card list if that harms the lesson-oriented flow.

The screen should preserve:
- lesson-style entry points
- verb-specific summary or count information
- lesson opening behavior
- audio-related entry context if currently present in the screen flow

### Search And Discovery
The screen should support fast discovery of lessons.

At minimum:
- keep or improve search/discovery
- make the current visible scope understandable
- prepare the screen for future status/grouping without requiring model changes now

If meaningful status slicing is not fully available from current data, keep this task lighter and focus on search + scalable structure rather than inventing fake status semantics.

### List Density
The lesson list should become more scan-friendly and scalable.

Refine the list so that:
- entries remain touch-friendly
- the visual hierarchy is cleaner
- key identifying information is easier to scan
- the list can comfortably grow beyond current content size

## Acceptance Criteria
1. `VerbsScreen` visibly aligns with the learn-catalog pattern used for words.
2. The top section has a clear reusable catalog structure.
3. The list is more scan-friendly and scalable than before.
4. Verb lessons remain clearly lesson-oriented, not reduced to generic vocabulary cards.
5. Existing lesson opening behavior is preserved.
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
- Align pattern, not sameness. The goal is consistency, not forced uniformity.
- Reuse shared widgets where they help.
- If the current data does not support strong status filters, do not invent new app state just to match words.
- Favor scalable list behavior over decorative complexity.

## Suggested Prompt For AI
```text
Implement Task 05 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/05_verbs_catalog_refactor.md.

Goal:
Refactor VerbsScreen so it aligns with the scalable learn-catalog pattern while preserving its lesson-oriented nature.

Allowed files:
- flutter_app/lib/screens/verbs_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- words screen
- other feature screens
- services
- models
- assets
- content files

Requirements:
- Keep the current palette and tone
- Align the top structure with the learn-area pattern
- Improve search/discovery and list scanability
- Preserve lesson-entry behavior
- Do not invent new model or backend state

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
