import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'package:ionicons/ionicons.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../profile/view/widgets/profile_avatar.dart';

class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthFlowState>(
      bloc: AuthCubit.instance,
      builder: (context, state) => _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = AuthCubit.instance;
    final profile = auth.userProfile;
    final displayName =
        (profile?.username?.isNotEmpty ?? false) ? profile!.username! : 'User';
    final imageUrl = auth.getProfileImageUrl(profile?.profileImage);

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90.r,
                      height: 90.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5.w,
                        ),
                      ),
                      child: ClipOval(
                        child: ProfileAvatarImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CustomText(
                      text: 'Hey, 👋',
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 16.sp,
                      textColor: AppColors.darkGreen.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: displayName,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 22.sp,
                      textColor: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _buildMenuItem(
                icon: Icons.history,
                title: 'order history',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.orderHistory);
                },
              ),
              SizedBox(height: 10.h),
              _buildMenuItem(
                imagePath: AppAssets.contactUsIcon,
                title: 'contact us',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.contactUs);
                },
              ),
              SizedBox(height: 10.h),
              _buildMenuItem(
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
                child: Divider(color: AppColors.darkGreen.withValues(alpha: 0.2), thickness: 1.h),
              ),
              SizedBox(height: 8.h),
              _buildMenuItem(
                icon: Ionicons.log_out,
                title: 'log out',
                onTap: () async {
                    _showLogoutDialog(context);
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.background,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: const BoxDecoration(
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 32.r,
                  color: AppColors.darkGreen,
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'Log Out',
                textAlign: TextAlign.center,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                textColor: AppColors.darkGreen,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'are you sure you want to log out?',
                textAlign: TextAlign.center,
                fontSize: 14.sp,
                textColor: AppColors.textPrimary,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                label: 'Log Out',
                height: 48.h,
                borderRadius: BorderRadius.circular(14.r),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await AuthCubit.instance.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                          (route) => false,
                    );
                  }
                },
              ),
              SizedBox(height: 12.h),
              CustomButton(
                label: 'Cancel',
                height: 48.h,
                borderRadius: BorderRadius.circular(14.r),
                backgroundColor: AppColors.textFieldDarkerPink,
                textColor: AppColors.darkGreen,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMenuItem({
    IconData? icon,
    String? imagePath,
    double? imageSize,
    double? iconSize,
    required String title,
    required VoidCallback onTap,
  }) {
    assert(icon != null || imagePath != null,
    'Either icon or imagePath must be provided');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        child: Row(
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: imageSize ?? 24.r,
                height: imageSize ?? 24.r,
                color: AppColors.sideBarIcons,
              )
            else
              Icon(
                icon,
                color: AppColors.sideBarIcons,
                size: iconSize ?? 22.r,
              ),
            SizedBox(width: 14.w),
            CustomText(
              text: title,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 20.sp,
              textColor: AppColors.sideBarIcons,
            ),
          ],
        ),
      ),
    );
  }
}