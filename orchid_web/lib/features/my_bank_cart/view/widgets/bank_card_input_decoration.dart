import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

/// Shared text style for the bank card form input fields,
/// matching the edit profile screen field typography.
TextStyle get bankCardTextStyle => TextStyle(
  color: AppColors.textFieldText,
  fontSize: 15.sp,
  fontFamily: AppFonts.goudyOldStyle,
);

/// Builds the styled input decoration for the credit card form fields.
/// Uses the same colors as the edit profile screen in both the enabled
/// and disabled states.
InputDecoration bankCardInputDecoration({
  required String label,
  required String hint,
}) {
  OutlineInputBorder buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(
      color: AppColors.darkGreen.withValues(alpha: 0.7),
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      fontFamily: AppFonts.goudyOldStyle,
    ),
    hintStyle: TextStyle(
      color: AppColors.darkGreen.withValues(alpha: 0.45),
      fontSize: 15.sp,
      fontFamily: AppFonts.goudyOldStyle,
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
    border: buildBorder(AppColors.cardBorder, 1),
    enabledBorder: buildBorder(AppColors.cardBorder, 1),
    focusedBorder: buildBorder(AppColors.selectedCategory, 2),
    disabledBorder: buildBorder(
      AppColors.cardBorder.withValues(alpha: 0.45),
      1,
    ),
    errorBorder: buildBorder(AppColors.error, 1),
    focusedErrorBorder: buildBorder(AppColors.error, 2),
  );
}
