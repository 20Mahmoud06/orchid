import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AddMessageHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AddMessageHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.r,
      child: Center(
        child: CustomText(
          text: 'Add a message',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}