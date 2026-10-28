import 'dart:async';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/payment/cubit/paymob_payment_state.dart';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/payment_pending_actions.dart';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/payment_pending_args.dart';
import 'package:ORCHID/features/payment/view/widgets/payment_pending/pending_panel.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

class PendingPanel extends StatelessWidget {
  const PendingPanel({
    super.key,
    required this.state,
    required this.orderCode,
    required this.starting,
    required this.timedOut,
    required this.wide,
  });

  final PaymobPaymentState state;
  final String orderCode;
  final bool starting;
  final bool timedOut;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final reviewing = state.snapshot?.needsReview == true;
    final quarantined = state.snapshot?.isQuarantined == true;
    final failed = !quarantined && (state.isFailed || state.isError);
    final confirmed = state.isConfirmed;
    final showSpinner =
        starting || (!failed && !confirmed && !reviewing && !quarantined);

    final icon = confirmed
        ? Ionicons.checkmark_circle_outline
        : (reviewing || quarantined)
        ? Ionicons.alert_circle_outline
        : Ionicons.close_circle_outline;

    final title = confirmed
        ? 'Payment confirmed'
        : reviewing
        ? 'Payment needs review'
        : quarantined
        ? 'Confirming payment status'
        : failed
        ? 'Payment not completed'
        : starting
        ? 'Starting secure payment'
        : 'Confirming your payment';

    final description = reviewing
        ? 'Paymob reported a payment that needs a manual review. '
              'Please contact Orchid support with your order code.'
        : quarantined
        ? 'Paymob has not confirmed whether this payment started. To avoid '
              'charging you twice, this order is paused until the status is '
              'verified. Check again in a few minutes: a completed payment '
              'will update automatically. If you were charged, contact Orchid '
              'support with your order code.'
        : failed
        ? (state.message ??
              'The card payment was not completed. You can try again.')
        : timedOut
        ? 'This is taking longer than usual. Keep this page open, or check '
              'again later. Your order will update automatically when Paymob '
              'confirms the payment.'
        : 'Paymob is confirming your card payment. This usually takes only a '
              'few seconds. We only mark the order paid after the backend '
              'receives Paymob\'s verified webhook.';

    final amount = state.snapshot?.amountCents ?? state.checkout?.amountCents;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 22.w,
        vertical: wide ? 40 : 28.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(wide ? 20 : 20.r),
        border: Border.all(color: AppColors.incrementButton, width: 1),
      ),
      child: Column(
        children: [
          if (showSpinner)
            SizedBox(
              width: wide ? 54 : 54.r,
              height: wide ? 54 : 54.r,
              child: const CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Container(
              width: wide ? 64 : 64.r,
              height: wide ? 64 : 64.r,
              decoration: const BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: wide ? 32 : 32.r, color: AppColors.black),
            ),
          SizedBox(height: wide ? 18 : 18.h),
          CustomText(
            text: title,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: wide ? 24 : 22.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
            textAlign: TextAlign.center,
          ),
          if (orderCode.isNotEmpty) ...[
            SizedBox(height: wide ? 8 : 8.h),
            CustomText(
              text: 'Order $orderCode',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: wide ? 16 : 16.sp,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primary,
              textAlign: TextAlign.center,
            ),
          ],
          if (amount != null && amount > 0) ...[
            SizedBox(height: wide ? 4 : 4.h),
            CustomText(
              text: 'EGP ${(amount / 100).toStringAsFixed(2)}',
              fontFamily: AppFonts.inriaSerif,
              fontSize: wide ? 14 : 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: wide ? 14 : 14.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 600 : double.infinity),
            child: CustomText(
              text: description,
              fontFamily: AppFonts.inriaSerif,
              fontSize: wide ? 15 : 14.sp,
              height: 1.5,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ),
          if (state.message != null &&
              !failed &&
              state.message!.trim().isNotEmpty) ...[
            SizedBox(height: wide ? 12 : 12.h),
            CustomText(
              text: state.message!,
              fontFamily: AppFonts.inriaSerif,
              fontSize: wide ? 13 : 13.sp,
              textColor: AppColors.error,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
