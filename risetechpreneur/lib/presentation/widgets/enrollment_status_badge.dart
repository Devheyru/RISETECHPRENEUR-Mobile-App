import 'package:flutter/material.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/order_models.dart';

class EnrollmentStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const EnrollmentStatusBadge({super.key, required this.status});

  Color get _foreground {
    if (status.isPending) return Colors.orange.shade800;
    if (status.isApproved) return Colors.green.shade800;
    return AppColors.textGrey;
  }

  Color get _background {
    if (status.isPending) return Colors.orange.withValues(alpha: 0.12);
    if (status.isApproved) return Colors.green.withValues(alpha: 0.12);
    return AppColors.textGrey.withValues(alpha: 0.10);
  }

  String get _label {
    if (status.isPending) return 'Pending';
    if (status.isApproved) return 'Approved';
    if (status.raw == OrderStatus.unknown.raw) return 'Unknown';
    return status.raw;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.isApproved
                ? Icons.check_circle
                : status.isPending
                ? Icons.hourglass_top
                : Icons.info,
            size: 14,
            color: _foreground,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
