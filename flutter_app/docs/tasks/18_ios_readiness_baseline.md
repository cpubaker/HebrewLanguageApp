# Task 18: iOS Readiness Baseline

## Purpose
Prepare the Flutter app repository so iPhone work starts from an iOS-ready baseline instead of a cold start.

## Why This Task Exists
The app is written in Flutter, but the repository is not yet operating as an iOS-ready product baseline.

That means future iPhone work risks discovering platform issues too late:
- project setup gaps
- plugin compatibility issues
- platform-specific audio behavior
- missing platform validation notes

## Scope
In scope:
- add or validate iOS platform project scaffolding
- review Flutter dependencies for iOS readiness
- document any platform-specific follow-up items
- keep current Flutter app behavior unchanged

Out of scope:
- shipping App Store purchases
- full iOS UX redesign
- adding Apple-specific monetization flows
- backend sync

## Allowed Files
- `flutter_app/pubspec.yaml`
- `flutter_app/ios/**`
- `flutter_app/lib/services/*`
- `flutter_app/README.md`
- `flutter_app/docs/*`

You may create new files only inside:
- `flutter_app/ios/`
- `flutter_app/docs/`

## Forbidden Files
- `flutter_app/lib/screens/*`
- `flutter_app/lib/theme/*`
- `flutter_app/assets/**`
- `data/**`

## Requirements

### Platform Baseline
- the repo should contain a valid iOS platform baseline or a documented platform-generation step
- package choices should be reviewed for iOS compatibility
- obvious platform service concerns, especially audio/session behavior, should be noted

### Validation Reality
- if the task runs on macOS, validate the iOS project and simulator build
- if the task runs on Windows, do not fake iOS validation; document the exact macOS follow-up instead

### Keep Scope Tight
- this task is about readiness, not feature redesign
- do not spread platform conditionals through screens unless clearly required

## Acceptance Criteria
1. The repo has an iOS readiness baseline or an explicit generated platform baseline.
2. Known iOS-specific follow-ups are documented.
3. Flutter dependency and service assumptions are reviewed for iOS constraints.
4. Current app behavior remains unchanged.
5. Validation is honest about platform limitations.

## Validation
Run what is available in the current environment:

```powershell
cd flutter_app
flutter analyze
flutter test
```

If on macOS, also validate the iOS project and simulator build.

## Notes For The Implementer
- Do not pretend Windows can fully validate iOS readiness.
- Keep the result useful for the next engineer on macOS.
- If generating iOS scaffolding requires a platform-specific environment, document the exact follow-up command.

## Suggested Prompt For AI
```text
Implement Task 18 from flutter_app/docs/technical_refactor_plan.md and flutter_app/docs/tasks/18_ios_readiness_baseline.md.

Goal:
Prepare the Flutter repo for future iPhone work by creating or validating an iOS-ready baseline and documenting platform-specific follow-up items honestly.

Allowed files:
- flutter_app/pubspec.yaml
- flutter_app/ios/**
- flutter_app/lib/services/*
- flutter_app/README.md
- flutter_app/docs/*

Do not modify:
- screens
- theme
- assets
- content files

Requirements:
- establish an iOS readiness baseline
- review dependency and service assumptions for iOS
- document platform-specific follow-ups honestly

Validation:
- cd flutter_app
- flutter analyze
- flutter test
- if on macOS, validate iOS project generation/build
```
