import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';

class RecentOrdersFooter extends StatelessWidget {
  const RecentOrdersFooter({
    super.key,
    required this.visibleCount,
    required this.totalOrders,
    required this.onViewAll,
    this.onShowMore,
    this.isLoadingMore = false,
  });

  final int visibleCount;
  final int totalOrders;
  final VoidCallback onViewAll;
  final VoidCallback? onShowMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        CustomText(
          text: 'Showing $visibleCount of $totalOrders orders',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onShowMore != null)
              TextButton(
                onPressed: isLoadingMore ? null : onShowMore,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: isLoadingMore
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const CustomText(
                        text: 'Show more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'View All Orders',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
