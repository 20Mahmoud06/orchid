import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../profile/view/screens/complete_profile_screen.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../../cubit/auth_cubit.dart';

/// Sign Up Screen matching Orchid design specifications with PNG icons.
class SignUpScreen extends StatefulWidget {
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onBackPressed;

  const SignUpScreen({super.key, this.onNavigateToLogin, this.onBackPressed});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _auth = AuthCubit.instance;

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSignUp() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate every field, then show all the errors at once.
    final emailErr = Validators.validateEmail(email);

    String? passwordErr;
    if (password.isEmpty) {
      passwordErr = 'please enter a password';
    } else if (password.length < 6) {
      passwordErr = 'password must be at least 6 characters';
    }

    String? confirmErr;
    if (confirmPassword.isEmpty) {
      confirmErr = 'please confirm your password';
    } else if (password != confirmPassword) {
      confirmErr = 'passwords do not match';
    }

    if (emailErr != null || passwordErr != null || confirmErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passwordErr;
        _confirmPasswordError = confirmErr;
      });
      return;
    }

    _performSignUp(email, password);
  }

  Future<void> _performSignUp(String email, String password) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _auth.signUp(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case SignUpSuccess():
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.completeProfile,
          (route) => false,
          arguments: const CompleteProfileArgs(fromSignUp: true),
        );
        break;
      case SignUpFailure():
        setState(() => _generalError = result.message);
        break;
    }
  }

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
                onPressed: widget.onBackPressed ??
                    () => Navigator.maybePop(context),
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
              Container(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 28.h,
                      ),
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
                            controller: _emailController,
                            hint: 'email',
                            textColor: AppColors.textSecondary,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.iconColor,
                              size: 22.r,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_emailError != null ||
                                  _generalError != null) {
                                setState(() {
                                  _emailError = null;
                                  _generalError = null;
                                });
                              }
                            },
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
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_passwordError != null ||
                                  _generalError != null) {
                                setState(() {
                                  _passwordError = null;
                                  _generalError = null;
                                });
                              }
                            },
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
                          SizedBox(height: 16.h),
                          CustomAuthTextField(
                            controller: _confirmPasswordController,
                            hint: 'confirm password',
                            textColor: AppColors.textSecondary,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.iconColor,
                              size: 22.r,
                            ),
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                _isLoading ? null : _validateAndSignUp,
                            onChanged: (_) {
                              if (_confirmPasswordError != null ||
                                  _generalError != null) {
                                setState(() {
                                  _confirmPasswordError = null;
                                  _generalError = null;
                                });
                              }
                            },
                          ),
                          if (_confirmPasswordError != null) ...[
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: CustomText(
                                text: _confirmPasswordError!,
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
                          SizedBox(height: 28.h),
                          CustomButton(
                            label: 'signup',
                            isLoading: _isLoading,
                            onPressed:
                                _isLoading ? null : _validateAndSignUp,
                          ),
                          SizedBox(height: 20.h),
                          Center(
                            child: GestureDetector(
                              onTap: widget.onNavigateToLogin,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        AppColors.black.withValues(alpha: 0.7),
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Already have an account? ',
                                    ),
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
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
