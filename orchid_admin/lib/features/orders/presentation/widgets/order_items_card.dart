import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';
import 'order_items_list.dart';
import 'order_summary.dart';

class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Order Items (${order.itemCount})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          OrderItemsList(items: order.items),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          OrderSummary(
            subtotal: order.subtotal,
            deliveryFee: order.deliveryFee,
            serviceFee: order.serviceFee,
            total: order.total,
            paymentMethod: order.paymentMethod,
          ),
        ],
      ),
    );
  }
}
