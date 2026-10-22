import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Empty-state illustration and CTA shown when the cart has no items.
class CartEmptyState extends StatelessWidget {
  final VoidCallback onChooseItems;

  const CartEmptyState({super.key, required this.onChooseItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              color: AppColors.fieldPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.cart_outline,
              size: 64.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          CustomText(
            text: 'Your cart is empty',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Start adding your favorite items!',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16.sp,
            textColor: AppColors.textSecondary,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            label: 'CHOOSE BOUQUET',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
            backgroundColor: AppColors.textFieldPink,
            height: 52.h,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [],
            onPressed: onChooseItems,
          ),
        ],
      ),
    );
  }
}
