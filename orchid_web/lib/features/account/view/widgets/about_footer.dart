import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AboutFooter extends StatelessWidget {
  const AboutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the title text and style so we can measure it accurately
    const String titleText = 'More than flowers';
    final TextStyle titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.privacyBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 1. Calculate the exact width of the title text
              final textPainter = TextPainter(
                text: TextSpan(text: titleText, style: titleStyle),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout();

              // Ensure the calculated width doesn't exceed available space
              final titleWidth = textPainter.width.clamp(0.0, constraints.maxWidth);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: titleText,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.thanksYouText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  // 2. Constrain this Row to the exact width of the title
                  SizedBox(
                    width: titleWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dividers take up remaining space
                        Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1.r,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: 'It is a feeling',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.black,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Divider(
                            color: AppColors.thanksYouText,
                            thickness: 1.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppAssets.heartIcon,
                    width: 30.r,
                    height: 30.r,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          right: -8.w,
          top: 35.h,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              AppAssets.bigFlowerSplash,
              width: 80.r,
              height: 80.r,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}