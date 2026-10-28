import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../models/customer_order.dart';
import 'order_history_body.dart';

/// Mobile layout of the orders history screen (unchanged presentation),
/// extracted from the screen so the screen only owns state and actions.
class OrderHistoryMobileView extends StatefulWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onBackPressed;
  final VoidCallback onCancelAll;
  final ValueChanged<CustomerOrder> onOpenDetails;
  final ValueChanged<CustomerOrder> onCancelOrder;
  final ValueChanged<CustomerOrder> onResumePayment;

  const OrderHistoryMobileView({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.onBackPressed,
    required this.onCancelAll,
    required this.onOpenDetails,
    required this.onCancelOrder,
    required this.onResumePayment,
  });

  @override
  State<OrderHistoryMobileView> createState() => _OrderHistoryMobileViewState();
}

class _OrderHistoryMobileViewState extends State<OrderHistoryMobileView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int _itemCount = 4;
  static const double _slideDistance = 14;
  static const SlideDirection _direction = SlideDirection.leftToRight;

  static const _tabs = <String>['All', 'Preparing', 'Completed', 'Canceled'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _animFor(int index) {
    final start = (index / _itemCount) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeSlideIn(
              animation: _animFor(0),
              direction: _direction,
              distance: _slideDistance,
              child: BlocBuilder<OrdersCubit, OrdersState>(
                bloc: OrdersCubit.instance,
                builder: (context, state) {
                  final hasOrders = OrdersCubit.instance.orders.isNotEmpty;
                  return CustomAppBar.orchid(
                    title: 'orders history',
                    onBackPressed: widget.onBackPressed,
                    actions: !hasOrders
                        ? null
                        : [
                            AppBarAction(
                              icon: Ionicons.trash,
                              color: AppColors.redText,
                              onPressed: widget.onCancelAll,
                            ),
                          ],
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            FadeSlideIn(
              animation: _animFor(1),
              direction: _direction,
              distance: _slideDistance,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: FlowerCategoryTabs(
                  categories: _tabs,
                  selectedIndex: widget.selectedTabIndex,
                  onCategorySelected: widget.onTabSelected,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: OrderHistoryBody(
                  web: false,
                  selectedTabIndex: widget.selectedTabIndex,
                  onOpenDetails: widget.onOpenDetails,
                  onCancelOrder: widget.onCancelOrder,
                  onResumePayment: widget.onResumePayment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
