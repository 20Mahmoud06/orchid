import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/payment/cubit/paymob_payment_state.dart';
import 'package:ORCHID/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentPendingActions extends StatelessWidget {
  const PaymentPendingActions({
    super.key,
    required this.state,
    required this.wide,
    required this.starting,
    required this.onCheckNow,
    required this.onStart,
    required this.onReopen,
    required this.onLeave,
  });

  final PaymobPaymentState state;
  final bool wide;
  final bool starting;
  final VoidCallback onCheckNow;
  final VoidCallback onStart;
  final VoidCallback onReopen;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    if (state.phase == PaymobPaymentPhase.creating || starting) {
      return const SizedBox.shrink();
    }

    final quarantined = state.snapshot?.isQuarantined == true;
    final reviewing = state.snapshot?.needsReview == true;
    if (quarantined || reviewing) {
      final stopButtons = <Widget>[
        CustomButton(
          label: 'CHECK AGAIN',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: wide ? 16 : 18.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.textFieldPink,
          height: wide ? 50 : 52.h,
          borderRadius: BorderRadius.circular(wide ? 14 : 16.r),
          boxShadow: const [],
          onPressed: onCheckNow,
        ),
        CustomButton(
          label: 'BACK TO HOME',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: wide ? 15 : 16.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.white,
          height: wide ? 50 : 48.h,
          borderRadius: BorderRadius.circular(wide ? 14 : 14.r),
          boxShadow: const [],
          onPressed: onLeave,
        ),
      ];

      if (wide) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 12,
          children: [
            for (final button in stopButtons)
              SizedBox(width: 220, child: button),
          ],
        );
      }

      return Column(
        children: [
          for (var index = 0; index < stopButtons.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            stopButtons[index],
          ],
        ],
      );
    }

    final retry =
        state.phase == PaymobPaymentPhase.error ||
        state.phase == PaymobPaymentPhase.failed;

    final buttons = <Widget>[
      CustomButton(
        label: retry ? 'TRY AGAIN' : 'CHECK AGAIN',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: wide ? 16 : 18.sp,
        fontWeight: FontWeight.bold,
        textColor: AppColors.black,
        backgroundColor: AppColors.textFieldPink,
        height: wide ? 50 : 52.h,
        borderRadius: BorderRadius.circular(wide ? 14 : 16.r),
        boxShadow: const [],
        onPressed: retry ? onStart : onCheckNow,
      ),
      if (!retry)
        CustomButton(
          label: 'REOPEN PAYMENT PAGE',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: wide ? 15 : 16.sp,
          fontWeight: FontWeight.bold,
          textColor: AppColors.black,
          backgroundColor: AppColors.white,
          height: wide ? 50 : 48.h,
          borderRadius: BorderRadius.circular(wide ? 14 : 14.r),
          boxShadow: const [],
          onPressed: onReopen,
        ),
      CustomButton(
        label: 'BACK TO HOME',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: wide ? 15 : 16.sp,
        fontWeight: FontWeight.bold,
        textColor: AppColors.black,
        backgroundColor: AppColors.white,
        height: wide ? 50 : 48.h,
        borderRadius: BorderRadius.circular(wide ? 14 : 14.r),
        boxShadow: const [],
        onPressed: onLeave,
      ),
    ];

    if (wide) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 12,
        children: [
          for (final button in buttons) SizedBox(width: 220, child: button),
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < buttons.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          buttons[index],
        ],
      ],
    );
  }
}
