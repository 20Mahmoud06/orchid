import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../widgets/auth_web_ui.dart';
import '../../cubit/auth_cubit.dart';

/// Login Screen matching exact Figma design specifications with PNG icons and PopScope protection.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSignup;
  final VoidCallback? onNavigateToForgotPassword;

  const LoginScreen({
    super.key,
    this.onNavigateToSignup,
    this.onNavigateToForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = AuthCubit.instance;

  bool _isLoading = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailErr = Validators.validateEmail(email);
    final passwordErr = password.isEmpty ? 'please enter your password' : null;

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
      _generalError = null;
    });

    if (emailErr != null || passwordErr != null) return;

    _performLogin(email, password);
  }

  Future<void> _performLogin(String email, String password) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _auth.login(
      email: email,
      password: password,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case LoginSuccess():
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainNav,
          (route) => false,
        );
        break;
      case LoginIncompleteProfile():
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.completeProfile,
          (route) => false,
        );
        break;
      case LoginFailure():
        setState(() => _generalError = result.message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop-first web presentation: a restrained, centered sign-in
          // panel on a soft botanical background. Narrow viewports keep the
          // existing Orchid mobile layout.
          if (constraints.maxWidth >= 768) {
            return AuthWebScaffold(card: _buildWebCard());
          }

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
                        _buildCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Professional website sign-in panel used on wide (>= 768px) viewports.
  Widget _buildWebCard() {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(title: 'LOGIN'),
          const SizedBox(height: 28),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null || _generalError != null) {
                setState(() {
                  _emailError = null;
                  _generalError = null;
                });
              }
            },
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'password',
            isPassword: true,
            autofillHints: const [AutofillHints.password],
            errorText: _passwordError,
            onChanged: (_) {
              if (_passwordError != null || _generalError != null) {
                setState(() {
                  _passwordError = null;
                  _generalError = null;
                });
              }
            },
            onSubmitted: (_) => _validateAndLogin(),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        activeColor: AppColors.cardBorder,
                        checkColor: AppColors.white,
                        side: const BorderSide(
                          color: AppColors.pinkBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: _isLoading
                            ? null
                            : (value) =>
                                  setState(() => _rememberMe = value ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => setState(() => _rememberMe = !_rememberMe),
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        'Remember me',
                        style: TextStyle(
                          fontFamily: AppFonts.inriaSerif,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AuthLink(
                text: 'forgot password?',
                color: AppColors.black,
                onTap: widget.onNavigateToForgotPassword,
              ),
            ],
          ),
          if (_generalError != null) ...[
            const SizedBox(height: 16),
            AuthErrorText(message: _generalError!),
          ],
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Login',
            isLoading: _isLoading,
            onPressed: _validateAndLogin,
          ),
          const SizedBox(height: 22),
          AuthInlinePrompt(
            leading: "Don't have an account?",
            action: 'Sign up',
            onTap: widget.onNavigateToSignup,
          ),
        ],
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
                  text: 'LOGIN',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.darkGreen,
                  letterSpacing: -0.6,
                ),
                SizedBox(height: 24.h),
                CustomAuthTextField(
                  controller: _emailController,
                  hint: 'email',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (_emailError != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: _emailError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                CustomAuthTextField(
                  controller: _passwordController,
                  hint: 'password',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  isPassword: true,
                ),
                if (_passwordError != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: _passwordError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                if (_generalError != null) ...[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: _generalError!,
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
                              value: _rememberMe,
                              activeColor: AppColors.cardBorder,
                              checkColor: AppColors.white,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              onChanged: _isLoading
                                  ? null
                                  : (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
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
                      onTap: widget.onNavigateToForgotPassword,
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
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _validateAndLogin,
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: widget.onNavigateToSignup,
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
