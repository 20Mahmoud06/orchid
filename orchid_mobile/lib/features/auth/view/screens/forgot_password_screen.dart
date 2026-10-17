import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';
import '../widgets/reset_password_dialog.dart';
import '../../cubit/auth_cubit.dart';

/// Route arguments for [ForgotPasswordScreen].
class ForgotPasswordScreenArgs {
  /// Whether the screen should open in password recovery mode.
  final bool recoveryMode;

  const ForgotPasswordScreenArgs({this.recoveryMode = false});
}

/// Forgot Password Screen matching Orchid design specifications with PNG icons.
///
/// The same screen handles both the normal "send reset link" flow and the
/// password recovery flow (opened from the reset email deep link) by switching
/// its content based on [recoveryMode].
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  /// When true the screen shows the "Create New Password" UI and opens the
  /// reset password dialog instead of the reset-link form.
  final bool recoveryMode;

  const ForgotPasswordScreen({
    super.key,
    this.onBackPressed,
    this.recoveryMode = false,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _auth = AuthCubit.instance;

  late bool _isRecoveryMode;
  bool _isSending = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _isRecoveryMode = widget.recoveryMode;
    if (_isRecoveryMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openResetPasswordDialog();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_isSending) return;

    final email = _emailController.text.trim();
    final validationError = Validators.validateEmail(email);
    if (validationError != null) {
      setState(() => _emailError = validationError);
      return;
    }

    setState(() {
      _emailError = null;
      _isSending = true;
    });

    try {
      final exists = await _auth.emailExists(email);
      if (!mounted) return;

      if (exists == false) {
        setState(() {
          _isSending = false;
          _emailError = 'no account found with this email address';
        });
        return;
      }

      await _auth.sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() => _isSending = false);
      _emailController.clear();
      _showMessage('check your email to reset your password');
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showMessage(error is String ? error : AppStrings.networkError,
          isError: true);
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    await _auth.resetPassword(newPassword);
  }

  Future<void> _openResetPasswordDialog() async {
    if (!mounted) return;
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResetPasswordDialog(onSubmit: _updatePassword),
    );
    if (updated == true && mounted) {
      await _finishPasswordReset();
    }
  }

  Future<void> _finishPasswordReset() async {
    await _auth.finishPasswordReset();
    if (!mounted) return;
    _showMessage(
      'password updated successfully, please login with your new password',
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : AppColors.darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: CustomText(
            text: message,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14.sp,
            textColor: AppColors.white,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.all(4.r),
                constraints: const BoxConstraints(),
                icon: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Image.asset(
                    width: 24.r,
                    height: 24.r,
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
                  letterSpacing: 2.5.sp,
                  text: _isRecoveryMode
                      ? 'Create New Password'
                      : 'Forgot Password?',
                  textAlign: TextAlign.center,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.darkGreen,
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: CustomText(
                  text: _isRecoveryMode
                      ? 'enter your new password and confirm it below'
                      : "enter your email address and we'll\nsend you a link to reset your\npassword",
                  textAlign: TextAlign.center,
                  fontSize: 16.sp,
                  textColor: Colors.black87,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 32.h),
              if (_isRecoveryMode)
                CustomButton(
                  label: 'Reset Password',
                  height: 60.h,
                  onPressed: _openResetPasswordDialog,
                )
              else ...[
                CustomAuthTextField(
                  controller: _emailController,
                  hint: 'email address',
                  textColor: AppColors.textSecondary,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.iconColor,
                    size: 22.r,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (_emailError != null) ...[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(
                      text: _emailError!,
                      fontSize: 13.sp,
                      textColor: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                CustomButton(
                  label: 'Send Reset Link',
                  height: 60.h,
                  isLoading: _isSending,
                  onPressed: _isSending ? null : _sendResetLink,
                ),
              ],
              SizedBox(height: 40.h),
              if (!_isRecoveryMode)
                Center(
                  child: Image.asset(
                    AppAssets.emailImage,
                    width: 180.r,
                    height: 180.r,
                    fit: BoxFit.contain,
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
