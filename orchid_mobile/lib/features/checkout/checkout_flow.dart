import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_keys.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_routes.dart';
import '../../shared/widgets/custom_text.dart';
import '../order/cubit/orders_cubit.dart';
import '../payment/view/screens/payment_pending_screen.dart';
import 'cubit/checkout_cubit.dart';

/// Submits the pending checkout to Supabase.
///
/// Cash on Delivery keeps the existing spinner + confirmation screen. Card
/// payments create the order first, then hand off to Paymob Unified Checkout
/// and a status screen that waits for the verified webhook. There is no fake
/// success delay on the card path.
Future<void> submitCheckoutAndConfirm(
  BuildContext context, {
  required String paymentMethod,
}) async {
  final messenger = scaffoldMessengerKey.currentState;
  CheckoutCubit.instance.setPaymentMethod(paymentMethod);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final placed = await CheckoutCubit.instance.submitOrder();

    // Keep the history fresh so a new order shows up without a hot reload.
    unawaited(OrdersCubit.instance.load(force: true));

    if (placed.paymentMethod == 'card') {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss the loading dialog
      Navigator.of(context).pushNamed(
        AppRoutes.paymentPending,
        arguments: PaymentPendingArgs(
          orderId: placed.id,
          orderCode: placed.code,
        ),
      );
      return;
    }

    // Cash on Delivery keeps the short progress moment used by the original
    // checkout. Paymob never uses this path.
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss the loading dialog
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.confirm, (_) => false);
  } on CheckoutException catch (error) {
    if (context.mounted) Navigator.of(context).pop();
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: CustomText(text: error.message, textColor: AppColors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (_) {
    if (context.mounted) Navigator.of(context).pop();
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: CustomText(
          text:
              'Could not place your order. Check your connection and try again.',
          textColor: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
