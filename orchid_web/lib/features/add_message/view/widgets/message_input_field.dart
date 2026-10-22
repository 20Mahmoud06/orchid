import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class MessageInputField extends StatelessWidget {
  static const int maxCharacters = 300;

  final TextEditingController controller;
  final int characterCount;
  final ValueChanged<String>? onChanged;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.characterCount,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.h, // Fixed height to match Figma
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.8),
          width: 1.w,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 6, // Fixed number of lines
            minLines: 6, // Same as maxLines
            maxLength: maxCharacters,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [LengthLimitingTextInputFormatter(maxCharacters)],
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 15.sp,
              color: AppColors.black,
              height: 1.5,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 40.h),
              counterText: '',
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CustomText(
                text: '$characterCount \\ $maxCharacters',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 12.sp,
                textColor: AppColors.iconColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
