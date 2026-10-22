import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class MessageEmptyPlaceholder extends StatelessWidget {
  const MessageEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon with gradient background
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background.withValues(alpha: 0.6),
                    AppColors.background.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  AppAssets.noSpeechBubbleIcon,
                  width: 250.r,
                  height: 250.r,
                  fit: BoxFit.contain,
                  color: AppColors.iconColor.withValues(alpha: 0.35),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Main text
            CustomText(
              text: 'No message added',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 18.sp,
              textColor: AppColors.primary.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 6.h),
            // Subtitle text
            CustomText(
              text: 'You can add it later at any time',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14.sp,
              textColor: AppColors.iconColor.withValues(alpha: 0.4),
              fontWeight: FontWeight.w300,
            ),
          ],
        ),
      ),
    );
  }
}
