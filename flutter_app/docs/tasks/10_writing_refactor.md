# Task 10: Writing Refactor

## Purpose
Refactor `WritingScreen` so it becomes the second fully aligned exercise screen in the `Практика` area, built on top of the shared practice foundation while preserving its writing-specific recall flow.

This task should make the writing experience clearer, more structured, and easier to extend without changing the core exercise behavior.

## Why This Task Exists
The current writing screen already has a solid exercise loop, but it still implements its structure locally.

After introducing the shared practice foundation and refactoring flashcards, writing should also align with the common practice system while preserving what makes it distinct:
- prompt-driven recall
- typed answer
- explicit check action
- result feedback
- move-to-next progression

## Scope
In scope:
- refactor `WritingScreen`
- align it with the shared practice foundation from Task 08
- improve the clarity of the writing exercise flow
- preserve current writing mechanics and answer behavior

Out of scope:
- changes to `WritingSession`
- navigation changes
- redesign of flashcards or other screens
- service/model/persistence changes
- content changes

## Allowed Files
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
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/models/*`
- `flutter_app/assets/**`
- `data/**`

Do not modify:
- `WritingSession`
- writing progress persistence wiring

## Requirements

### Exercise Role
`WritingScreen` should feel like a clear practice session focused on recall and typing, not like a generic form placed inside a card.

The user should be able to quickly understand:
- what to write
- when to submit
- what happened after submission
- how the current session is going
- when to continue to the next prompt

### Practice Alignment
The screen should visibly build on the shared practice foundation from Task 08 and align with the overall `Практика` area.

It should use common practice primitives where they fit, especially for:
- screen header/session framing
- result and feedback structure
- stats display
- session summary

### Preserve Writing-Specific Nature
Do not turn writing into a flashcards-like reveal flow.

The refactor should preserve:
- prompt-first structure
- explicit text input
- explicit submit/check action
- post-answer result state
- next-step progression

The user should still feel the cognitive task is “remember and write”, not “recognize and reveal”.

### Session State Clarity
The screen should more clearly separate:
- active prompt state
- empty submission guidance
- answered state
- result feedback
- session summary
- empty state

This should make the screen easier to understand and easier to extend later.

### Result And Next-Step Clarity
After submission, the result state should clearly show:
- whether the answer was correct
- what the correct answer is
- what the user can do next

The transition from answer to next prompt should feel cleaner and more intentional than before.

## Acceptance Criteria
1. `WritingScreen` visibly aligns with the shared practice foundation.
2. The prompt -> input -> submit -> result -> next flow is clearer and more structured than before.
3. Writing-specific recall behavior is preserved.
4. Empty, active, and answered states feel like parts of one coherent practice system.
5. Existing writing mechanics and persistence behavior are preserved.
6. No services, models, or `WritingSession` logic were changed.
7. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- Preserve the writing exercise identity. Consistency should not erase the cognitive difference from flashcards.
- Reuse shared practice primitives where they help.
- If a UX idea requires changing answer rules or session logic, stop and keep the current mechanics.
- This task should complete the first coherent version of the `Практика` area.

## Suggested Prompt For AI
```text
Implement Task 10 from flutter_app/docs/mobile_ux_replatform_plan.md and flutter_app/docs/tasks/10_writing_refactor.md.

Goal:
Refactor WritingScreen so it becomes the second fully aligned Practice exercise screen built on the shared practice foundation, while preserving writing-specific recall behavior.

Allowed files:
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
- flashcards screen
- services
- models
- assets
- content files
- WritingSession

Requirements:
- Keep the current palette and tone
- Align with shared practice primitives
- Improve clarity of prompt, input, submit, result, and next-step flow
- Preserve writing-specific mechanics and persistence wiring
- Do not change WritingSession

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
