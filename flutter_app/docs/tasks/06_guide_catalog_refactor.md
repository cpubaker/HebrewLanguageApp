# Task 06: Guide Catalog Refactor

## Purpose
Refactor `GuideScreen` into the first scalable catalog screen for the `Матеріали` area.

This task should establish the pattern for structured study materials:
- clear header
- discoverability
- progress/status visibility
- scalable list behavior
- support for continuation of reading/study

The result should serve as the reference pattern for later refactoring of `ReadingScreen`.

## Why This Task Exists
The guide/reference area already contains structured educational content, but as the number of topics grows, the screen needs a stronger catalog model.

Unlike the learn-area catalogs, this screen is primarily about:
- browsing material
- understanding status
- resuming reading
- navigating a larger collection without friction

## Scope
In scope:
- refactor `GuideScreen`
- improve the top section structure
- strengthen search/discovery and status presentation
- make the lesson/topic list more scalable
- preserve lesson opening behavior

Out of scope:
- navigation changes
- redesign of home
- redesign of words, verbs, reading, flashcards, or writing
- service/model changes
- persistence changes
- content changes

## Allowed Files
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/widgets/*`
- `flutter_app/lib/theme/app_theme.dart`

You may create new files only inside:
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/words_screen.dart`
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
`GuideScreen` should behave like a scalable materials catalog, not just a long stack of topic cards.

The screen should make it easy to:
- understand what the section contains
- find the next useful topic
- see progress/status at a glance
- resume work in partially completed materials

### Materials Pattern
The screen should align with the `Матеріали` area concept, which differs from `Вчити`:
- more emphasis on topic status and progression
- less emphasis on compact drill-like scanning
- stronger support for continue/resume behavior

The result should still feel visually consistent with the rest of the app.

### Header And Discovery
The top section should support:
- title
- short explanation
- summary/progress context
- search or discovery affordance
- room for future filtering/grouping

The exact implementation can stay pragmatic, but the structure should clearly scale better than the current version.

### Status Logic
Use current available data to make lesson status meaningful and visible.

At minimum, the screen should clearly support states such as:
- unread
- in progress
- completed

If current stored state does not fully support a distinct in-progress state, use the best available semantics without inventing new backend state.

### List Behavior
The topic list should be easier to navigate as the collection grows.

Refine the list so that:
- topic identity is clear
- status is readable quickly
- category/group information is legible
- the list remains comfortable with many more items

Do not turn the screen into a dense admin list. It still needs to feel readable and inviting.

### Preserve Existing Functional Behavior
- keep lesson opening behavior working
- keep current document-loading flow
- keep status persistence behavior intact

## Acceptance Criteria
1. `GuideScreen` has a clearer scalable materials-catalog structure.
2. The top section improves discovery and progress awareness.
3. Topic status is more legible and useful at catalog level.
4. The list is more scalable without losing readability.
5. Existing lesson opening and persistence behavior still work.
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
- This is the first catalog pattern for the `Матеріали` area, not a copy of the learn-area pattern.
- Reuse shared widgets where they fit, but preserve the materials-specific role of the screen.
- If a richer status model requires service changes, do not add them in this task.
- Favor continuation, readability, and status clarity over decorative complexity.

## Suggested Prompt For AI
```text
Implement Task 06 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/06_guide_catalog_refactor.md.

Goal:
Refactor GuideScreen into a scalable materials-catalog screen with stronger discovery, clearer status visibility, and better support for resuming study.

Allowed files:
- flutter_app/lib/screens/guide_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- words screen
- verbs screen
- reading screen
- flashcards screen
- writing screen
- services
- models
- assets
- content files

Requirements:
- Keep the current palette and tone
- Improve header/discovery/progress structure
- Make topic status more legible
- Improve scalability of the list
- Preserve lesson opening and persistence behavior

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
