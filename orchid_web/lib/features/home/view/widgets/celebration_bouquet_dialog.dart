import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

class CelebrationBouquetDialog extends StatelessWidget {
  final VoidCallback onBuyExisting;
  final VoidCallback onCreateBouquet;

  const CelebrationBouquetDialog({
    super.key,
    required this.onBuyExisting,
    required this.onCreateBouquet,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: AppColors.textFieldPink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Ionicons.gift_outline,
                size: 32.r,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Your Message Is Ready',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              textColor: AppColors.black,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text:
                  'Choose a bouquet for your celebration. Buy an existing bouquet or create your own.',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              label: 'BUY EXISTING BOUQUET',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColors.black,
              backgroundColor: AppColors.textFieldPink,
              height: 48.h,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [],
              onPressed: onBuyExisting,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              label: 'CREATE MY BOUQUET',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColors.black,
              backgroundColor: AppColors.white,
              height: 48.h,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [],
              onPressed: onCreateBouquet,
            ),
          ],
        ),
      ),
    );
  }
}
