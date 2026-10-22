import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../widgets/custom_text.dart';

class FlowerCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const FlowerCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 35.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16.sp,
                          color: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        child: CustomText(
                          text: categories[index],
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16.sp,
                          textColor: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: 2.5.h,
                        width: isSelected
                            ? _getTextWidth(categories[index], context)
                            : 0,
                        decoration: BoxDecoration(
                          color: AppColors.selectedCategory,
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.selectedCategory
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6.r,
                                    spreadRadius: 1.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getTextWidth(String text, BuildContext context) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width + 12.w;
  }
}
