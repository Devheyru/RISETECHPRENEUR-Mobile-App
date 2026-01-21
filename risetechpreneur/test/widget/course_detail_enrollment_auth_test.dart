import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/order_providers.dart';
import 'package:risetechpreneur/data/pending_submission_store.dart';
import 'package:risetechpreneur/presentation/screens/auth_screen.dart';
import 'package:risetechpreneur/presentation/screens/course_detail_screen.dart';

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

Course _testCourse({double price = 100}) {
  return Course(
    id: 3,
    userId: '1',
    title: 'Test Course',
    subtitle: 'Subtitle',
    slug: 'test-course',
    price: price,
    thumbnail: 'assets/img/education/courses-13.webp',
    category: 'business',
    education: 'professional',
    experience: 'beginner',
    feature: 'new',
    duration: '0',
    description: 'Desc',
    learningPoints: const ['A', 'B'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  testWidgets('Unauthenticated enroll routes to auth', (tester) async {
    await mockNetworkImagesFor(() async {
      final store = PendingSubmissionStore(storage: _FakeStorage());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthState(ref: ref, restoreOnInit: false, initialUser: null),
            ),
            myLearningsProvider.overrideWith((ref) async => const <Learning>[]),
            pendingSubmissionStoreProvider.overrideWithValue(store),
          ],
          child: MaterialApp(home: CourseDetailScreen(course: _testCourse())),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('course_detail_enroll_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });
}
