import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/bouquet_item.dart';

/// Reusable bouquet card for the 3-column grid on the choose bouquets screen.
class BouquetGridCard extends StatelessWidget {
  final BouquetItem bouquet;
  final bool isFavorite;
  final int quantity;
  final bool showQuantityControl;
  final Color? favoriteHeartColor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const BouquetGridCard({
    super.key,
    required this.bouquet,
    required this.isFavorite,
    required this.quantity,
    this.showQuantityControl = true,
    this.favoriteHeartColor,
    required this.onFavoriteToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SkeletonImage(
                path: bouquet.imagePath,
                fit: BoxFit.cover,
                placeholderColor: AppColors.fieldPink,
                errorWidget: const SkeletonFallbackBox(
                  color: AppColors.fieldPink,
                ),
              ),
            ),
          ),

          Positioned(
            top: 6.h,
            left: 6.w,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                size: 16.r,
                color: isFavorite
                    ? (favoriteHeartColor ?? AppColors.redText)
                    : AppColors.black,
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: -15.h,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: bouquet.name,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 12.sp,
                    textColor: AppColors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: '${bouquet.price} EGP',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 12.sp,
                          textColor: AppColors.black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showQuantityControl) ...[
                        SizedBox(width: 6.w),
                        _QuantityControl(
                          quantity: quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // The pink circular + button
    if (quantity == 0) {
      return GestureDetector(
        onTap: onIncrement,
        child: Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color: AppColors.incrementButton,
            borderRadius: BorderRadius.circular(50.r), // Perfect circle
          ),
          child: Icon(
            Icons.add,
            size: 18.r,
            color: AppColors.white,
          ),
        ),
      );
    }

    // Quantity control
    return Container(
      height: 22.h,
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onDecrement,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Icon(
                Icons.remove,
                size: 12.r,
                color: AppColors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: CustomText(
              text: '$quantity',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 10.sp,
              textColor: AppColors.white,
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Icon(
                Icons.add,
                size: 12.r,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}