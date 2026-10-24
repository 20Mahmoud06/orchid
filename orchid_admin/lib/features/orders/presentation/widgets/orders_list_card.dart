import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';
import 'order_list_tile.dart';
import 'order_status_tabs.dart';

class OrdersListCard extends StatelessWidget {
  const OrdersListCard({
    super.key,
    required this.orders,
    required this.searchController,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.selectedOrderId,
    required this.onOrderSelected,
    required this.periodLabel,
  });

  final List<Order> orders;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final OrderStatus? statusFilter;
  final ValueChanged<OrderStatus?> onStatusFilterChanged;
  final String? selectedOrderId;
  final ValueChanged<Order> onOrderSelected;
  final String periodLabel;

  bool get _hasActiveFilters =>
      searchController.text.trim().isNotEmpty || statusFilter != null;

  String get _emptyMessage {
    if (orders.isNotEmpty && _hasActiveFilters) {
      return 'No orders match your search or status filter.';
    }
    return 'No orders found for $periodLabel.';
  }

  List<Order> get _filteredOrders {
    final query = searchController.text.trim().toLowerCase();

    return orders.where((order) {
      final matchesSearch =
          query.isEmpty ||
          order.orderCode.toLowerCase().contains(query) ||
          (order.customerName?.toLowerCase().contains(query) ?? false);
      final matchesStatus =
          statusFilter == null || order.status == statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: OrderStatusTabs(
              orders: orders,
              selectedStatus: statusFilter,
              onChanged: onStatusFilterChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _OrdersSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                CustomText(
                  text: 'ORDERS QUEUE',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                CustomText(
                  text: 'Showing ${filtered.length} of ${orders.length}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: CustomText(
                  text: _emptyMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final order = filtered[index];
                return OrderListTile(
                  order: order,
                  isSelected: selectedOrderId == order.id,
                  onTap: () => onOrderSelected(order),
                );
              },
            ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: CustomText(
              text:
                  '${orders.length} order${orders.length == 1 ? '' : 's'} in $periodLabel',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersSearchField extends StatelessWidget {
  const _OrdersSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: const InputDecoration(
          hintText: 'Search by order code or customer name...',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
