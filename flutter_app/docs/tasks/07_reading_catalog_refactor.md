# Task 07: Reading Catalog Refactor

## Purpose
Refactor `ReadingScreen` so it becomes the second scalable catalog screen for the `Матеріали` area, aligned with the materials-pattern introduced by `GuideScreen` while preserving its reading-specific structure.

This task should make the reading area easier to browse, resume, and scale as the number of texts grows.

## Why This Task Exists
The current reading screen already communicates level and read status, but it needs a stronger catalog model for future growth.

Unlike the guide/reference screen, reading content has its own important structure:
- reading levels
- reading progress
- text-by-text continuation
- clearer navigation across a large set of texts

The goal is consistency with the `Матеріали` area without flattening the reading experience into a generic materials list.

## Scope
In scope:
- refactor `ReadingScreen`
- strengthen the top structure for discovery and progress context
- improve readability and scalability of the text list
- preserve level-based organization where it is meaningful
- preserve text opening and reading-status behavior

Out of scope:
- navigation changes
- redesign of home
- redesign of words, verbs, guide, flashcards, or writing
- service/model changes
- persistence changes
- content changes

## Allowed Files
- `flutter_app/lib/screens/reading_screen.dart`
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
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Catalog Role
`ReadingScreen` should behave like a scalable reading catalog inside the `Матеріали` area.

The screen should make it easy to:
- understand available reading content
- find an appropriate next text
- resume reading from the current level or active text
- understand reading progress at a glance

### Materials Alignment
The screen should align with the broader materials-catalog pattern used by `GuideScreen`, especially in:
- page header structure
- discovery/progress framing
- list interaction consistency
- status visibility

It should feel like part of the same area, not like a separate product.

### Preserve Reading-Specific Structure
Do not remove the reading-specific level structure if it remains useful.

The refactor should preserve and clarify:
- level grouping
- reading status visibility
- text identity
- text opening behavior

If grouping by level is already the right model, improve it rather than flattening it.

### Header And Discovery
The top section should support:
- title
- short explanation
- reading progress context
- search/discovery affordance or filter entry point
- room for future grouping/filter expansion

The exact feature set can stay pragmatic, but the top area should be more scalable than the current version.

### Status And Resume Behavior
Use the current available data to improve catalog-level visibility of:
- unread
- in progress if practical
- completed

If the current data model does not support a true in-progress distinction, use the best available semantics without introducing new backend state.

The screen should better support the user question:
- what should I read next?

### List Behavior
The text list should scale better as the reading library grows.

Refine the list so that:
- grouped sections remain legible
- individual texts are easy to scan
- status and level are readable without clutter
- the layout stays inviting rather than becoming too dense

## Acceptance Criteria
1. `ReadingScreen` visibly aligns with the materials-catalog pattern.
2. The top section improves discovery and progress context.
3. Reading levels and reading-specific structure are preserved or improved.
4. Text status is easier to understand at catalog level.
5. Existing text opening and persistence behavior still work.
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
- Align the pattern, but preserve the reading area's identity.
- Reuse shared widgets where helpful.
- If stronger filtering would require model or service changes, do not add them in this task.
- Favor clarity, grouping, and continuation support over extra decoration.

## Suggested Prompt For AI
```text
Implement Task 07 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/07_reading_catalog_refactor.md.

Goal:
Refactor ReadingScreen into a scalable materials-catalog screen aligned with GuideScreen while preserving reading-specific level grouping and progress behavior.

Allowed files:
- flutter_app/lib/screens/reading_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- words screen
- verbs screen
- guide screen
- flashcards screen
- writing screen
- services
- models
- assets
- content files

Requirements:
- Keep the current palette and tone
- Improve header/discovery/progress framing
- Preserve or improve level grouping
- Make reading status easier to scan
- Preserve text opening and persistence behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
