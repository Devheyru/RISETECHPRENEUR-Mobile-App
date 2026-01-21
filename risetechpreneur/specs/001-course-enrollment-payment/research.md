# Research: Course Enrollment (Orders) + Payment Proof Upload

This document resolves open questions and locks down implementation decisions for the feature described in `spec.md`.

## Open Questions Resolved

### 1) Free-course enrollment behavior

- **Decision**: Treat courses with `price == 0` as **immediately accessible** with **no backend call** (no order placement, no screenshot upload).
- **Rationale**: The backend API surface provided for this feature only supports paid enrollment via `POST /api/orders/place` (requires `transaction_screenshot`). There is no described endpoint for a free-enroll action.
- **Alternatives considered**:
  - Add a “free enroll” backend endpoint (preferred long-term, but not available).
  - Attempt to call `POST /api/orders/place` with a dummy file (violates API contract/FR-003).

### 2) Does `GET /api/my-learnings` include `pending` orders?

- **Decision**: Implement the client to **work correctly whether or not** the backend includes `pending` items in `/api/my-learnings`.
- **Rationale**: We have an example response showing `approved`, but not an explicit guarantee about `pending`. The UI requirements still expect status visibility on course detail and “My Learnings”.
- **Implementation approach**:
  - Source of truth is `GET /api/my-learnings` when it contains the order.
  - Additionally, after a successful `POST /api/orders/place`, persist a lightweight local record keyed by `course_id` (e.g., `{orderId,status,submittedAt}`) so the course detail screen can show **Pending** immediately even if `/api/my-learnings` doesn’t return it yet.
  - “My Learnings” screen can show:
    - server-backed list from `/api/my-learnings`, and
    - an optional “Pending submissions” section derived from local cache that is de-duplicated against server results.
- **Alternatives considered**:
  - Assume `/api/my-learnings` always includes pending (simpler but brittle).
  - Poll `GET /api/my-learnings` aggressively (wastes network and battery).

## Technology & Integration Decisions

### Image selection

- **Decision**: Use `image_picker` for selecting a screenshot from gallery (and optionally camera if desired later).
- **Rationale**: Standard Flutter solution, good platform support, simple API.
- **Alternatives considered**: `file_picker` (broader file types; less “image-first” UX).

### Upload format

- **Decision**: Use `http.MultipartRequest` to send `multipart/form-data` with fields:
  - `course_id` (string)
  - `transaction_screenshot` (file)
    and headers:
  - `Authorization: Bearer <token>`
  - `Accept: application/json`
- **Rationale**: Matches backend contract exactly.

### Testing strategy (multipart)

- **Decision**: For unit tests of multipart request construction, inject an `http.Client`/`http.BaseClient` into the repository and capture `send()` to assert headers/fields/file part names deterministically.
- **Rationale**: `http.MultipartRequest` builds the final request at `send()` time, so capturing there is more reliable than relying on `MockClient` request interception.

### Client-side validation

- **Decision**: Validate before upload:
  - must select image
  - allowed extensions: `.png`, `.jpg`, `.jpeg` (case-insensitive)
  - file size: `<= 5MB`
- **Rationale**: Prevents unnecessary network calls and matches FR-003.

### State management & caching

- **Decision**: Implement a Riverpod-driven flow using:
  - a repository for network calls
  - providers for “my learnings” fetch and “place order” mutation
  - local persistence via `flutter_secure_storage` for pending-submission metadata
- **Rationale**: Aligns with existing architecture and keeps UI states consistent.

### Error handling

- **Decision**: Standardize error display using existing patterns (SnackBars + inline error widgets where applicable) and map:
  - `401` → “Please sign in again” + route to auth
  - network timeouts/offline → “Check your connection” + retry
  - validation errors (`4xx`) → show user-friendly message when present
- **Rationale**: Matches constitution reliability gate and existing `ErrorHandler` usage.
