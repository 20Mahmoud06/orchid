import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';

class OrderStatusTabs extends StatelessWidget {
  const OrderStatusTabs({
    super.key,
    required this.orders,
    required this.selectedStatus,
    required this.onChanged,
  });

  final List<Order> orders;
  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  int _countFor(OrderStatus? status) => status == null
      ? orders.length
      : orders.where((order) => order.status == status).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _OrderTab(
            label: 'All',
            count: _countFor(null),
            isSelected: selectedStatus == null,
            onTap: () => onChanged(null),
          ),
          for (final status in OrderStatus.values)
            _OrderTab(
              label: status.label,
              count: _countFor(status),
              isSelected: selectedStatus == status,
              onTap: () => onChanged(status),
            ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: CustomText(
            text: '$label ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
