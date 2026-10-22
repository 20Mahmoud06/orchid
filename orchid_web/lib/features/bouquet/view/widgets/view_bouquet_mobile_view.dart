import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

/// Mobile layout of the view-bouquet screen (unchanged presentation).
class ViewBouquetMobileView extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> description;
  final bool showTwoButtons;
  final VoidCallback? onBackPressed;
  final VoidCallback onEditBouquet;
  final VoidCallback onLooksGood;

  const ViewBouquetMobileView({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.showTwoButtons,
    required this.onBackPressed,
    required this.onEditBouquet,
    required this.onLooksGood,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(title: title, onBackPressed: onBackPressed),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SkeletonImage(
                        path: imagePath,
                        width: 280.w,
                        fit: BoxFit.contain,
                        placeholderSize: Size(280.w, 280.h),
                        errorWidget: const SkeletonFallbackBox(
                          color: AppColors.fieldPink,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (description.isNotEmpty)
                        Column(
                          children: description
                              .map(
                                (line) => CustomText(
                                  text: line,
                                  fontFamily: AppFonts.goudyOldStyle,
                                  fontSize: 24.sp,
                                  textColor: AppColors.textPrimary,
                                  textAlign: TextAlign.center,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              if (showTwoButtons) ...[
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'Edit Bouquet',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.incrementButton,
                    width: 1.w,
                  ),
                  boxShadow: const [],
                  onPressed: onEditBouquet,
                ),
                SizedBox(height: 12.h),
              ],
              CustomButton(
                label: 'Looks Good',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
                backgroundColor: AppColors.incrementButton,
                height: 60.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: onLooksGood,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
