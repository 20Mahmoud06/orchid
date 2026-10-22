import 'package:flutter/material.dart';

import '../../models/customer_order.dart';
import '../widgets/order_details_mobile_view.dart';
import '../widgets/web/order_details_web_view.dart';

/// Full details of one placed order: items, delivery info, fees and status.
class OrderDetailsScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final placedOn = _formatDate(order.createdAt);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return OrderDetailsWebView(order: order, placedOn: placedOn);
        }
        return OrderDetailsMobileView(
          order: order,
          placedOn: placedOn,
          onBackPressed: () => Navigator.maybePop(context),
        );
      },
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) {
    final hour = date.toLocal().hour > 12
        ? date.toLocal().hour - 12
        : date.toLocal().hour;
    final minute = date.toLocal().minute.toString().padLeft(2, '0');
    final period = date.toLocal().hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${_months[date.month - 1]} ${date.year}, '
        '$hour:$minute $period';
  }
}
