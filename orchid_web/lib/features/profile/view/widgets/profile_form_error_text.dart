import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Red inline validation/error message shown under profile form fields.
class ProfileFormErrorText extends StatelessWidget {
  final String message;
  final double topSpacing;

  const ProfileFormErrorText({
    super.key,
    required this.message,
    this.topSpacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing.h, left: 4.w),
      child: CustomText(
        text: message,
        fontSize: 13.sp,
        textColor: AppColors.error,
      ),
    );
  }
}
