import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class SummaryItem extends StatelessWidget {
  final Widget? leading;
  final String? iconPath;
  final double? iconSize;
  final String title;
  final String? subtitle;
  final String trailing;

  const SummaryItem({
    super.key,
    this.leading,
    this.iconPath,
    this.iconSize,
    required this.title,
    this.subtitle,
    required this.trailing,
  }) : assert(
         leading != null || iconPath != null,
         'Either leading or iconPath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final double size = iconSize ?? 24.r;

    final double titleLineHeight = 20.sp * 1.45;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon aligned with the title's vertical center
          SizedBox(
            height: titleLineHeight,
            child: Center(
              child: leading != null
                  ? leading!
                  : Image.asset(
                      iconPath!,
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  CustomText(
                    text: subtitle!,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
                    textColor: AppColors.black.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          CustomText(
            text: trailing,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}
