import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Reusable ORCHID brand header widget with pixel-perfect Figma typography and shadows.
class OrchidBrandWidget extends StatelessWidget {
  final double? flowerSize;
  final double? orchidFontSize;
  final double? flowerShopFontSize;
  final double? spacing;
  final bool showShadow;

  const OrchidBrandWidget({
    super.key,
    this.flowerSize,
    this.orchidFontSize,
    this.flowerShopFontSize,
    this.spacing,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final double actualFlowerSize = flowerSize ?? 75.r;
    final double actualOrchidFontSize = orchidFontSize ?? 64.sp;
    final double actualFlowerShopFontSize = flowerShopFontSize ?? 24.sp;
    final double actualSpacing = spacing ?? 4.h;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          height: actualFlowerSize,
          width: actualFlowerSize,
          fit: BoxFit.contain,
        ),
        SizedBox(height: actualSpacing),
        CustomText(
          text: 'ORCHID',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: actualOrchidFontSize,
          fontWeight: FontWeight.w400,
          textColor: AppColors.darkGreen,
          height: 1.0,
          letterSpacing: -0.02 * actualOrchidFontSize,
          shadows: showShadow
              ? [
                  Shadow(
                    offset: Offset(4.w, 4.h),
                    blurRadius: 7.r,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ]
              : null,
        ),
        SizedBox(height: 4.h),
        CustomText(
          text: 'flower shop',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.goudyBookletter,
          fontSize: actualFlowerShopFontSize,
          fontWeight: FontWeight.w400,
          textColor: AppColors.flowerShopGreen,
          height: 1.0,
          letterSpacing: -0.02 * actualFlowerShopFontSize,
          shadows: showShadow
              ? [
                  Shadow(
                    offset: Offset(0, 4.h),
                    blurRadius: 4.r,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ]
              : null,
        ),
      ],
    );
  }
}
