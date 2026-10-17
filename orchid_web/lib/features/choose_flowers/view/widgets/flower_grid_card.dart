import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/flower_item.dart';

/// Reusable flower card for the 3-column grid on the choose flowers screen.
class FlowerGridCard extends StatelessWidget {
  final FlowerItem flower;
  final bool isFavorite;
  final int quantity;
  final bool showQuantityControl;
  final Color? favoriteHeartColor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FlowerGridCard({
    super.key,
    required this.flower,
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SkeletonImage(
                      path: flower.imagePath,
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: flower.name,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 11.sp,
                  textColor: AppColors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: '${flower.price} EGP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 10.sp,
                        textColor: AppColors.black.withValues(alpha: 0.7),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showQuantityControl) ...[
                      SizedBox(width: 4.w),
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
    if (quantity == 0) {
      return GestureDetector(
        onTap: onIncrement,
        child: Container(
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(
            color: AppColors.incrementButton,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            Icons.add,
            size: 15.r,
            color: AppColors.white,
          ),
        ),
      );
    }

    return Container(
      height: 22.h,
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(11.r),
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
