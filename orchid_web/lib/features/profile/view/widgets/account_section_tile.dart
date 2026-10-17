import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Reusable tile component for Account list section items in Profile screen.
class AccountSectionTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;

  const AccountSectionTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: Center(child: icon),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CustomText(
                    text: title,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.black,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.r,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: AppColors.cardBorder.withValues(alpha: 0.7),
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}