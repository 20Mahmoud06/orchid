import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class CelebrationMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const CelebrationMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: controller,
            hint: 'Type your message...',
            containerColor: AppColors.white,
            fillColor: AppColors.white,
            boxShadow: const [],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            borderRadius: 16.r,
          ),
        ),
        SizedBox(width: 8.w),
        CustomButton(
          label: 'Send',
          width: 80.w,
          height: 48.h,
          backgroundColor: AppColors.textFieldDarkerPink,
          textColor: AppColors.darkGreen,
          fontSize: 14.sp,
          boxShadow: const [],
          onPressed: onSend,
        ),
      ],
    );
  }
}
