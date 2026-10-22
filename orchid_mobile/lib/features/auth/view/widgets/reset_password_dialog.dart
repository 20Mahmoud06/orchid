import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../cubit/reset_password_cubit.dart';
import '../../cubit/reset_password_state.dart';

/// Modal shown while the user is in password recovery mode.
///
/// Reuses the Orchid [CustomAuthTextField] so the password fields keep the
/// visibility toggle, focus animation and field styling used everywhere else.
/// Pops with `true` once the password has been updated successfully.
class ResetPasswordDialog extends StatefulWidget {
  /// Performs the actual password update. Should throw on failure so the
  /// error can be surfaced inside the dialog.
  final Future<void> Function(String newPassword) onSubmit;

  const ResetPasswordDialog({super.key, required this.onSubmit});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final ResetPasswordCubit _resetPasswordCubit = ResetPasswordCubit(
    widget.onSubmit,
  );

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resetPasswordCubit.close();
    super.dispose();
  }

  void _submit() {
    _resetPasswordCubit.submit(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      bloc: _resetPasswordCubit,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) => PopScope(
        canPop: state.canSkip,
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
                  onChanged: (_) => _resetPasswordCubit.clearError(),
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
                  onFieldSubmitted: state.isSubmitting ? null : _submit,
                  onChanged: (_) => _resetPasswordCubit.clearError(),
                ),
                if (state.errorMessage != null) ...[
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
                          text: state.errorMessage!,
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
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
