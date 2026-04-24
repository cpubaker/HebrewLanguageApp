# Task 17: Entitlements Foundation

## Purpose
Introduce a clean entitlement layer for future Pro features without locking current features behind ad hoc UI checks.

## Why This Task Exists
The codebase does not yet have a formal place for premium feature decisions.

Without a dedicated entitlement layer, future Pro work tends to become:
- scattered `if premium` checks in screens
- fragile testing
- weak assumptions about client-side security
- harder future integration with purchases or account-based access

## Scope
In scope:
- add an entitlement service boundary
- define feature identifiers or capability flags in one place
- make the app capable of asking "is this feature available?" through one interface
- keep the default implementation effectively free/unlocked unless a requirement explicitly says otherwise

Out of scope:
- real purchases and billing integration
- server-side entitlement validation
- moving assets behind secure delivery
- actually paywalling dark theme

## Allowed Files
- `flutter_app/lib/app.dart`
- `flutter_app/lib/services/*`
- `flutter_app/lib/screens/app_shell_screen.dart`
- `flutter_app/lib/screens/more_screen.dart`
- `flutter_app/lib/screens/home_screen.dart`
- `flutter_app/test/*`

You may create new files only inside:
- `flutter_app/lib/services/`
- `flutter_app/test/`

## Forbidden Files
- `flutter_app/lib/screens/words_screen.dart`
- `flutter_app/lib/screens/guide_screen.dart`
- `flutter_app/lib/screens/reading_screen.dart`
- `flutter_app/lib/screens/flashcards_screen.dart`
- `flutter_app/lib/screens/writing_screen.dart`
- `flutter_app/lib/theme/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Central Gate
- premium capability checks should go through one service or interface
- UI should not invent its own premium logic
- feature identifiers should be centralized and explicit

### Safe Product Semantics
- do not imply that packaged client assets are secure premium delivery
- do not use dark theme as the first premium gate in this task
- the default implementation should support the current app behavior

### Future Readiness
- the entitlement layer should be easy to replace later with purchase-backed or server-backed logic
- tests should be able to inject fake entitlements easily

## Acceptance Criteria
1. A single entitlement boundary exists.
2. Feature availability checks can be expressed without screen-local premium logic.
3. Current app behavior remains unchanged by default.
4. Tests cover the new entitlement layer or its primary integration points.
5. The app builds and tests pass.

## Validation
Run:

```powershell
cd flutter_app
flutter analyze
flutter test
```

## Notes For The Implementer
- This is a foundation task, not a monetization launch.
- Favor clear naming like capability/entitlement/feature access over vague flag bags.
- If you expose a sample gated UI hook, keep it non-disruptive and default-open.

## Suggested Prompt For AI
```text
Implement Task 17 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/17_entitlements_foundation.md.

Goal:
Add a clean entitlement layer so future Pro features can be gated through one service boundary without changing current behavior.

Allowed files:
- flutter_app/lib/app.dart
- flutter_app/lib/services/*
- flutter_app/lib/screens/app_shell_screen.dart
- flutter_app/lib/screens/more_screen.dart
- flutter_app/lib/screens/home_screen.dart
- flutter_app/test/*

Do not modify:
- feature exercise/content screens
- theme
- assets
- content files

Requirements:
- one entitlement boundary
- centralized feature identifiers
- default-open behavior
- do not actually paywall dark theme

Validation:
- cd flutter_app
- flutter analyze
- flutter test
```
