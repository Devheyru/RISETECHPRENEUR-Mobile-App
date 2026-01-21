import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/order_providers.dart';
import 'package:risetechpreneur/data/pending_submission_store.dart';
import 'package:risetechpreneur/presentation/screens/my_learnings_screen.dart';

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
  testWidgets('My Learnings loading state', (tester) async {
    await mockNetworkImagesFor(() async {
      final completer = Completer<List<Learning>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthState(
                restoreOnInit: false,
                initialUser: AppUser(id: '1', email: 'a@b.com', token: 't'),
              ),
            ),
            myLearningsProvider.overrideWith((ref) => completer.future),
            pendingSubmissionStoreProvider.overrideWithValue(
              PendingSubmissionStore(storage: _FakeStorage()),
            ),
          ],
          child: const MaterialApp(home: MyLearningsScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('My Learnings error state', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthState(
                restoreOnInit: false,
                initialUser: AppUser(id: '1', email: 'a@b.com', token: 't'),
              ),
            ),
            myLearningsProvider.overrideWith((ref) async {
              throw NetworkException();
            }),
            pendingSubmissionStoreProvider.overrideWithValue(
              PendingSubmissionStore(storage: _FakeStorage()),
            ),
          ],
          child: const MaterialApp(home: MyLearningsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('No internet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  testWidgets('My Learnings empty state', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthState(
                restoreOnInit: false,
                initialUser: AppUser(id: '1', email: 'a@b.com', token: 't'),
              ),
            ),
            myLearningsProvider.overrideWith((ref) async => const <Learning>[]),
            pendingSubmissionsProvider.overrideWith(
              (ref) async => <int, PendingSubmission>{},
            ),
          ],
          child: const MaterialApp(home: MyLearningsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No enrollments yet.'), findsOneWidget);
    });
  });

  testWidgets('My Learnings success state', (tester) async {
    await mockNetworkImagesFor(() async {
      final learnings = <Learning>[
        Learning(orderId: 1, status: OrderStatus.approved, course: _course(1)),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthState(
                restoreOnInit: false,
                initialUser: AppUser(id: '1', email: 'a@b.com', token: 't'),
              ),
            ),
            myLearningsProvider.overrideWith((ref) async => learnings),
            pendingSubmissionsProvider.overrideWith(
              (ref) async => <int, PendingSubmission>{},
            ),
          ],
          child: const MaterialApp(home: MyLearningsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Course 1'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });
  });
}
