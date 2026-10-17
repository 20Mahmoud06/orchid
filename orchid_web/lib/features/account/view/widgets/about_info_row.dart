import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AboutInfoRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const AboutInfoRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 32.r,
            height: 32.r,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomText(
              text: label,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              textColor: AppColors.sideBarIcons,
            ),
          ),
          CustomText(
            text: value,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            textColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
