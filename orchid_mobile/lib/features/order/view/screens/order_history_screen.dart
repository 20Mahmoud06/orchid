import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../../../payment/cubit/paymob_payment_cubit.dart';
import '../../../payment/view/screens/payment_pending_screen.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../models/customer_order.dart';
import '../widgets/order_history_dialogs.dart';
import '../widgets/order_history_list.dart';

/// Live history of the signed-in customer's orders.
class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const OrderHistoryScreen({super.key, this.onBackPressed});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;

  late final AnimationController _controller;
  static const int _itemCount = 4;
  static const double _slideDistance = 14;
  static const SlideDirection _direction = SlideDirection.leftToRight;

  static const _tabs = <String>['All', 'Preparing', 'Completed', 'Canceled'];

  @override
  void initState() {
    super.initState();
    // Always refresh on open so a freshly placed order shows up without a hot
    // reload.
    OrdersCubit.instance.load(force: true);
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

  /// Asks for confirmation, then cancels the order (status CANCELED) if active,
  /// or removes it from history if completed.
  Future<void> _confirmCancelOrder(CustomerOrder order) async {
    final isCompleted = order.status.toUpperCase() == 'COMPLETED';
    final confirmed = await showCancelOrderDialog(
      context,
      isCompleted: isCompleted,
    );

    if (confirmed != true || !mounted) return;
    try {
      if (isCompleted) {
        await OrdersCubit.instance.deleteOrder(order);
      } else {
        await OrdersCubit.instance.cancelOrder(order);
      }
    } catch (_) {
      if (!mounted) return;
      final messenger = scaffoldMessengerKey.currentState;
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: CustomText(
            text: isCompleted
                ? 'Could not remove this order'
                : 'Could not cancel this order',
            textColor: AppColors.white,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetails(CustomerOrder order) {
    Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order);
  }

  /// Reopens the card-payment screen for an order that is still payable.
  ///
  /// The screen checks the authoritative payment status first, so an order
  /// whose previous Paymob request is quarantined is shown safely without
  /// starting another chargeable intention.
  void _resumePayment(CustomerOrder order) {
    PaymobPaymentCubit.instance.reset();
    Navigator.pushNamed(
      context,
      AppRoutes.paymentPending,
      arguments: PaymentPendingArgs(
        orderId: order.id,
        orderCode: order.orderCode,
      ),
    );
  }

  Future<void> _confirmCancelAll() async {
    final confirmed = await showCancelAllOrdersDialog(context);

    if (confirmed == true && mounted) {
      try {
        await OrdersCubit.instance.cancelAll();
      } catch (_) {
        if (!mounted) return;
        final messenger = scaffoldMessengerKey.currentState;
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(
          const SnackBar(
            content: CustomText(
              text: 'Could not cancel your orders',
              textColor: AppColors.white,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                              onPressed: _confirmCancelAll,
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
                  selectedIndex: _selectedTabIndex,
                  onCategorySelected: (index) {
                    setState(() => _selectedTabIndex = index);
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: OrderHistoryList(
                  selectedTabIndex: _selectedTabIndex,
                  onOpenDetails: _openDetails,
                  onRemove: _confirmCancelOrder,
                  onResumePayment: _resumePayment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
