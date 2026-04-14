# Task 02: App Shell Refactor

## Purpose
Refactor the mobile app shell so the root navigation matches the new scalable information architecture:
- `Головна`
- `Вчити`
- `Практика`
- `Матеріали`
- `Ще`

This task changes the app structure at the shell level only. It does not redesign the internal screens yet.

## Why This Task Exists
The current app shell exposes too many root destinations and mixes content types with exercise modes at the same navigation level. That structure will not scale as the product grows.

Before redesigning individual screens, the app needs a stable root navigation model that future work can build on.

## Scope
In scope:
- refactor root navigation in `AppShellScreen`
- reduce root destinations to at most 5
- introduce lightweight container screens for grouped areas if needed
- remap existing screens into the new root structure

Out of scope:
- redesign of `HomeScreen`
- redesign of list/catalog screens
- redesign of practice screens
- service/model/persistence changes
- content changes
- deep rewrite of per-screen business logic

## Allowed Files
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/lib/screens/widgets/*`

You may create new files only inside:
- `flutter_app/lib/screens/`
- `flutter_app/lib/screens/widgets/`

## Forbidden Files
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/lib/theme/app_theme.dart`
- `flutter_app/assets/**`
- `data/**`

Existing feature screens should not be substantially rewritten:
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/verbs_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`

If any of those files must be touched, changes should be minimal and only for integration.

## Requirements

### Root Navigation
- Bottom navigation must have no more than 5 destinations.
- Root destinations must reflect user intent rather than implementation detail.
- `Картки` and `Письмо` must no longer be root tabs.
- All current flows must remain reachable.

### Target Root Areas
Implement the root structure as:
1. `Головна`
2. `Вчити`
3. `Практика`
4. `Матеріали`
5. `Ще`

The exact internal presentation of these areas may be lightweight for now, but the navigation model must be in place.

### Container Area Behavior
The grouped areas may initially be simple launcher screens or section containers.

Expected grouping:
- `Вчити`
  - words
  - verbs
- `Практика`
  - flashcards
  - writing
- `Матеріали`
  - guide/reference
  - reading
- `Ще`
  - placeholder or future-ready overflow area

The grouped areas do not need final UX polish in this task.

### Technical Constraints
- Preserve current callbacks and loading flow from `AppShellScreen`.
- Preserve current persistence wiring.
- Preserve bottom-nav hide/show behavior if practical.
- Avoid introducing a new state-management package.
- Prefer simple composition over heavy abstraction.

## Acceptance Criteria
1. The app root navigation has at most 5 destinations.
2. The new root destinations follow the target IA.
3. `FlashcardsScreen` and `WritingScreen` are not root tabs anymore.
4. `Words`, `Verbs`, `Guide`, and `Reading` remain reachable through the new grouped structure.
5. Existing loading and persistence wiring in `AppShellScreen` still works.
6. No services or models were changed.
7. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This is a shell task, not a visual redesign task.
- Do not spend scope on polishing grouped-area screens beyond what is needed for usable navigation.
- If internal screen UX starts changing significantly, stop and split it into later tasks.
- `Ще` may be a minimal placeholder if there is no meaningful utility screen yet.

## Suggested Prompt For AI
```text
Implement Task 02 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/02_app_shell_refactor.md.

Goal:
Refactor the Flutter app shell so the root navigation uses the new scalable IA:
- Головна
- Вчити
- Практика
- Матеріали
- Ще

Allowed files:
- flutter_app/lib/screens/app_shell_screen.dart
- flutter_app/lib/screens/home_screen.dart
- flutter_app/lib/screens/widgets/*
- new files only under flutter_app/lib/screens/ and flutter_app/lib/screens/widgets/

Do not modify:
- services
- models
- theme
- assets
- content files

Requirements:
- Reduce bottom nav to at most 5 destinations
- Remove flashcards and writing from root tabs
- Keep all current flows reachable
- Preserve existing loading and persistence wiring
- Keep screen redesign to a minimum

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
