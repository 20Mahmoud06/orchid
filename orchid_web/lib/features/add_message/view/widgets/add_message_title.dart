import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AddMessageTitle extends StatelessWidget {
  const AddMessageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomText(
        text: 'would you like to\nadd a message ?',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 22.sp,
        textColor: AppColors.primary,
        textAlign: TextAlign.center,
        height: 1.3,
      ),
    );
  }
}
