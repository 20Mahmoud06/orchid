import 'package:flutter/material.dart';

import '../../../../../app/router/app_nav.dart';
import '../../../../../app/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../orders/domain/models/order_model.dart';
import 'recent_orders_data_table.dart';
import 'recent_orders_empty_state.dart';
import 'recent_orders_footer.dart';
import 'recent_orders_header.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({
    super.key,
    required this.orders,
    required this.totalOrders,
    required this.periodLabel,
    this.onShowMore,
    this.isLoadingMore = false,
  });

  final List<Order> orders;
  final int totalOrders;
  final String periodLabel;
  final VoidCallback? onShowMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentOrdersHeader(
            onViewAll: () => AppNav.go(context, AppRoutes.orders),
            periodLabel: periodLabel,
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            RecentOrdersEmptyState(periodLabel: periodLabel)
          else
            RecentOrdersDataTable(
              orders: orders,
              onViewOrder: (order) =>
                  AppNav.push(context, AppRoutes.orderDetails(order.orderCode)),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          RecentOrdersFooter(
            visibleCount: orders.length,
            totalOrders: totalOrders,
            onViewAll: () => AppNav.go(context, AppRoutes.orders),
            onShowMore: onShowMore,
            isLoadingMore: isLoadingMore,
          ),
        ],
      ),
    );
  }
}
