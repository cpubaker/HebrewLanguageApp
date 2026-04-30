# Maintainability Refactor Plan

## Problems Likely To Grow

- Large stateful screens combine navigation, async loading, persistence rollback,
  feature gates, and presentation. This makes small product changes risky because
  unrelated concerns are edited in the same file.
- App startup wiring was spread through `HebrewFlutterApp`, so adding one service
  required changing the widget constructor, default creation, tests, and shell
  parameters at the same time.
- UI colors are still partly screen-local. Night mode can regress when future
  changes bypass shared theme tokens.
- Several practice modules have similar result cards, stat pills, audio hints,
  and progress updates. Divergence will make bug fixes repetitive.
- Content loading tolerates missing optional files, but catalog and metadata
  contracts are implicit. New content tools can break runtime assumptions without
  a clear boundary test.

## Refactoring Strategy

1. Keep changes as narrow vertical slices. Avoid broad rewrites of a full screen
   unless tests already cover the user flow being moved.
2. Keep `lib/services/` as the home for parsing, persistence, AI transport,
   audio, and progress state. Screens should receive ready-to-use contracts.
3. Extract shared UI only after at least two live call sites need the same
   behavior. Prefer widgets under `lib/screens/widgets/` over new framework
   layers.
4. Extend `lib/theme/app_theme.dart` before adding screen-local light or dark
   colors.
5. Add a focused test for every extracted contract before moving the next slice.

## Completed First Slice

- Added `AppDependencies` as the explicit app composition boundary.
- Kept legacy `HebrewFlutterApp` constructor parameters as compatibility
  overrides for existing tests and narrow widget setup.
- Resolved default app services once in `HebrewFlutterAppState`, then passed
  stable instances into `AppShellScreen`.

## Next Slices

1. Split `AppShellScreen` into navigation shell, progress mutation handlers, and
   workspace shortcut builders.
2. Move repeated practice result/status widgets from flashcards, writing,
   repetition, and sprint into shared widgets with golden or widget tests.
3. Replace hardcoded screen accent colors with named theme tokens for semantic
   states: success, danger, warning, AI, and lesson category accents.
4. Add contract tests for lesson catalog metadata and content asset sync output.
5. Review the largest screens one by one and extract only stable subtrees that
   already have test coverage.
