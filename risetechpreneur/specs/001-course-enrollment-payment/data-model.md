# Data Model: Course Enrollment (Orders) + Payment Proof Upload

This feature introduces an **Order** domain concept (paid enrollment request) and a **Learning** (user-facing item returned from `/api/my-learnings`).

## Entities

### 1) Order (client view)

Represents the result of placing a paid enrollment request.

- **Fields**
  - `id: int`
  - `courseId: int`
  - `userId: int`
  - `status: OrderStatus`
  - `transactionScreenshotPath: String?` (as returned by backend; optional)
  - `createdAt: DateTime?`
  - `updatedAt: DateTime?`

- **Validation rules**
  - `courseId` required
  - `transaction_screenshot` required for paid courses (enforced at UI validation)

- **State transitions**
  - `pending` → `approved` (backend-driven)
  - Any other status value must be tolerated and displayed safely

### 2) Learning (server response item)

Represents a course the user has ordered/learns, as returned by `GET /api/my-learnings`.

- **Fields**
  - `orderId: int`
  - `status: OrderStatus`
  - `course: Course` (reuse existing `lib/data/models.dart` with safe defaults)
  - `totalStudents: int?`

### 3) OrderStatus (UI model)

A UI-safe status representation.

- **Known values**: `pending`, `approved`
- **Unknown values**: preserve raw string and display generic guidance

## Local Persistence (Pending Cache)

To support immediate feedback after submission and to handle the case where `/api/my-learnings` does not include `pending` items:

- Store a lightweight record keyed by `courseId`:
  - `orderId`
  - `status` (initially `pending`)
  - `submittedAt` (ISO 8601)

Storage mechanism: `flutter_secure_storage` (already in the repo).

## Relationships

- A user can have many `Learning` items.
- A `Learning` item is tied to exactly one `Course` and one `Order` (via `orderId`).
- Duplicate prevention: a user should have at most one _active_ order per course in UI.

## Mapping Notes

- Backend course objects in `/api/my-learnings` may not contain every field used in the full `Course` model. The existing `Course.fromJson` already provides sensible defaults; parsing must remain defensive.
- Date fields may be absent; treat as optional or fall back to `DateTime.now()` only if the UI requires a value.
