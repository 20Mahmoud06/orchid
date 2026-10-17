import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Modal shown while the user is in password recovery mode.
///
/// Reuses the Orchid [CustomAuthTextField] so the password fields keep the
/// visibility toggle, focus animation and field styling used everywhere else.
/// Pops with `true` once the password has been updated successfully.
class ResetPasswordDialog extends StatefulWidget {
  /// Performs the actual password update. Should throw on failure so the
  /// error can be surfaced inside the dialog.
  final Future<void> Function(String newPassword) onSubmit;

  const ResetPasswordDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Minimum password length. Matches the default Supabase Auth requirement
  /// (Authentication > Settings > Password strength).
  static const int _minPasswordLength = 6;

  String? _errorMessage;
  bool _isSubmitting = false;

  /// Whether the user may leave the dialog. Stays locked while the recovery
  /// is in progress and only opens once the reset fails (e.g. expired link)
  /// so the user is never trapped on a dead-end error.
  bool _canSkip = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validate(String newPassword, String confirmPassword) {
    if (newPassword.isEmpty) {
      return 'please enter your new password';
    }
    if (newPassword.length < _minPasswordLength) {
      return 'password must be at least $_minPasswordLength characters';
    }
    if (confirmPassword.isEmpty) {
      return 'please confirm your new password';
    }
    if (newPassword != confirmPassword) {
      return 'passwords do not match';
    }
    return null;
  }

  String _resolveErrorMessage(Object error) {
    // The AuthCubit resolves Supabase exceptions into a friendly
    // Orchid-style string before rethrowing it.
    if (error is String && error.isNotEmpty) {
      return error;
    }
    return AppStrings.networkError;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final validationError = _validate(newPassword, confirmPassword);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _canSkip = false;
    });

    try {
      await widget.onSubmit(newPassword);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _resolveErrorMessage(error);
        _canSkip = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canSkip,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.background,
        child: SingleChildScrollView(
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
                  Icons.lock_outline,
                  size: 32.r,
                  color: AppColors.darkGreen,
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'Create New Password',
                textAlign: TextAlign.center,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                textColor: AppColors.darkGreen,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'enter your new password and confirm it below',
                textAlign: TextAlign.center,
                fontSize: 14.sp,
                textColor: AppColors.textPrimary,
                height: 1.3,
              ),
              SizedBox(height: 24.h),
              CustomAuthTextField(
                controller: _newPasswordController,
                hint: 'new password',
                textColor: AppColors.textSecondary,
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppColors.iconColor,
                  size: 22.r,
                ),
                isPassword: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),
              SizedBox(height: 16.h),
              CustomAuthTextField(
                controller: _confirmPasswordController,
                hint: 'confirm new password',
                textColor: AppColors.textSecondary,
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppColors.iconColor,
                  size: 22.r,
                ),
                isPassword: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _isSubmitting ? null : _submit,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: CustomText(
                        text: _errorMessage!,
                        fontSize: 13.sp,
                        textColor: AppColors.error,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 24.h),
              CustomButton(
                label: 'Reset Password',
                height: 56.h,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
