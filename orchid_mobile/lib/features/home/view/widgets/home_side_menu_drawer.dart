import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import 'home_side_menu_header.dart';
import 'home_side_menu_item.dart';
import 'home_side_menu_logout_dialog.dart';

class HomeSideMenuDrawer extends StatelessWidget {
  const HomeSideMenuDrawer({
    super.key,
    required this.displayName,
    required this.imageUrl,
  });

  final String displayName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300.w,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.buttonPink,
            ],
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSideMenuHeader(
                imageUrl: imageUrl,
                displayName: displayName,
              ),
              SizedBox(height: 16.h),
              HomeSideMenuItem(
                icon: Icons.history,
                title: 'order history',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.orderHistory);
                },
              ),
              SizedBox(height: 10.h),
              HomeSideMenuItem(
                imagePath: AppAssets.contactUsIcon,
                title: 'contact us',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.contactUs);
                },
              ),
              SizedBox(height: 10.h),
              HomeSideMenuItem(
                imagePath: AppAssets.inspirationIcon,
                imageSize: 26.r,
                title: 'inspiration',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.inspiration);
                },
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Divider(
                  color: AppColors.darkGreen.withValues(alpha: 0.2),
                  thickness: 1.h,
                ),
              ),
              SizedBox(height: 8.h),
              HomeSideMenuItem(
                icon: Ionicons.log_out,
                title: 'log out',
                onTap: () async {
                  showHomeSideMenuLogoutDialog(context);
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
