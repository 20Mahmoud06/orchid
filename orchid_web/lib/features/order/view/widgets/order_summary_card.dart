import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

class OrderSummaryCard extends StatelessWidget {
  final String title;
  final String description;
  final int price;
  final String image;

  const OrderSummaryCard({
    super.key,
    this.title = 'Custom Bouquet',
    required this.description,
    required this.price,
    this.image = AppAssets.bouquetTest,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ───────── RIGHT CONTAINER (content, sits behind) ─────────
          Positioned(
            top: 0,
            bottom: 0,
            left: 100.w,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.cardBorder, width: 1.w),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(38.w, 16.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: title,
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.primary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: description,
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 13.sp,
                          textColor: AppColors.black.withValues(alpha: 0.7),
                          height: 1.4,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CustomText(
                        text: '$price EGP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ───────── LEFT CONTAINER (image, sits on top) ─────────
          Positioned(
            top: 0.h,
            left: -1.w,
            bottom: 0.h,
            width: 130.w,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.cardBorder, width: 1.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                child: SkeletonImage(
                  path: image,
                  fit: BoxFit.cover,
                  errorWidget: const SkeletonFallbackBox(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
