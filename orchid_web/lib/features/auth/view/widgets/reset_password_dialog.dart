import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_web_ui.dart';

/// Modal shown while the user is in password recovery mode.
///
/// Reuses the shared [AuthTextField] so the password fields keep the visibility
/// toggle and the same styling as the rest of the authentication pages. Pops
/// with `true` once the password has been updated successfully.
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.fieldPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 30,
                      color: AppColors.deepGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Create New Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 24,
                    height: 1.1,
                    color: AppColors.deepGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'enter your new password and confirm it below',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  controller: _newPasswordController,
                  label: 'New password',
                  hint: 'new password',
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: 18),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm new password',
                  hint: 'confirm new password',
                  isPassword: true,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                  onSubmitted: (_) => _submit(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  AuthErrorText(message: _errorMessage!),
                ],
                const SizedBox(height: 26),
                AuthPrimaryButton(
                  label: 'Reset Password',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
