import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Reusable profile info row widget matching Figma layout (Label left, Value right).
class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            textColor: AppColors.black,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: value,
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.black.withValues(alpha: 0.75),
              ),
              if (showArrow) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.r,
                  color: AppColors.darkGreen.withValues(alpha: 0.75),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
