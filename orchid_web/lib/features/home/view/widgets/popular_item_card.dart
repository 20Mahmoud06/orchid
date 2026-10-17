import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

class PopularItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const PopularItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130.w,
        margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
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
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: SkeletonImage(
                  path: imageUrl,
                  fit: BoxFit.cover,
                  placeholderColor: AppColors.fieldPink,
                  errorWidget: const SkeletonFallbackBox(
                    color: AppColors.fieldPink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: title,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 12.sp,
                            textColor: AppColors.black,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          CustomText(
                            text: price,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 10.sp,
                            textColor: AppColors.black.withValues(alpha: 0.7),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                        size: 16.r,
                        color: isFavorite ? Colors.red : AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}