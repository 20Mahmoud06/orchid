import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class BankCardHeader extends StatelessWidget {
  const BankCardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Add your bank card',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 23.sp,
          fontWeight: FontWeight.w800,
          textColor: AppColors.darkGreen,
        ),
        SizedBox(height: 6.h),
        CustomText(
          text: 'Securely save a card for faster payments.',
          fontFamily: AppFonts.inriaSerif,
          fontSize: 14.sp,
          textColor: AppColors.textPrimary,
        ),
      ],
    );
  }
}