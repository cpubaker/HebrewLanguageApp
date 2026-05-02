# Maintainability Refactor Plan

## Goals

- Keep the Flutter client easy to change by people and AI agents.
- Prefer narrow vertical slices over broad rewrites.
- Keep product behavior stable after each refactor batch.
- Make shared behavior testable outside large stateful screens.

## Problems Likely To Grow

- Large stateful screens still combine navigation, async loading, persistence
  rollback, feature gates, and presentation. This makes small product changes
  risky because unrelated concerns are edited in the same file.
- UI colors are still partly screen-local. Night mode can regress when future
  changes bypass shared theme tokens.
- Several practice modules have similar result cards, stat pills, audio hints,
  and progress updates. Divergence will make bug fixes repetitive.
- Content loading tolerates missing optional files, but catalog and metadata
  contracts are implicit. New content tools can break runtime assumptions
  without a clear boundary test.
- The largest screens are still hard to scan quickly, even after extracting the
  first shared contracts.

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
5. Add or run a focused test for every extracted contract before moving the next
   slice.
6. Avoid continuing micro-refactors once a file is no longer the clearest
   bottleneck. Move to the next high-impact area instead of extracting helpers
   for their own sake.

## Completed Slices

- Added `AppDependencies` as the explicit app composition boundary.
- Extracted `AppShellBottomNavigation` from `AppShellScreen`.
- Extracted `LatestRequestTracker` for last-write-wins persistence guards.
- Extracted `LearningWordProgress` for copying word progress between hydrated
  bundle instances.
- Extracted `BottomNavAutoHideBehavior` for scroll-driven bottom navigation
  visibility.
- Extracted `applyLessonStatus` and `restoreLessonStatus` for guide and reading
  lesson status updates.
- Extracted shared lesson status UI into `LessonStatusToggleButton` and
  `lessonStatusVisuals`.
- Extracted `AppShellLearnWorkspace`, `AppShellPracticeWorkspace`, and
  `AppShellMoreWorkspace` so `AppShellScreen` keeps less workspace presentation
  code.
- Extracted `applyWordUpdate` and `restoreWordUpdate` for optimistic word
  progress updates and rollback.
- Collapsed guide and reading lesson status persistence rollback into one
  `AppShellScreen` helper while keeping the existing screen contracts.
- Extracted pure AI learning helpers for feature restore checks, generated
  context merging, AI context scope selection, and AI practice text word scope.
- Extracted guide screen search/filter, list cards, detail header, outline,
  adjacent navigation, and related-topic presentation into focused widgets.
- Extracted guide detail link resolution into `GuideDetailLinkResolver` with
  unit coverage for adjacent titles, related IDs, markdown topic matching,
  dedupe, current/adjacent exclusions, fallback titles, and optional document
  load failures.
- Reused the guide detail current lesson document future for both body rendering
  and related-topic resolution, avoiding a second load of the same current
  asset.

## Next Slices

1. Pause additional `AppShellScreen` micro-refactors unless a new product change
   touches that area. It is still large, but the highest-risk mixed concerns
   have been reduced.
2. Stop pure widget extraction in `guide_screen.dart` unless a feature or bug
   touches the extracted area. The next guide work should simplify behavior,
   not just move lines between files.
3. Move repeated practice result/status widgets from flashcards, writing,
   repetition, and sprint into shared widgets with focused widget tests.
4. Replace hardcoded screen accent colors with named theme tokens for semantic
   states: success, danger, warning, AI, and lesson category accents.
5. Add contract tests for lesson catalog metadata and content asset sync output.
6. Review `MarkdownLessonBody` for separable parsing, layout, and glossary
   behavior while keeping its public API stable.

## Current Large Files

- `lib/screens/guide_screen.dart` is the largest remaining screen and should be
  the next refactor target if the goal is maintainability rather than polishing
  already-improved shell code.
- `lib/screens/words_screen.dart`, `lib/screens/home_screen.dart`,
  `lib/screens/flashcards_screen.dart`, and `lib/screens/writing_screen.dart`
  are still large enough to justify later targeted extraction.
- `lib/screens/app_shell_screen.dart` is still over 1000 lines, but it has
  already had several high-value concerns extracted. Further work there should
  be driven by an actual feature or bug.

## Validation

- After Flutter code changes:
  - `flutter analyze`
  - focused tests for the touched flow
  - `flutter test`
- After content source changes:
  - `powershell -ExecutionPolicy Bypass -File .\tool\sync_learning_assets.ps1`
