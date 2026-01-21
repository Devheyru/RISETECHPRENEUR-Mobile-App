import 'package:flutter_test/flutter_test.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/pending_cache_reconciliation.dart';
import 'package:risetechpreneur/data/pending_submission_store.dart';

class _FakeStorage implements KeyValueStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}

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
  test('clears local pending cache when server returns approved', () async {
    final store = PendingSubmissionStore(storage: _FakeStorage());

    await store.save(
      courseId: 3,
      submission: PendingSubmission(
        courseId: 3,
        orderId: 11,
        status: OrderStatus.pending,
        submittedAt: DateTime.parse('2026-01-20T10:00:00Z'),
      ),
    );

    expect(await store.readByCourseId(3), isNotNull);

    await reconcilePendingSubmissions(
      serverLearnings: [
        Learning(orderId: 11, status: OrderStatus.approved, course: _course(3)),
      ],
      store: store,
    );

    expect(await store.readByCourseId(3), isNull);
  });
}
