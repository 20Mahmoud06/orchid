import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../../cubit/sign_up_state.dart';
import 'auth_field_error.dart';
import 'auth_form_card.dart';
import 'auth_switch_link.dart';

class SignUpForm extends StatelessWidget {
  final SignUpFormState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSignUp;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final VoidCallback onConfirmPasswordChanged;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onBackPressed;

  const SignUpForm({
    super.key,
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSignUp,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onNavigateToLogin,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Image.asset(
                    AppAssets.backButtonIcon,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                onPressed: onBackPressed ?? () => Navigator.maybePop(context),
              ),
              SizedBox(height: 8.h),
              const Center(child: OrchidBrandWidget()),
              SizedBox(height: 24.h),
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
              SizedBox(height: 28.h),
              AuthFormCard(
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
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => onEmailChanged(),
                    ),
                    if (state.emailError != null) ...[
                      SizedBox(height: 4.h),
                      AuthFieldError(message: state.emailError!),
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
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => onPasswordChanged(),
                    ),
                    if (state.passwordError != null) ...[
                      SizedBox(height: 4.h),
                      AuthFieldError(message: state.passwordError!),
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: state.isLoading ? null : onSignUp,
                      onChanged: (_) => onConfirmPasswordChanged(),
                    ),
                    if (state.confirmPasswordError != null) ...[
                      SizedBox(height: 4.h),
                      AuthFieldError(message: state.confirmPasswordError!),
                    ],
                    if (state.generalError != null) ...[
                      SizedBox(height: 8.h),
                      AuthFieldError(message: state.generalError!),
                    ],
                    SizedBox(height: 28.h),
                    CustomButton(
                      label: 'signup',
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : onSignUp,
                    ),
                    SizedBox(height: 20.h),
                    AuthSwitchLink(
                      prompt: 'Already have an account? ',
                      actionLabel: 'login',
                      onTap: onNavigateToLogin,
                    ),
                    SizedBox(height: 25.h),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
