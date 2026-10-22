import 'package:flutter/material.dart';

import 'auth_card.dart';
import 'auth_heading.dart';
import 'auth_primary_button.dart';
import 'auth_text_field.dart';

/// Professional website forgot-password / recovery panel (>= 768px).
class ForgotPasswordWebCard extends StatelessWidget {
  final bool isRecoveryMode;
  final TextEditingController emailController;
  final String? emailError;
  final bool isSending;
  final VoidCallback onEmailChanged;
  final VoidCallback onResetPassword;
  final VoidCallback onSendResetLink;

  const ForgotPasswordWebCard({
    super.key,
    required this.isRecoveryMode,
    required this.emailController,
    required this.emailError,
    required this.isSending,
    required this.onEmailChanged,
    required this.onResetPassword,
    required this.onSendResetLink,
  });

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: isRecoveryMode ? 'Create New Password' : 'Forgot Password?',
            subtitle: isRecoveryMode
                ? 'enter your new password and confirm it below'
                : "enter your email address and we'll send you a link to "
                      'reset your password',
          ),
          const SizedBox(height: 28),
          if (isRecoveryMode)
            AuthPrimaryButton(
              label: 'Reset Password',
              onPressed: onResetPassword,
            )
          else ...[
            AuthTextField(
              controller: emailController,
              label: 'Email address',
              hint: 'email address',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              errorText: emailError,
              onChanged: (_) => onEmailChanged(),
              onSubmitted: (_) => onSendResetLink(),
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Send Reset Link',
              isLoading: isSending,
              onPressed: onSendResetLink,
            ),
          ],
        ],
      ),
    );
  }
}
