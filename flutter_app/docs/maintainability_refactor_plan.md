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
- Added shared `PracticeFeedbackCard` for practice answer feedback and wired it
  into writing and sprint flows with focused widget coverage.
- Added shared `PracticeStatsRow` for repeated equal-width practice stat pill
  rows and wired it into writing and sprint active states.
- Added shared `PracticeCompletionCard` for repeated practice completion states
  and wired it into flashcards, repetition, and sprint with focused widget
  coverage.
- Replaced repeated practice success, danger, warning, info, and AI accent
  literals with shared `AppThemeTokens` semantic colors, with contract coverage
  for light and night mode token values.
- Routed shared lesson status visuals through semantic `AppThemeTokens` colors
  so guide and reading status UI no longer owns hardcoded unread, studying, and
  read accents.
- Added catalog and asset sync contract coverage for normalized lesson catalog
  output plus guide metadata filename, section, lesson ID, order, alias, and
  related-ID integrity.
- Added reading level directory contract coverage so source and synced runtime
  assets stay aligned with the UI grouping and pubspec packaging contract.
- Extracted words search/filter indexing into pure `word_list_filter` helpers
  with unit coverage, keeping `WordsScreen` focused on state and presentation.
- Extracted `MarkdownLessonBody` markdown block parsing and inline glossary
  matching into pure services with focused unit coverage, preserving the public
  widget API for guide, reading, and verbs screens.
- Extracted remaining `MarkdownLessonBody` text direction, script detection,
  and bidirectional isolate preparation into a pure service with focused unit
  coverage.

## Next Slices

1. Pause additional `AppShellScreen` micro-refactors unless a new product change
   touches that area. It is still large, but the highest-risk mixed concerns
   have been reduced.
2. Stop pure widget extraction in `guide_screen.dart` unless a feature or bug
   touches the extracted area. The next guide work should simplify behavior,
   not just move lines between files.
3. Continue practice surface unification only where repeated contracts remain;
   result/status widgets now need a fresh audit before another extraction.
4. Continue replacing remaining hardcoded screen accent colors with named theme
   tokens, focusing next on category accents for guide search/detail, reading,
   verbs, and word-status surfaces.
5. Add more content contract tests only where a concrete content workflow needs
   a stronger guardrail.
6. Leave `MarkdownLessonBody` alone unless a concrete lesson rendering feature
   or bug touches its remaining widget layout.

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
