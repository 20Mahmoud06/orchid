import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final double assetSize;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    this.assetSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(
        label: 'home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      _NavItem(
        label: 'favorites',
        iconAsset: AppAssets.flowerOutlineIcon,
        selectedIconAsset: AppAssets.flowerIcon,
      ),
      _NavItem(
        label: 'cart',
        icon: Ionicons.cart_outline,
        selectedIcon: Ionicons.cart,
      ),
      _NavItem(
        label: 'profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.bottomNavBar,
        border: Border(
          top: BorderSide(
            color: AppColors.cardBorder.withValues(alpha: 0.5),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(navItems.length, (index) {
            final isSelected = index == currentIndex;
            final item = navItems[index];

            return Expanded(
              child: InkWell(
                onTap: () => onItemSelected(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.iconAsset != null)
                      Image.asset(
                        isSelected
                            ? (item.selectedIconAsset ?? item.iconAsset!)
                            : item.iconAsset!,
                        width: (assetSize - 2).r,
                        height: (assetSize - 2).r,
                        color: AppColors.darkGreen,
                        fit: BoxFit.contain,
                      )
                    else
                      Icon(
                        isSelected ? item.selectedIcon! : item.icon!,
                        color: AppColors.darkGreen,
                        size: 24.r,
                      ),
                    SizedBox(height: 2.h),
                    CustomText(
                      text: item.label,
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      textColor: AppColors.darkGreen,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData? icon;
  final IconData? selectedIcon;
  final String? iconAsset;
  final String? selectedIconAsset;

  _NavItem({
    required this.label,
    this.icon,
    this.selectedIcon,
    this.iconAsset,
    this.selectedIconAsset,
  });
}