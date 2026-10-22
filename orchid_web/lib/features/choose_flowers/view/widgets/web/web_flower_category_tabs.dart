import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop category tab strip mirroring the mobile `FlowerCategoryTabs`.
class WebFlowerCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const WebFlowerCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 35),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = categories[index];
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
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        child: CustomText(
                          text: label,
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16,
                          textColor: isSelected
                              ? AppColors.selectedCategory
                              : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: 2.5,
                        width: isSelected ? _textWidth(label) : 0,
                        decoration: BoxDecoration(
                          color: AppColors.selectedCategory,
                          borderRadius: BorderRadius.circular(2),
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

  double _textWidth(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width + 12;
  }
}
