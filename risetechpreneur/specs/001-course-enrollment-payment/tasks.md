# Tasks: Course Enrollment (Orders) with Payment Proof Upload

**Input**: Design documents from `/specs/001-course-enrollment-payment/`

- plan.md
- spec.md
- research.md
- data-model.md
- contracts/openapi.yaml
- quickstart.md

**Tests**: Tests are REQUIRED by the project constitution and by NFR-002 in the spec.

---

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Update dependencies in pubspec.yaml to add `image_picker` and run `flutter pub get`
- [x] T002 Add iOS permission strings required by image picking (`NSPhotoLibraryUsageDescription`; add `NSCameraUsageDescription` only if camera capture is enabled) in ios/Runner/Info.plist
- [x] T003 Confirm Android picker flow uses the system picker (no manifest permissions required); only add SDK <= 32 `READ_EXTERNAL_STORAGE` / SDK 33+ `READ_MEDIA_IMAGES` if the chosen implementation requires direct media access in android/app/src/main/AndroidManifest.xml
- [x] T004 [P] Create feature module file stubs in lib/data/order_models.dart, lib/data/order_repository.dart, lib/data/order_providers.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Checkpoint goal**: The data layer can (a) place an order, (b) fetch my-learnings, and (c) compute per-course enrollment status (server + local pending cache), with unit tests.

- [x] T005 Implement `OrderStatus` parsing + display helpers in lib/data/order_models.dart
- [x] T006 Implement `Order` and `Learning` models (JSON parsing) in lib/data/order_models.dart
- [x] T007 [P] Implement secure pending-submission store (save/read/remove by `courseId`) in lib/data/pending_submission_store.dart
- [x] T008 [P] Add unit tests for model parsing in test/unit/order_models_test.dart
- [x] T009 [P] Add unit tests for pending store read/write behavior in test/unit/pending_submission_store_test.dart
- [x] T010 Implement `OrderRepository.placeOrder()` (multipart upload `course_id`, `transaction_screenshot`) in lib/data/order_repository.dart
- [x] T011 Implement `OrderRepository.fetchMyLearnings()` (Bearer token) in lib/data/order_repository.dart
- [x] T012 Refactor `OrderRepository` to accept an injected `http.Client`/`http.BaseClient` so tests can intercept `send()` deterministically in lib/data/order_repository.dart
- [x] T013 [P] Add unit tests for `OrderRepository` multipart request construction by injecting a custom `http.BaseClient` (override `send()` to capture the request) and asserting `Authorization` header, `course_id` field, and file part name `transaction_screenshot` in test/unit/order_repository_test.dart
- [x] T014 Wire repository + state into Riverpod providers (repository provider + my-learnings provider + place-order controller) in lib/data/order_providers.dart
- [x] T015 Implement computed provider for per-course enrollment status (merge server learnings + local pending cache) in lib/data/order_providers.dart

---

## Phase 3: User Story 1 — Submit Enrollment + Payment Proof (Priority: P1) 🎯 MVP

**Goal**: A signed-in learner can submit a paid enrollment request by uploading a screenshot proof image, and the course detail immediately reflects `pending` status while preventing duplicate submissions.

**Independent Test**: On a paid course, select an image (PNG/JPG/JPEG <= 5MB), submit, see success feedback and `Pending` status; repeat attempt shows Enroll disabled.

### Tests (REQUIRED)

- [x] T016 [P] [US1] Unit test image validation rules (type + size) in test/unit/enrollment_validation_test.dart
- [x] T017 [P] [US1] Widget test: course detail shows Enroll disabled when status exists (pending/approved/unknown) in test/widget/course_detail_enrollment_status_test.dart
- [x] T018 [P] [US1] Widget test: unauthenticated enroll routes to auth and shows message in test/widget/course_detail_enrollment_auth_test.dart

### Implementation

- [x] T019 [P] [US1] Add reusable status badge widget for `pending/approved/unknown` in lib/presentation/widgets/enrollment_status_badge.dart
- [x] T020 [P] [US1] Add payment proof picker + preview bottom sheet/dialog widget in lib/presentation/widgets/payment_proof_sheet.dart
- [x] T021 [US1] Integrate paid enrollment flow into course detail screen (use providers, show status, submit order, write pending cache) in lib/presentation/screens/course_detail_screen.dart
- [x] T022 [US1] Implement client-side validation (required image, type, size <= 5MB) and user-friendly messages in lib/presentation/widgets/payment_proof_sheet.dart
- [x] T023 [US1] Ensure retry preserves the selected screenshot and user input state across failures (provider/controller state, not widget-local only) in lib/presentation/widgets/payment_proof_sheet.dart and lib/presentation/screens/course_detail_screen.dart
- [x] T024 [US1] Implement duplicate prevention UI (disable enroll + show “View in My Learnings”) in lib/presentation/screens/course_detail_screen.dart
- [x] T025 [US1] Implement free-course behavior (`price == 0` → immediate access) in lib/presentation/screens/course_detail_screen.dart

