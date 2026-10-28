import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/choose_flowers/view/widgets/web/web_choose_flowers_widgets.dart';
import '../../../cubit/orders_cubit.dart';
import '../../../cubit/orders_state.dart';
import '../../../models/customer_order.dart';
import '../order_history_body.dart';
import 'web_order_history_header.dart';

/// Desktop-first orders history page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — the title with the cancel-all action on
/// top, then the status tabs and the order cards centered in a readable
/// column.
class OrderHistoryWebView extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCancelAll;
  final ValueChanged<CustomerOrder> onOpenDetails;
  final ValueChanged<CustomerOrder> onCancelOrder;
  final ValueChanged<CustomerOrder> onResumePayment;

  const OrderHistoryWebView({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.onCancelAll,
    required this.onOpenDetails,
    required this.onCancelOrder,
    required this.onResumePayment,
  });

  static const _tabs = <String>['All', 'Preparing', 'Completed', 'Canceled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<OrdersCubit, OrdersState>(
                    bloc: OrdersCubit.instance,
                    builder: (context, state) {
                      final hasOrders = OrdersCubit.instance.orders.isNotEmpty;
                      return WebOrderHistoryHeader(
                        showCancelAll: hasOrders,
                        onCancelAll: onCancelAll,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WebFlowerCategoryTabs(
                              categories: _tabs,
                              selectedIndex: selectedTabIndex,
                              onCategorySelected: onTabSelected,
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: OrderHistoryBody(
                                web: true,
                                selectedTabIndex: selectedTabIndex,
                                onOpenDetails: onOpenDetails,
                                onCancelOrder: onCancelOrder,
                                onResumePayment: onResumePayment,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
