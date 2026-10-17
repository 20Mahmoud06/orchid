import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/user/user_profile.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

/// Order confirmation screen shown after a successful checkout.
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late final String _orderCode;
  late final String _username;

  @override
  void initState() {
    super.initState();
    final code = CheckoutCubit.instance.lastOrderCode;
    _orderCode = code == null || code.isEmpty ? '—' : '#$code';
    _username = UserProfile.instance.username;
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainNav, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Ionicons.home,
                      size: 24.r,
                      color: AppColors.black,
                    ),
                    onPressed: _goHome,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      SkeletonImage(
                        path: AppAssets.completed,
                        width: 250.w,
                        fit: BoxFit.contain,
                        placeholderSize: Size(250.w, 250.h),
                        errorWidget: const SkeletonFallbackBox(),
                      ),
                      SizedBox(height: 24.h),
                      CustomText(
                        text: 'ORDER CONFIRMED !',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primary,
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Thank you, $_username !',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: 'your bouquet has been confirmed successfully',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        textColor: AppColors.black.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          children: [
                            CustomText(
                              text: 'ORDER CODE',
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 16.sp,
                              textColor: AppColors.black.withValues(alpha: 0.6),
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              text: _orderCode,
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              textColor: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28.h),
                      CustomText(
                        text:
                            'You Will Receive a WhatsApp\nMessage When Your Order is on\nits way',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 22.sp,
                        textColor: AppColors.primary,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      CustomText(
                        text: 'Thank you for choosing ORCHID',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.thanksText,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
