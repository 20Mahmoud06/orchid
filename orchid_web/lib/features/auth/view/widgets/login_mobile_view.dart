import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';

/// Mobile layout of the login screen (unchanged presentation).
class LoginMobileView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onLogin;
  final VoidCallback? onNavigateToSignup;
  final VoidCallback? onNavigateToForgotPassword;

  const LoginMobileView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.generalError,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.onNavigateToSignup,
    required this.onNavigateToForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  const OrchidBrandWidget(),
                  SizedBox(height: 60.h),
                  _buildCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
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
                  text: 'LOGIN',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.darkGreen,
                  letterSpacing: -0.6,
                ),
                SizedBox(height: 24.h),
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
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: rememberMe,
                              activeColor: AppColors.cardBorder,
                              checkColor: AppColors.white,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              onChanged: isLoading
                                  ? null
                                  : (value) =>
                                        onRememberMeChanged(value ?? false),
                            ),
                          ),
                          CustomText(
                            text: 'Remember me',
                            fontSize: 14.sp,
                            textColor: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onNavigateToForgotPassword,
                      child: CustomText(
                        text: 'forgot password?',
                        fontSize: 14.sp,
                        textColor: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  label: 'Login',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onLogin,
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: onNavigateToSignup,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
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
