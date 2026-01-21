# Implementation Plan: Course Enrollment (Orders) with Payment Proof Upload

**Branch**: `001-course-enrollment-payment` | **Date**: 2026-01-20 | **Spec**: ./spec.md
**Input**: Feature specification from `/specs/001-course-enrollment-payment/spec.md`

## Summary

Add a paid-course enrollment flow that places an **order** via `POST /api/orders/place` (multipart upload of `transaction_screenshot`) and a “My Learnings” view backed by `GET /api/my-learnings`. The UI validates image type/size, prevents duplicate paid orders, and shows order status (pending/approved/unknown) in both course detail and My Learnings. To handle uncertain backend behavior around pending visibility, persist a lightweight local “pending submission cache” after a successful order placement.

## Technical Context

**Language/Version**: Dart `^3.7.2` (Flutter project)  
**Primary Dependencies**: `flutter_riverpod`, `http`, `flutter_secure_storage`, `url_launcher` (+ add `image_picker` for this feature)  
**Storage**: `flutter_secure_storage` (auth token + local pending-submission metadata)  
**Testing**: `flutter_test` (unit/widget). For repository tests, inject an `http.Client`/`http.BaseClient` and capture `send()` to assert multipart fields/headers deterministically (no real network).  
**Target Platform**: Android/iOS primary (Flutter multi-platform repo, but UX is mobile-first)  
**Project Type**: Flutter mobile app  
**Performance Goals**: Maintain 60fps; avoid UI jank during image pick/preview/upload  
**Constraints**: Multipart upload max 5MB image; request timeouts (~15s); no new backend endpoints assumed  
**Scale/Scope**: Single feature touching course detail, More/My Learnings navigation, and data layer

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

- [ ] Code quality gate: `flutter analyze` is clean; no new lints ignored.
- [ ] Testing gate: new/changed behavior has appropriate unit/widget/integration tests.
- [ ] UX gate: UI uses design tokens/components; includes loading/empty/error states.
- [ ] Performance gate: no avoidable rebuilds/jank; profile-mode validation if relevant.
- [ ] Reliability gate: errors handled explicitly; no silent failures.

Gate evaluation (plan stage): no constitution violations required/expected.

## Project Structure

### Documentation (this feature)

```text
specs/001-course-enrollment-payment/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── core/
├── data/
└── presentation/

test/
├── unit/
├── widget/
└── golden/ (optional)

integration_test/ (optional but recommended for critical journeys)

android/
ios/
```

**Structure Decision**: Use the existing Flutter structure.

- Data layer additions in `lib/data/` (repository + models + providers)
- UI additions/changes in `lib/presentation/screens/` and small reusable widgets in `lib/presentation/widgets/`
- Tests under `test/unit/` and `test/widget/`

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed    | Simpler Alternative Rejected Because |
| --------- | ------------- | ------------------------------------ |
| N/A       | No violations | N/A                                  |

## Phase 0: Research (complete)

Output: `research.md`

- Resolved free-course behavior and pending visibility uncertainty.
- Chosen technical approach for image picking, validation, multipart upload, and local pending cache.

## Phase 1: Design & Contracts (complete)

Outputs:

- `data-model.md`
- `contracts/openapi.yaml`
- `quickstart.md`

### UX / Screen Flow

- **Course detail** (`CourseDetailScreen`)
  - If not signed in: Enroll routes to Auth + shows a user-friendly message.
  - If signed in and paid course:
    - If existing order found (server or local pending cache): disable Enroll and show status + “View in My Learnings”.
    - Else: show “Enroll” → bottom sheet/dialog to pick image, preview, validate, submit.
  - If free course (`price == 0`): show “Start Learning” and allow access without order placement.

- **My Learnings** (new screen)
  - Fetch from `GET /api/my-learnings` and render course cards with status.
  - Optionally show locally-cached pending submissions if server does not include them.
  - Entry point: add an item under the **More** tab.

### Status Handling

- Support `pending` and `approved` explicitly.
- Unknown status values must be displayed safely (raw value + generic guidance).

Post-design Constitution Check: still no violations expected.

## Phase 2: Implementation Plan (next)

1. Dependencies
   - Add `image_picker` to `pubspec.yaml`.

- Ensure required platform permissions are set (iOS `NSPhotoLibraryUsageDescription`; Android media permissions only if needed by the chosen picker flow).

2. Data layer
   - Add an `OrderRepository` with:
     - `placeOrder({required int courseId, required File screenshot})`
     - `fetchMyLearnings()`
   - Implement a local pending cache (secure storage) keyed by `courseId`.

3. Models
   - Add models for:
     - `Order` (from place response)
     - `Learning` (from my-learnings response)
     - `OrderStatus` helpers (parse + display)

4. Providers (Riverpod)
   - Provider for `OrderRepository`.
   - Async providers for:
     - My Learnings list
     - Place-order mutation state
     - Per-course computed enrollment status (server + local cache)

5. UI
   - Update `CourseDetailScreen` to use real enrollment logic and show status.
   - Add an enrollment submission UI (bottom sheet/dialog) with:
     - image pick
     - preview
     - validation messaging
     - loading/progress state
     - retry support without losing the selected screenshot/state (state stored in provider/controller, not only widget-local)
   - Add `MyLearningsScreen` and link it from `MoreScreen`.

6. Testing
   - Unit tests:
     - model parsing for `Order`/`Learning`
     - repository request construction (multipart + headers) by injecting an `http.BaseClient` and capturing `send()`
     - pending cache behavior
   - Widget tests:
     - course detail status rendering + disabled enroll
     - my learnings list states (loading/error/empty/success)

7. Quality gates
   - Run `flutter analyze` and `flutter test` and ensure UX states conform to `AppColors`/theme.
