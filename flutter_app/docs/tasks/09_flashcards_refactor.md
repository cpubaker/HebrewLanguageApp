# Task 09: Flashcards Refactor

## Purpose
Refactor `FlashcardsScreen` so it becomes the first fully aligned exercise screen in the `Практика` area, built on top of the shared practice foundation.

This task should improve the clarity of the flashcards flow while preserving the current exercise rules and deck behavior.

## Why This Task Exists
The current flashcards screen is already feature-rich, but it still carries local structural decisions that should now be aligned with the shared practice pattern.

As one of the core practice modes, flashcards should become the reference implementation for:
- exercise header
- active task state
- answer/reveal flow
- session details
- completion state

## Scope
In scope:
- refactor `FlashcardsScreen`
- align it with the shared practice foundation from Task 08
- improve session-state clarity
- improve the presentation of deck mode, answer flow, and completion flow
- preserve existing flashcard mechanics

Out of scope:
- changes to flashcard scoring rules
- changes to `FlashcardSession`
- navigation changes
- redesign of writing or other screens
- service/model/persistence changes

## Allowed Files
- `flutter_app/lib/screens/flashcards_screen.dart`
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
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

Do not modify:
- `FlashcardSession`
- flashcard progress persistence wiring

## Requirements

### Exercise Role
`FlashcardsScreen` should feel like a clear, scalable practice flow rather than a set of ad hoc panels inside one screen.

The user should be able to quickly understand:
- which deck they are in
- what action to take
- what happened after the answer
- where they are in the session
- what to do when the deck is complete

### Practice Alignment
The screen should visibly build on the shared practice foundation from Task 08.

It should use common practice primitives where they fit, especially for:
- header/session framing
- progress and session summary
- stats display
- result/reveal structure

### Preserve Flashcard Mechanics
Do not change the core behavior of the exercise:
- swipe/tap answer flow
- known vs repeat semantics
- deck modes
- reveal behavior
- restart/completion logic

This task is about UX clarity and structural cleanup, not rule changes.

### Deck Mode Clarity
The current deck modes are important and must remain understandable:
- all words
- with contexts
- needs review

The screen should make it easier to understand:
- which deck is active
- what the deck means
- how to switch or toggle when relevant

### Session State Clarity
The screen should more clearly separate:
- active card state
- answered/revealed state
- session details
- empty state
- completed state

The result should be easier to scan and easier to extend later.

### Completion State
The completed-deck screen should feel like part of the same practice system, not a separate one-off layout.

It should clearly communicate:
- what was completed
- how the user performed
- what the next useful action is

## Acceptance Criteria
1. `FlashcardsScreen` visibly aligns with the shared practice foundation.
2. The active card flow is clearer and more structured than before.
3. Deck mode and session progress are easier to understand.
4. Empty and completed states feel like part of the same system.
5. Existing flashcard mechanics and persistence behavior are preserved.
6. No services, models, or `FlashcardSession` logic were changed.
7. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Preserve behavior first, improve structure second, polish third.
- If a UX improvement requires changing exercise rules, stop and keep the current rule set.
- Reuse the practice foundation aggressively, but do not force unlike sections into one widget if that reduces clarity.
- This task should make the next writing-screen refactor easier by proving the shared practice pattern.

## Suggested Prompt For AI
```text
Implement Task 09 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/09_flashcards_refactor.md.

Goal:
Refactor FlashcardsScreen so it becomes the first fully aligned Practice exercise screen built on the shared practice foundation, while preserving existing flashcard behavior.

Allowed files:
- flutter_app/lib/screens/flashcards_screen.dart
- flutter_app/lib/screens/widgets/*
- flutter_app/lib/theme/app_theme.dart

Do not modify:
- app shell/navigation
- home screen
- words screen
- verbs screen
- guide screen
- reading screen
- writing screen
- services
- models
- assets
- content files
- FlashcardSession

Requirements:
- Keep the current palette and tone
- Align with shared practice primitives
- Improve clarity of deck mode, answer flow, session state, and completion state
- Preserve swipe/tap behavior and deck semantics
- Do not change persistence wiring

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
