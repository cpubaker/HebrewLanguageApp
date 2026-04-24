# Technical Refactor Plan

## Purpose
This document defines the technical refactor roadmap for the Flutter client so future AI agents can work through the main scale and maintainability risks in a controlled order.

This roadmap is separate from the mobile UX replatform work. It focuses on architecture, persistence, content identity, performance headroom, monetization readiness, and iOS readiness.

## Why This Plan Exists
The current Flutter app is working, but several implementation choices will become fragile as the product grows:
- lesson progress is still keyed by asset paths in part of the app
- word progress is stored as one large `shared_preferences` JSON payload
- startup work is centralized near the root app shell
- large screens and shell logic are concentrated in a few very large files
- feature gating for future Pro work does not yet exist
- the repository is Flutter-based, but the app is not yet prepared as an iPhone-ready product surface

The goal is not to rewrite everything. The goal is to create clean seams so future work becomes safer.

## Primary Risks This Plan Targets

### 1. Content Identity Fragility
Guide and reading progress currently depend on asset paths. That makes lesson renames and content reorganizations expensive and error-prone.

Target state:
- lesson progress uses stable IDs
- path-based compatibility is migrated once, not maintained forever

### 2. Persistence Scalability
Word progress is currently persisted as one large JSON blob in `shared_preferences`.

Target state:
- persistence is behind an app-level repository boundary
- structured local storage is used for word progress
- migrations are explicit and tested

### 3. Root Composition Complexity
`AppShellScreen` currently mixes loading, hydration, persistence, retry behavior, navigation, and shell UX state.

Target state:
- root composition is split into smaller collaborators
- feature screens receive cleaner data contracts
- persistence details stop leaking into screen code

### 4. Startup And Loading Headroom
The app currently loads a large bundle up front and still does some discovery work centrally.

Target state:
- explicit loading responsibilities
- less startup-wide discovery work
- clearer path to lazy and incremental loading

### 5. Pro Feature Readiness
The codebase does not yet have a proper entitlement layer.

Target state:
- UI does not hardcode premium checks
- future Pro features can be gated through one service
- monetization does not rely on pretending packaged assets are secure

### 6. iPhone Readiness
Flutter gives a cross-platform codebase, but this repo is not yet an iOS-ready product baseline.

Target state:
- iOS platform setup exists
- package choices and app services are reviewed with iOS constraints in mind
- future iPhone work does not begin from zero

## Refactor Principles
- Prefer narrow vertical tasks over broad rewrites.
- Keep runtime behavior stable unless a task explicitly changes it.
- Introduce boundaries before introducing storage or platform migrations.
- Preserve user progress through tested migrations.
- Avoid new state-management packages unless a task explicitly justifies one.
- Treat dark and light mode as product features, not throwaway experiments.
- Do not use dark theme as the first premium gate. Accessibility and product trust matter more than a weak paywall.

## Non-Goals
- full redesign of existing screens
- replacing Flutter with another stack
- introducing a backend immediately
- shipping account sync in the same wave
- moving all content out of assets right now

## Workstreams

### Wave 1: Identity And Persistence Foundations
1. Stable lesson identity
2. Progress repository boundary
3. Word progress store migration

Why first:
- these changes protect user progress
- they reduce the cost of future content growth
- they create cleaner seams for later refactors

### Wave 2: Loading And Root Architecture
4. Learning bundle loading split
5. App shell composition refactor

Why second:
- loading and composition become easier after persistence seams exist
- this wave reduces startup coupling without changing product structure

### Wave 3: Product Readiness
6. Entitlements foundation
7. iOS readiness baseline

Why third:
- monetization and iPhone work should build on a cleaner core
- these are important, but they should not destabilize the app before the foundations are in place

## Success Criteria
This roadmap is successful when:
- lesson progress survives content renames without a giant manual path map
- word progress no longer rewrites one large preferences blob for every answer
- the app shell is composition-oriented instead of persistence-oriented
- startup loading responsibilities are explicit and testable
- future premium gates can be added without scattering checks through screens
- iOS work has a prepared baseline instead of a cold start

## How AI Agents Should Use This Plan
- Execute one task at a time.
- Read `flutter_app/docs/technical_refactor_execution_order.md` first.
- Then read the matching task spec under `flutter_app/docs/tasks/`.
- Do not combine tasks unless a human explicitly asks for a bundled pass.
- If a task reveals a hidden migration or cross-cutting issue, stop and split it into a new task instead of expanding scope silently.
