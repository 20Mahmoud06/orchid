import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onDecrement,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.remove, size: 16.r, color: AppColors.white),
            ),
          ),
          SizedBox(width: 8.w),
          CustomText(
            text: '$quantity',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            textColor: AppColors.white,
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onIncrement,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.add, size: 16.r, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
