import 'package:flutter/material.dart';

import '../../domain/models/order_model.dart';
import 'order_customer_card.dart';
import 'order_delivery_card.dart';
import 'order_details_header_card.dart';
import 'order_items_card.dart';

class OrderDetailsPanel extends StatelessWidget {
  const OrderDetailsPanel({
    super.key,
    required this.order,
    this.onStatusChanged,
  });

  final Order order;
  final ValueChanged<OrderStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderDetailsHeaderCard(order: order, onStatusChanged: onStatusChanged),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 560;
            final customer = OrderCustomerCard(order: order);
            final delivery = OrderDeliveryCard(order: order);

            if (stack) {
              return Column(
                children: [customer, const SizedBox(height: 16), delivery],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: customer),
                const SizedBox(width: 16),
                Expanded(child: delivery),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        OrderItemsCard(order: order),
      ],
    );
  }
}
