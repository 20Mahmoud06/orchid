import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

class BuildBouquetBanner extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const BuildBouquetBanner({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.fieldPink,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: SkeletonImage(
                  path: imagePath,
                  fit: BoxFit.cover,
                  placeholderColor: AppColors.fieldPink,
                  errorWidget: const SkeletonFallbackBox(
                    color: AppColors.fieldPink,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        textAlign: TextAlign.center,
                        text: 'Build your own\nbouquet',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primary,
                        height: 1.1.h,
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: 200.w,
                        child: CustomText(
                          textAlign: TextAlign.center,
                          text: 'choose your flowers and\ncreate your perfect bouquet.',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16.sp,
                          textColor: AppColors.black,
                          height: 1.2.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 30.w,
                bottom: 18.h,

                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 150.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.buttonPinkLight,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Center(
                      child: CustomText(
                        text: 'start now >',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        textColor: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}