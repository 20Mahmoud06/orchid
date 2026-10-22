import 'package:flutter/material.dart';

import '../auth_web_ui.dart';

/// Professional website account-creation panel used on wide (>= 768px)
/// viewports. Preserves the exact same fields and validation as mobile.
class SignUpWebView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final VoidCallback onSignUp;
  final VoidCallback? onNavigateToLogin;

  const SignUpWebView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.generalError,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onSignUp,
    required this.onNavigateToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AuthWebScaffold(
      card: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(title: 'SIGNUP'),
            const SizedBox(height: 28),
            AuthTextField(
              controller: emailController,
              label: 'Email',
              hint: 'email',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              errorText: emailError,
              onChanged: onEmailChanged,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: passwordController,
              label: 'Password',
              hint: 'password',
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
              errorText: passwordError,
              onChanged: onPasswordChanged,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: confirmPasswordController,
              label: 'Confirm password',
              hint: 'confirm password',
              isPassword: true,
              errorText: confirmPasswordError,
              onChanged: onConfirmPasswordChanged,
              onSubmitted: (_) => onSignUp(),
            ),
            if (generalError != null) ...[
              const SizedBox(height: 16),
              AuthErrorText(message: generalError!),
            ],
            const SizedBox(height: 26),
            AuthPrimaryButton(
              label: 'signup',
              isLoading: isLoading,
              onPressed: onSignUp,
            ),
            const SizedBox(height: 22),
            AuthInlinePrompt(
              leading: 'Already have an account?',
              action: 'login',
              onTap: onNavigateToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
