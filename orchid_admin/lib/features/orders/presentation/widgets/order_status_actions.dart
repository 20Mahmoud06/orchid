import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/order_model.dart';

class OrderStatusActions extends StatelessWidget {
  const OrderStatusActions({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  final OrderStatus status;
  final ValueChanged<OrderStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final canAccept = status == OrderStatus.pending;
    final canComplete = status == OrderStatus.preparing;
    final canCancel =
        status == OrderStatus.pending || status == OrderStatus.preparing;
    final isCanceled = status == OrderStatus.canceled;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (canCancel)
          OutlinedButton.icon(
            onPressed: onStatusChanged == null
                ? null
                : () => onStatusChanged!(OrderStatus.canceled),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Cancel Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              backgroundColor: AppColors.alertSoft,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.25)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (canAccept)
          ElevatedButton.icon(
            onPressed: onStatusChanged == null
                ? null
                : () => onStatusChanged!(OrderStatus.preparing),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Accept Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (canComplete)
          ElevatedButton.icon(
            onPressed: onStatusChanged == null
                ? null
                : () => onStatusChanged!(OrderStatus.completed),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Mark Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (isCanceled)
          OutlinedButton.icon(
            onPressed: onStatusChanged == null
                ? null
                : () => onStatusChanged!(OrderStatus.preparing),
            icon: const Icon(Icons.undo_rounded, size: 16),
            label: const Text('Reopen Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}
