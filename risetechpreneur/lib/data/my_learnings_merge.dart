library;

import 'package:risetechpreneur/data/order_models.dart';

/// Result of merging server-backed learnings with locally cached pending
/// submissions.
class MyLearningsMergeResult {
  final List<PendingSubmission> pendingOnly;

  const MyLearningsMergeResult({required this.pendingOnly});
}

/// Returns locally cached pending submissions that are not already represented
/// in the server learnings list.
MyLearningsMergeResult mergeMyLearningsPendingOnly({
  required List<int> serverCourseIds,
  required Map<int, PendingSubmission> pendingByCourseId,
}) {
  final serverIds = serverCourseIds.toSet();

  final pendingOnly =
      pendingByCourseId.entries
          .where((e) => !serverIds.contains(e.key))
          .map((e) => e.value)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  return MyLearningsMergeResult(pendingOnly: pendingOnly);
}
