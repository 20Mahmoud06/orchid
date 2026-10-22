import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class TermsHeaderCard extends StatelessWidget {
  const TermsHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          CustomText(
            text: 'Terms & Conditions',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.darkGreen,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          CustomText(
            text:
                'By using our app, you agree to the\nfollowing terms and conditions.',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            textColor: AppColors.darkGreen,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
