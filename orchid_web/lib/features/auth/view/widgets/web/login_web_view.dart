import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../auth_web_ui.dart';

/// Professional website sign-in panel used on wide (>= 768px) viewports.
class LoginWebView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final ValueChanged<bool> onRememberMeChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onLogin;
  final VoidCallback? onNavigateToSignup;
  final VoidCallback? onNavigateToForgotPassword;

  const LoginWebView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.generalError,
    required this.onRememberMeChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onLogin,
    required this.onNavigateToSignup,
    required this.onNavigateToForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return AuthWebScaffold(
      card: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(title: 'LOGIN'),
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
              autofillHints: const [AutofillHints.password],
              errorText: passwordError,
              onChanged: onPasswordChanged,
              onSubmitted: (_) => onLogin(),
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
                          value: rememberMe,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                          onChanged: isLoading
                              ? null
                              : (value) => onRememberMeChanged(value ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontFamily: AppFonts.inriaSerif,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                AuthLink(
                  text: 'forgot password?',
                  color: AppColors.black,
                  onTap: onNavigateToForgotPassword,
                ),
              ],
            ),
            if (generalError != null) ...[
              const SizedBox(height: 16),
              AuthErrorText(message: generalError!),
            ],
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Login',
              isLoading: isLoading,
              onPressed: onLogin,
            ),
            const SizedBox(height: 22),
            AuthInlinePrompt(
              leading: "Don't have an account?",
              action: 'Sign up',
              onTap: onNavigateToSignup,
            ),
          ],
        ),
      ),
    );
  }
}
