import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risetechpreneur/core/app_theme.dart';
import 'package:risetechpreneur/data/order_providers.dart';

class PaymentProofSheet extends ConsumerWidget {
  final int courseId;
  final String courseTitle;
  final double coursePriceEtb;

  static const String _paymentAccountNumber = '1000302084797';
  static const String _paymentAccountName = 'Kaytros Gecho Arka';

  const PaymentProofSheet({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.coursePriceEtb,
  });

  static Future<void> show(
    BuildContext context, {
    required int courseId,
    required String courseTitle,
    required double coursePriceEtb,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PaymentProofSheet(
            courseId: courseId,
            courseTitle: courseTitle,
            coursePriceEtb: coursePriceEtb,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProofControllerProvider(courseId));
    final controller = ref.read(
      paymentProofControllerProvider(courseId).notifier,
    );

    final priceLabel = 'ETB ${coursePriceEtb.toStringAsFixed(0)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit payment proof',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              courseTitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),

            _PaymentInstructionCard(
              priceLabel: priceLabel,
              onCopyAccountNumber: () async {
                await Clipboard.setData(
                  const ClipboardData(text: _paymentAccountNumber),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account number copied.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            _PreviewCard(
              file: state.selectedFile,
              onPick:
                  state.isSubmitting
                      ? null
                      : () => controller.pickFromGallery(),
              onClear:
                  state.isSubmitting ? null : () => controller.clearSelected(),
            ),

            if (state.validationError != null) ...[
              const SizedBox(height: 10),
              Text(
                state.validationError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],

            if (state.submitError != null) ...[
              const SizedBox(height: 10),
              Text(
                state.submitError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        state.isSubmitting
                            ? null
                            : () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        state.isSubmitting
                            ? null
                            : () async {
                              final order = await controller.submit();
                              if (order == null) return;

                              if (context.mounted) {
                                Navigator.of(context).maybePop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Enrollment request submitted successfully.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                    child:
                        state.isSubmitting
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Submit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final File? file;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  const _PreviewCard({
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, color: AppColors.textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasFile ? 'Selected image' : 'No image selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryNavy,
                  ),
                ),
              ),
              if (hasFile)
                IconButton(
                  onPressed: onClear,
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasFile)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                file!,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Text(
              'PNG/JPG/JPEG • Max 5MB',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_file),
              label: Text(hasFile ? 'Choose another image' : 'Choose image'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInstructionCard extends StatelessWidget {
  final String priceLabel;
  final VoidCallback onCopyAccountNumber;

  const _PaymentInstructionCard({
    required this.priceLabel,
    required this.onCopyAccountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Step 1: Send $priceLabel to the account below',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Account Number',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  PaymentProofSheet._paymentAccountNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy account number',
                onPressed: onCopyAccountNumber,
                icon: const Icon(Icons.copy, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Full Name',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          Text(
            PaymentProofSheet._paymentAccountName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Step 2: Upload the transaction screenshot below as proof.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
