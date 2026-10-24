import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/time/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';
import 'order_status_actions.dart';
import 'order_status_badge.dart';

class OrderDetailsHeaderCard extends StatelessWidget {
  const OrderDetailsHeaderCard({
    super.key,
    required this.order,
    this.onStatusChanged,
  });

  final Order order;
  final ValueChanged<OrderStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 560;
              final title = _buildTitle();
              final actions = OrderStatusActions(
                status: order.status,
                onStatusChanged: onStatusChanged,
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 14), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              CustomText(
                text:
                    'Delivery on ${formatShortDate(order.deliveryDate)} '
                    'at ${formatClockTime(order.orderTime)}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomText(
              text: 'Order #${order.orderCode}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
        const SizedBox(height: 6),
        CustomText(
          text: 'Placed on ${formatPlacedAt(order.createdAt)}',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
