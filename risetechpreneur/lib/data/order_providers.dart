library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:risetechpreneur/core/error_handler.dart';
import 'package:risetechpreneur/core/enrollment_validation.dart';
import 'package:risetechpreneur/data/auth_provider.dart';
import 'package:risetechpreneur/data/pending_cache_reconciliation.dart';
import 'package:risetechpreneur/data/order_models.dart';
import 'package:risetechpreneur/data/order_repository.dart';
import 'package:risetechpreneur/data/pending_submission_store.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final repository = OrderRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final pendingSubmissionsProvider =
    FutureProvider<Map<int, PendingSubmission>>((ref) async {
      final store = ref.watch(pendingSubmissionStoreProvider);
      return store.readAll();
    });

final myLearningsProvider = FutureProvider<List<Learning>>((ref) async {
  final user = ref.watch(authProvider);
  final token = user?.token;
  if (token == null || token.isEmpty) {
    return const <Learning>[];
  }

  final repo = ref.watch(orderRepositoryProvider);
  final learnings = await repo.fetchMyLearnings(token: token);

  // Reconcile local pending cache when backend indicates approval.
  final pendingStore = ref.read(pendingSubmissionStoreProvider);
  await reconcilePendingSubmissions(serverLearnings: learnings, store: pendingStore);

  return learnings;
});

class PlaceOrderController extends AsyncNotifier<Order?> {
  @override
  FutureOr<Order?> build() {
    return null;
  }

  Future<Order> placeOrder({required int courseId, required File screenshot}) async {
    final user = ref.read(authProvider);
    final token = user?.token;
    if (token == null || token.isEmpty) {
      throw AuthException(
        message: 'Unauthorized',
        userFriendlyMessage: 'Please sign in to continue.',
        code: 'UNAUTHORIZED',
      );
    }

    state = const AsyncLoading();
    final repo = ref.read(orderRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.placeOrder(
      courseId: courseId,
      screenshot: screenshot,
      token: token,
    ));
    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
    return result.requireValue;
  }
}

final placeOrderControllerProvider =
    AsyncNotifierProvider<PlaceOrderController, Order?>(PlaceOrderController.new);

class EnrollmentStatus {
  final OrderStatus status;
  final bool fromPendingCache;

  const EnrollmentStatus({
    required this.status,
    required this.fromPendingCache,
  });

  bool get isEnrolledOrPending => status.isApproved || status.isPending;
}

final enrollmentStatusByCourseIdProvider =
    FutureProvider.family<EnrollmentStatus?, int>((ref, courseId) async {
      final learnings = await ref.watch(myLearningsProvider.future);
      for (final learning in learnings) {
        if (learning.course.id == courseId) {
          return EnrollmentStatus(
            status: learning.status,
            fromPendingCache: false,
          );
        }
      }

      final pendingStore = ref.watch(pendingSubmissionStoreProvider);
      final pending = await pendingStore.readByCourseId(courseId);
      if (pending == null) return null;
      return EnrollmentStatus(status: pending.status, fromPendingCache: true);
    });

class PaymentProofState {
  final File? selectedFile;
  final String? validationError;
  final bool isSubmitting;
  final String? submitError;

  const PaymentProofState({
    required this.selectedFile,
    required this.validationError,
    required this.isSubmitting,
    required this.submitError,
  });

  const PaymentProofState.initial()
    : selectedFile = null,
      validationError = null,
      isSubmitting = false,
      submitError = null;

  PaymentProofState copyWith({
    File? selectedFile,
    bool clearSelectedFile = false,
    String? validationError,
    bool clearValidationError = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return PaymentProofState(
      selectedFile:
          clearSelectedFile ? null : (selectedFile ?? this.selectedFile),
      validationError:
          clearValidationError
              ? null
              : (validationError ?? this.validationError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}

class PaymentProofController extends Notifier<PaymentProofState> {
  final int _courseId;
  late final ImagePicker _picker;

  PaymentProofController(this._courseId);

  @override
  PaymentProofState build() {
    _picker = ref.watch(imagePickerProvider);
    return const PaymentProofState.initial();
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(clearValidationError: true, clearSubmitError: true);
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final file = File(picked.path);
      state = state.copyWith(selectedFile: file);
    } catch (e, st) {
      final msg = ErrorHandler.handleError(e, st);
      state = state.copyWith(submitError: msg);
    }
  }

  void clearSelected() {
    state = state.copyWith(clearSelectedFile: true, clearValidationError: true);
  }

  bool validate() {
    final error = validatePaymentProofImage(state.selectedFile);
    state = state.copyWith(validationError: error);
    return error == null;
  }

  Future<Order?> submit() async {
    if (!validate()) return null;
    final file = state.selectedFile;
    if (file == null) return null;

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);

    try {
      final order = await ref
          .read(placeOrderControllerProvider.notifier)
          .placeOrder(courseId: _courseId, screenshot: file);

      final pendingStore = ref.read(pendingSubmissionStoreProvider);
      await pendingStore.save(
        courseId: _courseId,
        submission: PendingSubmission(
          courseId: _courseId,
          orderId: order.id == 0 ? null : order.id,
          status: order.status,
          submittedAt: DateTime.now().toUtc(),
        ),
      );

      ref.invalidate(myLearningsProvider);
      ref.invalidate(pendingSubmissionsProvider);

      state = state.copyWith(isSubmitting: false);
      return order;
    } catch (e, st) {
      final msg = ErrorHandler.handleError(e, st);
      state = state.copyWith(isSubmitting: false, submitError: msg);
      return null;
    }
  }
}

final paymentProofControllerProvider =
    NotifierProvider.autoDispose
        .family<PaymentProofController, PaymentProofState, int>(
          PaymentProofController.new,
        );
