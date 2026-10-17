import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Title + subtitle shown at the top of the Complete Profile screen.
class CompleteProfileHeader extends StatelessWidget {
  const CompleteProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Complete Your Account',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.inriaSerif,
          fontSize: 29.sp,
          fontWeight: FontWeight.w400,
          textColor: AppColors.darkGreen,
        ),
        SizedBox(height: 50.h),
        CustomText(
          text: 'add your details to personalize\nyour experience',
          textAlign: TextAlign.center,
          fontFamily: AppFonts.inriaSerif,
          fontSize: 18.sp,
          textColor: Colors.black87,
          height: 1.3,
        ),
      ],
    );
  }
}
