<!--
Sync Impact Report

- Version change: N/A (template) -> 1.0.0
- Modified principles: Template placeholders -> 5 Flutter-specific principles added
- Added sections: Quality Gates; Workflow & Review
- Removed sections: None
- Templates requiring updates:

  - ✅ updated: .specify/templates/plan-template.md
  - ✅ updated: .specify/templates/spec-template.md
  - ✅ updated: .specify/templates/tasks-template.md
  - ✅ updated: .specify/templates/checklist-template.md
  - ✅ no change needed: .specify/templates/agent-file-template.md
- Follow-up TODOs: None
-->

# RiseTechpreneur Mobile App Constitution

## Core Principles

### 1) Code Quality & Maintainability (NON-NEGOTIABLE)

All changes MUST keep the codebase readable, refactor-friendly, and idiomatic Dart/Flutter.

- Prefer small, focused widgets and functions; avoid large build methods.
- Use null-safety correctly (no unsafe casts without justification).
- Avoid duplication: extract shared UI into `lib/presentation/widgets/` and shared logic into
  `lib/core/` / `lib/data/`.
- Follow the existing architecture: UI in `presentation/`, state/data in `data/`, shared styling
  and constants in `core/`.
- No new lints ignored. `flutter analyze` MUST be clean for mainline work.

Rationale: Maintainability is a product feature; it prevents regressions and speeds delivery.

### 2) Testing Discipline (NON-NEGOTIABLE)

Every behavior change MUST be verified by automated tests at the right level.

- Business logic (providers, repositories, parsing, validation) MUST have unit tests.
- UI behavior MUST have widget tests for critical states (loading, empty, error, success).
- End-to-end critical journeys MUST have integration tests when they cross multiple screens or
  involve deep links/authentication.
- Bug fixes MUST include a regression test that fails before the fix and passes after.
- Tests MUST be deterministic: no real network calls; mock or fake dependencies.

Rationale: In a multi-screen Flutter app with async IO, tests are the cheapest safety net.

### 3) UX Consistency via Design System

The app MUST feel consistent across screens and states.

- Use `AppTheme`/`AppColors` (and other design tokens) for typography, colors, and key styles.
- Avoid hard-coded colors, font sizes, and arbitrary padding/margins unless adding a new token.
- Prefer reusable components over one-off UI; keep shared widgets in `presentation/widgets/`.
- All states MUST be designed: loading, empty, error, and success.
- Accessibility is part of UX: interactive controls MUST have semantics/labels where applicable,
  and layouts MUST handle text scaling without breaking.

Rationale: Consistency reduces cognitive load and improves trust.

### 4) Performance & Responsiveness

The app MUST stay responsive and avoid avoidable jank.

- UI MUST not do heavy synchronous work on the main isolate.
- Avoid unnecessary rebuilds: use `const` widgets where possible and keep provider scopes tight.
- Use lazy lists/grids (`ListView.builder`, `GridView.builder`) for large collections.
- Network calls MUST have timeouts and user-visible loading states.
- Image usage MUST be efficient (proper sizing, caching where appropriate).

Rationale: Learning apps live or die by perceived speed; performance is UX.

### 5) Reliability, Errors, and Safe Defaults

Failures MUST be handled explicitly and communicated clearly.

- All API calls MUST handle success/error paths and surface actionable messages to users.
- Never fail silently (no swallowed exceptions without user-facing behavior + dev visibility).
- Auth/session state MUST be consistent and secure (tokens stored only via secure storage).
- Deep links MUST be validated (required params present; invalid links show safe error UI).
- Prefer safe fallbacks over crashes; crashes are treated as P0 defects.

Rationale: Reliability builds trust and reduces support burden.

## Quality Gates

The following are mandatory gates for merging and for feature delivery:

- `flutter analyze` passes with no new warnings/errors.
- `flutter test` passes for the affected modules/features.
- New/changed behavior is covered by appropriate tests (unit/widget/integration).
- UI changes preserve design system consistency (tokens/components) and include empty/loading/
  error states.
- Performance-sensitive changes are validated in profile mode when relevant.

## Workflow & Review

- Prefer small PRs. If a PR is large, it MUST include a clear breakdown and review guidance.
- PRs MUST link to a spec/plan (or describe the user-visible change and acceptance scenarios).
- Reviewers MUST verify the Quality Gates and principles above.
- Refactors MUST be behavior-preserving or include explicit behavior changes + tests.

## Governance

<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

- This constitution is the highest-level engineering policy for the repository.
- Amendments MUST be made via a PR that:
  - updates this file,
  - updates the Sync Impact Report,
  - bumps the version using semantic versioning (MAJOR/MINOR/PATCH), and
  - updates dependent `.specify/templates/*` documents if impacted.
- Compliance is reviewed on every feature plan (Constitution Check) and every PR.

**Version**: 1.0.0 | **Ratified**: 2026-01-19 | **Last Amended**: 2026-01-19
