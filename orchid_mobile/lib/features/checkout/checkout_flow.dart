import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_keys.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_routes.dart';
import '../../shared/widgets/custom_text.dart';
import '../order/cubit/orders_cubit.dart';
import 'cubit/checkout_cubit.dart';

/// Submits the pending checkout to Supabase and, on success, lands on the
/// confirm screen. Shows a loading spinner while inserting and a snackbar
/// with a readable message on failure.
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
    await CheckoutCubit.instance.submitOrder();

    // Keep the history fresh so a new order shows up without a hot reload.
    unawaited(OrdersCubit.instance.load(force: true));

    // Let the progress spinner linger so the payment feels like real work.
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss the loading dialog
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.confirm,
      (_) => false,
    );
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
