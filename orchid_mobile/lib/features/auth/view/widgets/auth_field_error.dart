import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text.dart';

class AuthFieldError extends StatelessWidget {
  final String message;

  const AuthFieldError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: CustomText(
        text: message,
        fontSize: 13.sp,
        textColor: AppColors.error,
      ),
    );
  }
}
