library;

import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/pending_submission_store.dart';

/// Clears local pending submissions when the backend indicates the learner is
/// approved/enrolled for that course.
Future<void> reconcilePendingSubmissions({
  required List<Learning> serverLearnings,
  required PendingSubmissionStore store,
}) async {
  final approvedCourseIds =
      serverLearnings
          .where((l) => l.status.isApproved)
          .map((l) => l.course.id)
          .toSet();

  if (approvedCourseIds.isEmpty) return;

  await store.removeMany(approvedCourseIds);
}
