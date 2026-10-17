import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class PrivacyInfoCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String body;

  const PrivacyInfoCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconAsset,
            width: 32.r,
            height: 32.r,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.sideBarIcons,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: body,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textPrimary,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
