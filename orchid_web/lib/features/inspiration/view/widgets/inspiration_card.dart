import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

class InspirationCard extends StatelessWidget {
  final String username;
  final String imagePath;
  final List<String> ingredients;
  final VoidCallback onChoose;

  const InspirationCard({
    super.key,
    required this.username,
    required this.imagePath,
    required this.ingredients,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.w,
                ),
              ),
            ),
          ),

          Positioned(
            top: 0.h,
            left: -1.w,
            bottom: 0.h,
            width: 130.w,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.w,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13.r),
                  bottomLeft: Radius.circular(13.r),
                ),
                child: SkeletonImage(
                  path: imagePath,
                  fit: BoxFit.contain,
                  errorWidget: const SkeletonFallbackBox(),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            bottom: 0,
            left: 130.w,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Username Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.r,
                        backgroundImage: const AssetImage(AppAssets.placeholderProfile),
                        backgroundColor: AppColors.fieldPink,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomText(
                          text: 'created by @$username',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.darkGreen,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // 2. Ingredients List with Left Indentation
                  Padding(
                    // This aligns the text with the username text,
                    // matching the Figma layout.
                    padding: EdgeInsets.only(left: 28.w), // 20 (avatar diameter) + 8 (gap)
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      separatorBuilder: (context, _) => SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        return CustomText(
                          text: ingredients[index],
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 13.sp,
                          textColor: AppColors.textPrimary,
                        );
                      },
                    ),
                  ),

                  Spacer(),

                  // 4. Button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onChoose,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: CustomText(
                            text: 'choose this bouquet >',
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
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
