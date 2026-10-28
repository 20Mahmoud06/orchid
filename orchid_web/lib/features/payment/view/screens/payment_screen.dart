import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../models/payment_method.dart';
import '../widgets/cash_confirmation_dialog.dart';
import '../widgets/payment_mobile_view.dart';
import '../widgets/web/payment_web_view.dart';
import '../widgets/web/web_payment_widgets.dart';

/// Payment screen matching the Orchid Figma design.
class PaymentScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const PaymentScreen({super.key, this.onBackPressed});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selected = PaymentMethod.cash;

  Future<void> _onConfirm() async {
    switch (_selected) {
      case PaymentMethod.cash:
        await _showCashConfirmationDialog(context);
        break;
      case PaymentMethod.card:
        // Paymob Unified Checkout collects the card data on Paymob's page.
        // The app never handles or stores raw card details.
        await submitCheckoutAndConfirm(context, paymentMethod: 'card');
        break;
      case PaymentMethod.wallet:
        Navigator.pushNamed(context, AppRoutes.myWallet);
        break;
    }
  }

  Future<void> _showCashConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        // The web build pins `MediaQuery.size` to the phone design size, so the
        // desktop decision has to read the real viewport. Mobile is unchanged.
        if (isWideViewport(ctx)) {
          return WebCashConfirmationDialog(
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () {
              Navigator.of(ctx).pop();
              submitCheckoutAndConfirm(context, paymentMethod: 'cash');
            },
          );
        }
        return CashConfirmationDialog(
          onCancel: () => Navigator.of(ctx).pop(),
          onConfirm: () {
            Navigator.of(ctx).pop();
            submitCheckoutAndConfirm(context, paymentMethod: 'cash');
          },
        );
      },
    );
  }

  void _selectMethod(PaymentMethod method) {
    setState(() => _selected = method);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return PaymentWebView(
            selected: _selected,
            onMethodSelected: _selectMethod,
            onConfirm: _onConfirm,
            onBackPressed: widget.onBackPressed,
          );
        }
        return PaymentMobileView(
          selected: _selected,
          onMethodSelected: _selectMethod,
          onConfirm: _onConfirm,
          onBackPressed: widget.onBackPressed,
        );
      },
    );
  }
}
