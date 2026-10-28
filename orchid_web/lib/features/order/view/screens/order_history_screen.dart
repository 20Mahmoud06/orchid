import 'package:ORCHID/features/payment/view/widgets/payment_pending/payment_pending_args.dart';
import 'package:flutter/material.dart';
import '../../../../core/app_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../payment/cubit/paymob_payment_cubit.dart';
import '../../../payment/view/screens/payment_pending_screen.dart';
import '../../cubit/orders_cubit.dart';
import '../../models/customer_order.dart';
import '../widgets/order_history_dialogs.dart';
import '../widgets/order_history_mobile_view.dart';
import '../widgets/web/web_order_history_view.dart';

/// Live history of the signed-in customer's orders.
///
/// The mobile and desktop layouts live in separate widget files; this screen
/// owns the tab state, the order actions and the cancel confirmations.
class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const OrderHistoryScreen({super.key, this.onBackPressed});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Always refresh on open so a freshly placed order shows up without a hot
    // reload.
    OrdersCubit.instance.load(force: true);
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
      if (messenger == null) return;
      showAppSnackBarWith(
        messenger,
        isCompleted
            ? 'Could not remove this order'
            : 'Could not cancel this order',
        isError: true,
      );
    }
  }

  void _openDetails(CustomerOrder order) {
    Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order);
  }

  /// Reopens the card-payment page for an order that is still payable.
  ///
  /// The payment page reconciles the authoritative status before starting
  /// anything, so a quarantined Paymob outcome is never charged again.
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
        if (messenger == null) return;
        showAppSnackBarWith(
          messenger,
          'Could not cancel your orders',
          isError: true,
        );
      }
    }
  }

  void _selectTab(int index) {
    setState(() => _selectedTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return OrderHistoryWebView(
            selectedTabIndex: _selectedTabIndex,
            onTabSelected: _selectTab,
            onCancelAll: _confirmCancelAll,
            onOpenDetails: _openDetails,
            onCancelOrder: _confirmCancelOrder,
            onResumePayment: _resumePayment,
          );
        }
        return OrderHistoryMobileView(
          selectedTabIndex: _selectedTabIndex,
          onTabSelected: _selectTab,
          onBackPressed: widget.onBackPressed,
          onCancelAll: _confirmCancelAll,
          onOpenDetails: _openDetails,
          onCancelOrder: _confirmCancelOrder,
          onResumePayment: _resumePayment,
        );
      },
    );
  }
}
