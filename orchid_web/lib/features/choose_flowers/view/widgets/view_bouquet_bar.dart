import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Floating bottom bar showing bouquet count and total price.
class ViewBouquetBar extends StatelessWidget {
  final int totalCount;
  final int totalPrice;
  final VoidCallback? onTap;
  final bool isSingleFlower;

  const ViewBouquetBar({
    super.key,
    required this.totalCount,
    required this.totalPrice,
    this.onTap,
    this.isSingleFlower = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.incrementButton,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.designFieldPink.withValues(alpha: 0.4),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text:
                  '${isSingleFlower ? 'view flower' : 'view bouquet'} '
                  '($totalCount) >',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              textColor: AppColors.viewBouquetButton,
            ),
            CustomText(
              text: '$totalPrice EGP',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 22.sp,
              textColor: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}
