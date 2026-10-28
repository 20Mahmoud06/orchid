import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/payment/cubit/paymob_payment_state.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.state,
    required this.orderCode,
    required this.starting,
    required this.timedOut,
  });

  final PaymobPaymentState state;
  final String orderCode;
  final bool starting;
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final quarantined = state.snapshot?.isQuarantined == true;
    final reviewing = state.snapshot?.needsReview == true;
    final failed = !quarantined && (state.isFailed || state.isError);
    final confirmed = state.isConfirmed;

    final icon = confirmed
        ? Ionicons.checkmark_circle_outline
        : failed
        ? Ionicons.close_circle_outline
        : (reviewing || quarantined)
        ? Ionicons.alert_circle_outline
        : Ionicons.time_outline;

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
        ? 'This is taking longer than usual. You can keep this screen open, '
              'tap "Check again" later, or return home. Your order will update '
              'automatically when Paymob confirms the payment.'
        : 'Paymob is confirming your card payment. This usually takes only a '
              'few seconds. You can safely close the payment page and return '
              'here; we only mark the order paid after the backend receives '
              'Paymob\'s verified webhook.';

    final amount = state.snapshot?.amountCents ?? state.checkout?.amountCents;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.incrementButton, width: 1.w),
      ),
      child: Column(
        children: [
          if (starting ||
              (!failed && !confirmed && !reviewing && !quarantined))
            SizedBox(
              width: 54.r,
              height: 54.r,
              child: const CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.r, color: AppColors.black),
            ),
          SizedBox(height: 18.h),
          CustomText(
            text: title,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
            textAlign: TextAlign.center,
          ),
          if (orderCode.isNotEmpty) ...[
            SizedBox(height: 8.h),
            CustomText(
              text: 'Order $orderCode',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primary,
              textAlign: TextAlign.center,
            ),
          ],
          if (amount != null && amount > 0) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: 'EGP ${(amount / 100).toStringAsFixed(2)}',
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 14.h),
          CustomText(
            text: description,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14.sp,
            height: 1.5,
            textColor: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          if (state.message != null &&
              !failed &&
              state.message!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            CustomText(
              text: state.message!,
              fontFamily: AppFonts.inriaSerif,
              fontSize: 13.sp,
              textColor: AppColors.error,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
