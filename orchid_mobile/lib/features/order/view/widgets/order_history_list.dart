import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../models/customer_order.dart';
import 'order_empty_state.dart';
import 'order_history_card.dart';

/// Filtered, refreshable list of the customer's orders.
class OrderHistoryList extends StatelessWidget {
  const OrderHistoryList({
    super.key,
    required this.selectedTabIndex,
    required this.onOpenDetails,
    required this.onRemove,
  });

  final int selectedTabIndex;
  final ValueChanged<CustomerOrder> onOpenDetails;
  final ValueChanged<CustomerOrder> onRemove;

  List<CustomerOrder> _filterOrders(List<CustomerOrder> orders) {
    switch (selectedTabIndex) {
      case 1:
        return orders.where((o) => o.status == 'PREPARING').toList();
      case 2:
        return orders.where((o) => o.status == 'COMPLETED').toList();
      case 3:
        return orders.where((o) => o.status == 'CANCELED').toList();
      default:
        return orders;
    }
  }

  String get _emptyMessage {
    switch (selectedTabIndex) {
      case 1:
        return 'no preparing orders yet';
      case 2:
        return 'no completed orders yet';
      case 3:
        return 'no canceled orders yet';
      default:
        return 'no orders yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      bloc: OrdersCubit.instance,
      builder: (context, state) {
        final controller = OrdersCubit.instance;
        if (controller.isLoading && !controller.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null && !controller.isLoaded) {
          return CatalogErrorView(
            message: 'Could not load your orders',
            onRetry: () => controller.load(force: true),
          );
        }
        final filtered = _filterOrders(controller.orders);
        if (filtered.isEmpty) {
          return OrderEmptyState(message: _emptyMessage);
        }
        return RefreshIndicator(
          onRefresh: () => controller.load(force: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final order = filtered[index];
              return OrderHistoryCard(
                title: order.title,
                orderId: order.displayCode,
                date: _formatDate(order.createdAt),
                price: order.total,
                status: order.status,
                image: order.coverImageUrl ?? AppAssets.bouquetTest,
                onTap: () => onOpenDetails(order),
                onRemove: () => onRemove(order),
              );
            },
          ),
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

  String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}
