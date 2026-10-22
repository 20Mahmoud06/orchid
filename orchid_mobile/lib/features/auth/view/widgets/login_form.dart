import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../../cubit/login_state.dart';
import 'auth_field_error.dart';
import 'auth_form_card.dart';
import 'auth_switch_link.dart';

class LoginForm extends StatelessWidget {
  final LoginFormState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onEmailChanged;
  final VoidCallback onPasswordChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  const LoginForm({
    super.key,
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                const OrchidBrandWidget(),
                SizedBox(height: 60.h),
                AuthFormCard(
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: state.isLoading ? null : onLogin,
                        onChanged: (_) => onPasswordChanged(),
                      ),
                      if (state.passwordError != null) ...[
                        SizedBox(height: 4.h),
                        AuthFieldError(message: state.passwordError!),
                      ],
                      if (state.generalError != null) ...[
                        SizedBox(height: 8.h),
                        AuthFieldError(message: state.generalError!),
                      ],
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  value: state.rememberMe,
                                  activeColor: AppColors.cardBorder,
                                  checkColor: AppColors.white,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  onChanged: state.isLoading
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
                          GestureDetector(
                            onTap: onForgotPassword,
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
                        isLoading: state.isLoading,
                        onPressed: state.isLoading ? null : onLogin,
                      ),
                      SizedBox(height: 20.h),
                      AuthSwitchLink(
                        prompt: "Don't have an account? ",
                        actionLabel: 'Sign up',
                        onTap: onSignUp,
                      ),
                      SizedBox(height: 25.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
