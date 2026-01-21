import 'package:flutter_test/flutter_test.dart';
import 'package:risetechpreneur/data/order_models.dart';
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

void main() {
  test('save/read/remove by courseId', () async {
    final store = PendingSubmissionStore(storage: _FakeStorage());

    final submission = PendingSubmission(
      courseId: 3,
      orderId: 11,
      status: OrderStatus.pending,
      submittedAt: DateTime.parse('2026-01-20T10:00:00Z'),
    );

    await store.save(courseId: 3, submission: submission);

    final readBack = await store.readByCourseId(3);
    expect(readBack, isNotNull);
    expect(readBack!.courseId, 3);
    expect(readBack.orderId, 11);
    expect(readBack.status.isPending, isTrue);

    await store.removeByCourseId(3);
    expect(await store.readByCourseId(3), isNull);
  });
}
