import 'package:flutter_test/flutter_test.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/my_learnings_merge.dart';
import 'package:risetechpreneur/data/order_models.dart';

Course _course(int id) {
  return Course(
    id: id,
    userId: '1',
    title: 'Course $id',
    subtitle: 'Subtitle',
    slug: 'course-$id',
    price: 100,
    thumbnail: 'assets/img/education/courses-13.webp',
    category: 'business',
    education: 'professional',
    experience: 'beginner',
    feature: 'new',
    duration: '0',
    description: 'Desc',
    learningPoints: const ['A'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('dedupes pending cache against server learnings by courseId', () {
    final serverLearnings = <Learning>[
      Learning(orderId: 1, status: OrderStatus.approved, course: _course(1)),
      Learning(orderId: 2, status: OrderStatus.pending, course: _course(2)),
    ];

    final pendingByCourseId = <int, PendingSubmission>{
      2: PendingSubmission(
        courseId: 2,
        orderId: 22,
        status: OrderStatus.pending,
        submittedAt: DateTime.parse('2026-01-20T10:00:00Z'),
      ),
      3: PendingSubmission(
        courseId: 3,
        orderId: 33,
        status: OrderStatus.pending,
        submittedAt: DateTime.parse('2026-01-20T12:00:00Z'),
      ),
    };

    final result = mergeMyLearningsPendingOnly(
      serverCourseIds: serverLearnings.map((e) => e.course.id).toList(),
      pendingByCourseId: pendingByCourseId,
    );

    expect(result.pendingOnly.map((e) => e.courseId), [3]);
  });

  test('sorts pending-only by submittedAt descending', () {
    final pendingByCourseId = <int, PendingSubmission>{
      3: PendingSubmission(
        courseId: 3,
        orderId: 33,
        status: OrderStatus.pending,
        submittedAt: DateTime.parse('2026-01-20T12:00:00Z'),
      ),
      4: PendingSubmission(
        courseId: 4,
        orderId: 44,
        status: OrderStatus.pending,
        submittedAt: DateTime.parse('2026-01-20T13:00:00Z'),
      ),
    };

    final result = mergeMyLearningsPendingOnly(
      serverCourseIds: const <int>[],
      pendingByCourseId: pendingByCourseId,
    );

    expect(result.pendingOnly.map((e) => e.courseId), [4, 3]);
  });
}
