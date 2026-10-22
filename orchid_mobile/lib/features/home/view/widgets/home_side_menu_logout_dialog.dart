import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../auth/cubit/auth_cubit.dart';

void showHomeSideMenuLogoutDialog(BuildContext context) {
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
