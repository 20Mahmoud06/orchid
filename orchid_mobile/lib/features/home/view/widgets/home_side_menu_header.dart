import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../profile/view/widgets/profile_avatar.dart';

class HomeSideMenuHeader extends StatelessWidget {
  const HomeSideMenuHeader({
    super.key,
    required this.imageUrl,
    required this.displayName,
  });

  final String? imageUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1.5.w,
              ),
            ),
            child: ClipOval(
              child: ProfileAvatarImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Hey, 👋',
            fontFamily: AppFonts.inriaSerif,
            fontSize: 16.sp,
            textColor: AppColors.darkGreen.withValues(alpha: 0.7),
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: displayName,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 22.sp,
            textColor: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
