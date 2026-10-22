import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';

/// Mobile layout of the sign-up screen (unchanged presentation).
class SignUpMobileView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final VoidCallback onSignUp;
  final VoidCallback? onNavigateToLogin;

  const SignUpMobileView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.generalError,
    required this.onSignUp,
    required this.onNavigateToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      children: [
        Center(
          child: CustomText(
            text: 'Create your account',
            textAlign: TextAlign.center,
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
            textColor: AppColors.darkGreen,
          ),
        ),
        SizedBox(height: 6.h),
        Center(
          child: CustomText(
            text: "let's get you started with your\nORCHID account",
            textAlign: TextAlign.center,
            fontSize: 16.sp,
            textColor: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              const Center(child: OrchidBrandWidget()),
              SizedBox(height: 24.h),
              heading,
              SizedBox(height: 28.h),
              _buildCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'SIGNUP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.darkGreen,
                  letterSpacing: -0.6,
                ),
                SizedBox(height: 16.h),
                CustomAuthTextField(
                  controller: emailController,
                  hint: 'email',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (emailError != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: emailError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                CustomAuthTextField(
                  controller: passwordController,
                  hint: 'password',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  isPassword: true,
                ),
                if (passwordError != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: passwordError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                CustomAuthTextField(
                  controller: confirmPasswordController,
                  hint: 'confirm password',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  isPassword: true,
                ),
                if (confirmPasswordError != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: confirmPasswordError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                if (generalError != null) ...[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: generalError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: 28.h),
                CustomButton(
                  label: 'signup',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onSignUp,
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: onNavigateToLogin,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                        children: const [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'login',
                            style: TextStyle(
                              color: AppColors.linkPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
              ],
            ),
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
