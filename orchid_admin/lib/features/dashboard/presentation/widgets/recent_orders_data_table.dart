import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/time/date_formatter.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/widgets/order_status_badge.dart';

class RecentOrdersDataTable extends StatelessWidget {
  const RecentOrdersDataTable({
    super.key,
    required this.orders,
    required this.onViewOrder,
  });

  final List<Order> orders;
  final ValueChanged<Order> onViewOrder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 44,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
              dividerThickness: 0.5,
              columnSpacing: 28,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: _HeaderLabel('ORDER CODE')),
                DataColumn(label: _HeaderLabel('CUSTOMER')),
                DataColumn(label: _HeaderLabel('DATE')),
                DataColumn(label: _HeaderLabel('TOTAL')),
                DataColumn(label: _HeaderLabel('STATUS')),
                DataColumn(label: _HeaderLabel('ACTION')),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      CustomText(
                        text: '#${order.orderCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      CustomText(
                        text: (order.customerName?.isNotEmpty ?? false)
                            ? order.customerName!
                            : 'Customer',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(
                      CustomText(
                        text: formatRecentDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    DataCell(
                      CustomText(
                        text: '${order.total.toStringAsFixed(0)} EGP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(OrderStatusBadge(status: order.status)),
                    DataCell(
                      _ViewOrderButton(onPressed: () => onViewOrder(order)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ViewOrderButton extends StatelessWidget {
  const _ViewOrderButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const CustomText(
        text: 'View',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
