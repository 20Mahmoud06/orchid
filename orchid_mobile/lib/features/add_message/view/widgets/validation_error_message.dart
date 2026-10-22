import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class ValidationErrorMessage extends StatelessWidget {
  final String message;

  const ValidationErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.validationBorder.withValues(alpha: 0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.validationBorder.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Warning icon
          Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              color: AppColors.validationBorder.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.error_outline_rounded,
                size: 16.r,
                color: AppColors.validationBorder,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Message text
          Expanded(
            child: CustomText(
              text: message,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.error,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
