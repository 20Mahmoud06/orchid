import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class TotalRow extends StatelessWidget {
  final int total;

  const TotalRow({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: 'TOTAL',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          textColor: AppColors.black,
        ),
        CustomText(
          text: '$total EGP',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          textColor: AppColors.black,
        ),
      ],
    );
  }
}