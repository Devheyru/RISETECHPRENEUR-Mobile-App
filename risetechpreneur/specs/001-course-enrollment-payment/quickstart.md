# Quickstart: Course Enrollment (Orders) + Payment Proof Upload

## Prerequisites

- Flutter SDK installed
- A backend account (login works via `POST /api/login-user` in current app)
- Platform permissions in place for image picking (iOS `NSPhotoLibraryUsageDescription`; Android media permissions only if required by the chosen picker flow)

## Run the app

- `flutter pub get`
- `flutter run`

## Manual test flow (happy path)

1. Sign in using the existing Auth screen.
2. Open **Courses** and select a paid course.
3. Tap **Enroll**.
4. Pick a transaction screenshot (PNG/JPG/JPEG, <= 5MB).
5. Submit.
6. Confirm you see:
   - success feedback
   - course detail shows status **Pending**
7. Open **My Learnings** (entry point will be in the More screen) and verify the course appears with a status.

8. Pull to refresh My Learnings and confirm:
   - server-backed enrollments render under **From server**
   - locally-saved submissions (when not yet present on server) render under **Pending submissions**

## Error/edge flows to verify

- Not signed in → tapping Enroll routes to Auth and shows a helpful message.
- Missing image → submit blocked with clear validation message.
- Image too large / unsupported format → submit blocked.
- Network failure/timeouts → error shown + retry works without losing the selected screenshot.
- Duplicate order attempt → Enroll disabled; “View in My Learnings” available.

## Notes

- If the backend does not include `pending` in `/api/my-learnings`, the UI will still show the submission as Pending using a local pending cache (see `research.md`).
- If an admin updates the order to `approved`, a refresh should show **Approved** and the local pending cache entry is cleared.
