import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.authSection,
        borderRadius: BorderRadius.circular(38.r),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: Offset(0, 1.h),
            blurRadius: 3.r,
            spreadRadius: 1.r,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            offset: Offset(0, 1.h),
            blurRadius: 2.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: child,
          ),
          Positioned(
            bottom: 5.h,
            right: 10.w,
            child: Image.asset(
              AppAssets.circleFlower,
              width: 42.r,
              height: 42.r,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
