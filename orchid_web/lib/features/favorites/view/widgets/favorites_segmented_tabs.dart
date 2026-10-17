import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

enum FavoritesTab { all, bouquets, flowers }

/// Segmented tab bar for the favorites screen matching Figma specs.
class FavoritesSegmentedTabs extends StatelessWidget {
  final FavoritesTab selectedTab;
  final ValueChanged<FavoritesTab> onTabSelected;

  const FavoritesSegmentedTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  static const _tabs = <FavoritesTab, String>{
    FavoritesTab.all: 'All',
    FavoritesTab.bouquets: 'Bouquets',
    FavoritesTab.flowers: 'Flowers',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      child: Row(
        children: FavoritesTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 36.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardBorder : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 20.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  child: Text(
                    _tabs[tab]!,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}