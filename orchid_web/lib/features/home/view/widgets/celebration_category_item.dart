import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class CelebrationCategoryItem extends StatelessWidget {
  final String name;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CelebrationCategoryItem({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.textFieldPink : Colors.transparent,
            ),
            child: Image.asset(
              icon,
              width: 40.r,
              height: 40.r,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: name,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 12.sp,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}
