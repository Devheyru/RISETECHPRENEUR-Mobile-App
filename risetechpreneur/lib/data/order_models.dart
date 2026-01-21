library;

import 'package:risetechpreneur/data/models.dart';

OrderStatus orderStatusFromJsonValue(Object? value) {
  final raw = value?.toString().trim();
  return OrderStatus.parse(raw);
}

DateTime? _tryParseDateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

class OrderStatus {
  final String raw;

  const OrderStatus._(this.raw);

  static const pending = OrderStatus._('pending');
  static const approved = OrderStatus._('approved');
  static const unknown = OrderStatus._('unknown');

  static OrderStatus parse(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return unknown;
    if (normalized == pending.raw) return pending;
    if (normalized == approved.raw) return approved;
    return OrderStatus._(normalized);
  }

  bool get isPending => raw == pending.raw;
  bool get isApproved => raw == approved.raw;
  bool get isKnown => isPending || isApproved || raw == unknown.raw;

  String get displayLabel {
    if (isPending) return 'Pending';
    if (isApproved) return 'Approved';
    if (raw == unknown.raw) return 'Unknown';
    return raw;
  }

  @override
  String toString() => raw;
}

class Order {
  final int id;
  final int courseId;
  final int userId;
  final OrderStatus status;
  final String? transactionScreenshotPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.status,
    this.transactionScreenshotPath,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      courseId: int.tryParse(json['course_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      status: orderStatusFromJsonValue(json['status']),
      transactionScreenshotPath: json['transaction_screenshot']?.toString(),
      createdAt: _tryParseDateTime(json['created_at']),
      updatedAt: _tryParseDateTime(json['updated_at']),
    );
  }
}

class Learning {
  final int orderId;
  final OrderStatus status;
  final Course course;
  final int? totalStudents;

  const Learning({
    required this.orderId,
    required this.status,
    required this.course,
    this.totalStudents,
  });

  factory Learning.fromJson(Map<String, dynamic> json) {
    final courseJson = json['course'];
    return Learning(
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      status: orderStatusFromJsonValue(json['status']),
      course:
          courseJson is Map<String, dynamic>
              ? Course.fromJson(courseJson)
              : Course.fromJson(const <String, dynamic>{}),
      totalStudents: int.tryParse(json['total_students']?.toString() ?? ''),
    );
  }
}

class PendingSubmission {
  final int courseId;
  final int? orderId;
  final OrderStatus status;
  final DateTime submittedAt;

  const PendingSubmission({
    required this.courseId,
    required this.orderId,
    required this.status,
    required this.submittedAt,
  });

  factory PendingSubmission.fromJson(Map<String, dynamic> json) {
    return PendingSubmission(
      courseId: int.tryParse(json['courseId']?.toString() ?? '') ?? 0,
      orderId: int.tryParse(json['orderId']?.toString() ?? ''),
      status: orderStatusFromJsonValue(json['status']),
      submittedAt:
          DateTime.tryParse(json['submittedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'orderId': orderId,
      'status': status.raw,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
