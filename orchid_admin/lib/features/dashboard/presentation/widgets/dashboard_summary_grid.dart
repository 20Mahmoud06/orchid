import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'summary_card.dart';

class DashboardSummaryGrid extends StatelessWidget {
  const DashboardSummaryGrid({
    super.key,
    required this.totalProducts,
    required this.totalOrders,
    required this.completedOrders,
    required this.newOrders,
    required this.preparingOrders,
    required this.canceledOrders,
    required this.completedSales,
    required this.periodLabel,
    required this.isNarrow,
    required this.isMobile,
  });

  final int totalProducts;
  final int totalOrders;
  final int completedOrders;
  final int newOrders;
  final int preparingOrders;
  final int canceledOrders;
  final double completedSales;
  final String periodLabel;
  final bool isNarrow;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final cards = [
      SummaryCard(
        label: 'Total Products',
        value: totalProducts.toString(),
        subtitle: 'Current catalog',
        icon: Icons.eco_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.textSecondary,
      ),
      SummaryCard(
        label: 'Total Orders',
        value: totalOrders.toString(),
        subtitle: periodLabel,
        icon: Icons.shopping_bag_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.textSecondary,
      ),
      SummaryCard(
        label: 'New Orders',
        value: newOrders.toString(),
        subtitle: 'Waiting to be accepted',
        icon: Icons.fiber_new_outlined,
        accentColor: AppColors.warning,
        subtitleColor: AppColors.warning,
      ),
      SummaryCard(
        label: 'Preparing Orders',
        value: preparingOrders.toString(),
        subtitle: 'Awaiting completion',
        icon: Icons.hourglass_bottom_rounded,
        accentColor: AppColors.orchidStrong,
        subtitleColor: AppColors.orchidStrong,
      ),
      SummaryCard(
        label: 'Completed Orders',
        value: completedOrders.toString(),
        subtitle: 'Finished successfully',
        icon: Icons.task_alt_rounded,
        accentColor: AppColors.success,
        subtitleColor: AppColors.success,
      ),
      SummaryCard(
        label: 'Cancelled Orders',
        value: canceledOrders.toString(),
        subtitle: 'Cancelled in this period',
        icon: Icons.cancel_outlined,
        accentColor: AppColors.error,
        subtitleColor: AppColors.error,
      ),
      SummaryCard(
        label: 'Completed Sales',
        value: '${completedSales.toStringAsFixed(0)} EGP',
        subtitle: 'From completed orders',
        icon: Icons.payments_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.success,
      ),
    ];

    final columns = isMobile
        ? 1
        : isNarrow
        ? 2
        : 4;
    final rows = <List<SummaryCard>>[];
    for (var i = 0; i < cards.length; i += columns) {
      final end = i + columns > cards.length ? cards.length : i + columns;
      rows.add(cards.sublist(i, end));
    }

    return Column(
      children: [
        for (var row = 0; row < rows.length; row++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var column = 0; column < columns; column++) ...[
                Expanded(
                  child: column < rows[row].length
                      ? rows[row][column]
                      : const SizedBox.shrink(),
                ),
                if (column < columns - 1) const SizedBox(width: 16),
              ],
            ],
          ),
          if (row < rows.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