---

## Phase 4: User Story 2 — Track Enrollment Status (Priority: P2)

**Goal**: A signed-in learner can view “My Learnings” to see ordered courses and their statuses, and course detail shows status without needing extra navigation.

**Independent Test**: Open My Learnings and see a list of returned courses with status; course detail for a listed course shows matching status.

### Tests (REQUIRED)

- [x] T026 [P] [US2] Widget test: My Learnings loading/error/empty/success states in test/widget/my_learnings_screen_test.dart
- [x] T027 [P] [US2] Unit test: merging server learnings with local pending cache (dedupe by `courseId`) in test/unit/my_learnings_merge_test.dart

### Implementation

- [x] T028 [P] [US2] Create My Learnings screen (list + pull-to-refresh + status chips) in lib/presentation/screens/my_learnings_screen.dart
- [x] T029 [US2] Add navigation entry to My Learnings from More tab in lib/presentation/screens/more_screen.dart
- [x] T030 [US2] Render “Pending submissions” section sourced from local pending cache (only if not present in server list) in lib/presentation/screens/my_learnings_screen.dart
- [x] T031 [US2] Ensure consistent error handling (401 → prompt sign-in; network → retry) in lib/presentation/screens/my_learnings_screen.dart

---

## Phase 5: User Story 3 — Approve/Reject Enrollment Requests (Priority: P3)

**Goal**: The mobile app reflects backend approval updates reliably (even though approval itself is performed outside the app).

**Independent Test**: If backend/admin updates an order from `pending` to `approved`, the app shows the new status after refresh and removes any local pending cache entry.

### Tests (REQUIRED)

- [x] T032 [P] [US3] Unit test: when server returns approved for a course, local pending cache entry is cleared in test/unit/pending_cache_reconciliation_test.dart

### Implementation

- [x] T033 [US3] Reconcile local pending cache against server results (clear on match/approved) in lib/data/order_providers.dart
- [x] T034 [US3] Add a clear “Approved” next-step UX in course detail + my learnings (e.g., “You’re enrolled” messaging) in lib/presentation/screens/course_detail_screen.dart

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T035 [P] Add documentation note about required permissions and supported image formats in README.md
- [x] T036 Ensure all new UI states follow design tokens (`AppColors`, typography) in lib/presentation/screens/course_detail_screen.dart
- [x] T037 Run `flutter analyze` and fix any new issues (touching relevant files: lib/data/order_models.dart, lib/data/order_repository.dart, lib/presentation/screens/my_learnings_screen.dart)
- [x] T038 Run `flutter test` and ensure all added tests pass (touching relevant files in test/unit/ and test/widget/)
- [x] T039 [P] Validate quickstart steps end-to-end and update any mismatches in specs/001-course-enrollment-payment/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 (Setup) blocks Phase 2+
- Phase 2 (Foundational) blocks Phase 3+
- Phase 3 (US1) can ship as MVP once complete
- Phase 4 (US2) builds on the same foundation and should follow MVP or be built in parallel after Phase 2
- Phase 5 (US3) is app-side reconciliation only; depends on Phase 2 providers and Phase 4 screen refresh patterns

### User Story Dependency Graph

- US1 → US2 → US3
  - US1 delivers order placement and immediate status feedback
  - US2 delivers persistent status visibility (My Learnings)
  - US3 delivers robust reconciliation when backend approval changes

---

## Parallel Execution Examples

### US1 parallel candidates

- (T019) lib/presentation/widgets/enrollment_status_badge.dart
- (T020) lib/presentation/widgets/payment_proof_sheet.dart
- (T016–T018) test/unit/ + test/widget/

### US2 parallel candidates

- (T028) lib/presentation/screens/my_learnings_screen.dart
- (T026) test/widget/my_learnings_screen_test.dart
- (T027) test/unit/my_learnings_merge_test.dart

### Foundational parallel candidates

- (T007) lib/data/pending_submission_store.dart
- (T008–T009–T013) tests in test/unit/

---

## Implementation Strategy

### MVP Scope (recommended)

- Complete Phase 1 + Phase 2 + Phase 3 (US1) and stop to validate the independent test for US1.

### Incremental Delivery

- Ship US1 (paid enrollment submission + pending)
- Ship US2 (My Learnings + status visibility)
- Ship US3 (reconciliation/approved UX polish)
