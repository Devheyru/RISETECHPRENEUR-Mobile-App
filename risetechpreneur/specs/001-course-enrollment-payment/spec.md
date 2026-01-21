# Feature Specification: Course Enrollment with Payment Proof Upload

**Feature Branch**: `001-course-enrollment-payment`  
**Created**: 2026-01-19  
**Status**: Draft  
**Input**: User description: "I want to add a course enrollment feature with payment with image submission"

## Clarifications

### Session 2026-01-20

- Q: Should users be able to submit multiple orders for the same course? -> A: Prevent duplicates; if an order already exists for that course (pending/approved), disable Enroll and show status + “View in My Learnings”.
- Q: What transaction screenshot formats/size should be accepted? -> A: Accept PNG/JPG/JPEG up to 5MB.
- Q: Should the enrollment UI collect extra payment fields beyond what the API accepts? -> A: No; collect only what the API accepts (course selection + screenshot).
- Q: Which order statuses must the app support? -> A: Support `pending` and `approved`, and show a safe generic fallback for any other status value.
- Q: Where should learners see their order status? -> A: Show order status both on the course detail screen and in “My Learnings”.

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Submit Enrollment + Payment Proof (Priority: P1)

As a learner, I want to enroll in a paid course by submitting a transaction screenshot (proof image) so I can request access to the course.

**Why this priority**: This is the core value of the feature and enables paid enrollment.

**Independent Test**: A tester can select a paid course, attach a valid transaction screenshot, submit, and see the resulting order in a "Pending" state.

**Acceptance Scenarios**:

1. **Given** I am signed in and viewing a paid course, **When** I choose “Enroll” and submit a valid proof image, **Then** the app confirms submission and the resulting order status is **pending**.
2. **Given** I already have an existing order for this course (e.g., pending/approved), **When** I view the course, **Then** the app disables “Enroll” and shows the current order status plus a “View in My Learnings” action.
3. **Given** I have not provided required fields (or the image is missing), **When** I try to submit, **Then** the app blocks submission and clearly explains what is required.
4. **Given** the network fails during submission, **When** I submit my enrollment request, **Then** the app shows a user-friendly error and allows me to retry without losing already-entered information.

---

### User Story 2 - Track Enrollment Status (Priority: P2)

As a learner, I want to see the status of my enrollment request (pending/approved) so I know whether I can access the course and what to do next.

**Why this priority**: Prevents confusion and support requests after payment submission.

**Independent Test**: A tester can view an enrollment request and see its current status and next steps.

**Acceptance Scenarios**:

1. **Given** I have submitted an order, **When** I open “My Learnings” (or an equivalent enrollments view), **Then** I can see the ordered course with its current status (e.g., pending/approved).
2. **Given** I open the course detail screen for a course I have ordered, **When** the app loads, **Then** I see the current order status and next steps without needing to navigate elsewhere.

---

### User Story 3 - Approve/Reject Enrollment Requests (Priority: P3)

As operations staff, I want to verify payments and approve orders so only verified learners get access.

**Why this priority**: This is required for real-world payment verification, but it depends on backend/admin capabilities.

**Independent Test**: A tester can submit an order, then (via backend/admin workflow) change its status to approved and observe the app reflecting the new status in “My Learnings”.

**Acceptance Scenarios**:

1. **Given** an order exists with status **pending**, **When** it becomes **approved** in the system, **Then** the learner sees the status update and can access the course.

---

### Edge Cases

- What happens when a learner attempts to enroll in the same paid course again? (Expected: blocked; show status + link to My Learnings)
- What happens when the image is too large (>5MB) or in an unsupported format? (Expected: block submission with a clear message)
- What happens when a learner changes accounts after starting a submission?
- What happens when a course is free (no payment required)?
- How does the system handle partial submissions (details entered but not submitted)?

## External Interfaces _(required for this feature)_

### Place Course Order (Paid Enrollment)

- **Endpoint**: `POST https://rise-techpreneur.havanacademy.com/api/orders/place`
- **Auth**: Bearer token (user must be logged in)
- **Request Type**: `multipart/form-data`
- **Request Fields**:
  - `course_id` (required)
  - `transaction_screenshot` (required file upload)
- **Expected Response (summary)**: includes a success message and an `order` object with `id`, `course_id`, `user_id`, `status` (e.g., `pending`), timestamps, and a `transaction_screenshot` path.

### Fetch Ordered Courses (My Learnings)

- **Endpoint**: `GET https://rise-techpreneur.havanacademy.com/api/my-learnings`
- **Auth**: Bearer token
- **Expected Response (summary)**: `success=true` and a `data[]` list where each item contains `order_id`, `status` (e.g., `approved`), a `course` object, and `total_students`.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The system MUST allow signed-in learners to initiate enrollment for a course.
- **FR-002**: For paid courses, the system MUST place an order by sending `course_id` and a `transaction_screenshot` file to `POST /api/orders/place` using `multipart/form-data`.
- **FR-003**: The system MUST validate enrollment submissions before sending (course selected, image attached, file type is PNG/JPG/JPEG, file size <= 5MB).
- **FR-004**: On successful order placement, the system MUST show a confirmation message and treat the resulting order status as `pending`.
- **FR-005**: The system MUST allow learners to view ordered courses by fetching data from `GET /api/my-learnings`.
- **FR-006**: The system MUST display order status values returned by the system and provide clear next steps. It MUST explicitly support `pending` and `approved`, and it MUST safely handle unknown status values (e.g., display the raw status with a generic message).
- **FR-007**: The system MUST display the learner’s order status both in “My Learnings” and on the course detail screen for ordered courses.
- **FR-008**: The system MUST prevent unauthenticated access to order placement and “My Learnings”.
- **FR-009**: The system MUST prevent duplicate paid orders per course for the same user; if an order exists for the course, the UI MUST disable “Enroll” and provide a “View in My Learnings” action.
- **FR-010**: The system MUST handle free courses by enabling enrollment without payment proof (immediate access).

### Non-Functional Requirements _(mandatory)_

- **NFR-001 (Quality)**: The implementation MUST pass static analysis with no new warnings/errors.
- **NFR-002 (Testing)**: New/changed behavior MUST have automated tests at the appropriate level (unit/widget), and critical multi-screen flows SHOULD have an end-to-end test.
- **NFR-003 (UX Consistency)**: Enrollment and payment-proof UI MUST match the existing design system and include loading/empty/error states.
- **NFR-004 (Performance)**: Image selection/preview and submission MUST keep the app responsive and avoid noticeable UI freezes during normal usage.
- **NFR-005 (Reliability)**: Network failures MUST surface clear messages and enable retry without data loss.

### Key Entities _(include if feature involves data)_

- **Order**: Represents a learner’s paid enrollment request; includes `id`, `course_id`, `user_id`, `status` (e.g., `pending`), timestamps, and `transaction_screenshot` reference.
- **Learning**: Represents the learner-facing view of an order plus its course details as returned by “My Learnings”; includes `order_id`, `status`, `course`, and `total_students`.
- **OrderStatus**: A state model aligned to backend values. The UI MUST explicitly support `pending` and `approved` and tolerate unknown values.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: 90% of learners can submit a paid enrollment request (including image proof) in under 2 minutes without assistance.
- **SC-002**: 95% of enrollment submissions provide clear, actionable error messages when validation fails (measured by usability test completion without confusion).
- **SC-003**: Learners can always see the current enrollment status within 5 seconds of navigating to the course/enrollments view under typical network conditions.
- **SC-004**: Support inquiries about “Did my payment go through?” decrease by 30% after release (compared to pre-feature baseline).
