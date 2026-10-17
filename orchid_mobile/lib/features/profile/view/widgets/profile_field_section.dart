import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Label above a form field, used by the profile forms.
class ProfileFieldSection extends StatelessWidget {
  final String label;
  final Widget child;

  const ProfileFieldSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          textColor: AppColors.black,
        ),
        SizedBox(height: 6.h),
        child,
        SizedBox(height: 14.h),
      ],
    );
  }
}
