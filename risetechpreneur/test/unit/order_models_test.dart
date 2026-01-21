import 'package:flutter_test/flutter_test.dart';
import 'package:risetechpreneur/data/order_models.dart';

void main() {
  group('OrderStatus', () {
    test('parses known statuses case-insensitively', () {
      expect(OrderStatus.parse('Pending').isPending, isTrue);
      expect(OrderStatus.parse('APPROVED').isApproved, isTrue);
    });

    test('handles unknown/empty values safely', () {
      expect(OrderStatus.parse(null).displayLabel, 'Unknown');
      expect(OrderStatus.parse('').displayLabel, 'Unknown');
      expect(OrderStatus.parse('rejected').displayLabel, 'rejected');
    });
  });

  group('Order', () {
    test('parses from backend snake_case fields', () {
      final order = Order.fromJson({
        'id': 11,
        'course_id': 3,
        'user_id': 2,
        'status': 'pending',
        'transaction_screenshot': 'public/order/transaction_screenshots/x.jpg',
        'created_at': '2026-01-20T10:00:00Z',
        'updated_at': '2026-01-20T10:01:00Z',
      });

      expect(order.id, 11);
      expect(order.courseId, 3);
      expect(order.userId, 2);
      expect(order.status.isPending, isTrue);
      expect(
        order.transactionScreenshotPath,
        contains('transaction_screenshots'),
      );
      expect(order.createdAt, isNotNull);
      expect(order.updatedAt, isNotNull);
    });
  });
}
