import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AccountFooter extends StatelessWidget {
  final String title;
  final String description;

  const AccountFooter({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Define the text style for the title so we can measure it accurately
    final titleStyle = TextStyle(
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.smallFlowerSplash,
            width: 36.r,
            height: 36.r,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 1. Calculate the exact width of the title text
                final textPainter = TextPainter(
                  text: TextSpan(text: title, style: titleStyle),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();

                // Ensure the calculated width doesn't exceed available space
                final titleWidth = textPainter.width.clamp(
                  0.0,
                  constraints.maxWidth,
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: title,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.thanksYouText,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
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
                            text: description,
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
                      width: 24.r,
                      height: 24.r,
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
