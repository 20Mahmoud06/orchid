import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

class BankCardConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const BankCardConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: const BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.card_outline,
                size: 30.r,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 14.h),
            CustomText(
              text: 'Confirm Card Payment',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              textColor: AppColors.black,
            ),
            SizedBox(height: 10.h),
            CustomText(
              text:
                  'You will be charged on the provided credit card upon delivery. Do you want to confirm this order?',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'CANCEL',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.black,
                    backgroundColor: AppColors.white,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: onCancel,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    label: 'CONFIRM',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.black,
                    backgroundColor: AppColors.textFieldPink,
                    height: 48.h,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [],
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
