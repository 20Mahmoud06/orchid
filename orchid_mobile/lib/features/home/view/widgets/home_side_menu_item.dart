import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class HomeSideMenuItem extends StatelessWidget {
  const HomeSideMenuItem({
    super.key,
    this.icon,
    this.imagePath,
    this.imageSize,
    this.iconSize,
    required this.title,
    required this.onTap,
  });

  final IconData? icon;
  final String? imagePath;
  final double? imageSize;
  final double? iconSize;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    assert(
      icon != null || imagePath != null,
      'Either icon or imagePath must be provided',
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: imageSize ?? 24.r,
                height: imageSize ?? 24.r,
                color: AppColors.sideBarIcons,
              )
            else
              Icon(
                icon,
                color: AppColors.sideBarIcons,
                size: iconSize ?? 22.r,
              ),
            SizedBox(width: 14.w),
            CustomText(
              text: title,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              textColor: AppColors.sideBarIcons,
            ),
          ],
        ),
      ),
    );
  }
}
