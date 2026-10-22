import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../profile/view/screens/complete_profile_screen.dart';
import '../../cubit/auth_cubit.dart';
import '../widgets/sign_up_mobile_view.dart';
import '../widgets/web/sign_up_web_view.dart';

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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final emailErr = Validators.validateEmail(email);
    final String? passwordErr;
    if (password.isEmpty) {
      passwordErr = 'please enter a password';
    } else if (password.length < 6) {
      passwordErr = 'password must be at least 6 characters';
    } else {
      passwordErr = null;
    }

    final String? confirmPasswordErr;
    if (confirmPassword.isEmpty) {
      confirmPasswordErr = 'please confirm your password';
    } else if (password != confirmPassword) {
      confirmPasswordErr = 'passwords do not match';
    } else {
      confirmPasswordErr = null;
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
      _generalError = null;
    });

    if (emailErr != null || passwordErr != null || confirmPasswordErr != null) {
      return;
    }

    _performSignUp(email, password);
  }

  Future<void> _performSignUp(String email, String password) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _auth.signUp(email: email, password: password);

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

  void _handleEmailChanged(String _) {
    if (_emailError != null || _generalError != null) {
      setState(() {
        _emailError = null;
        _generalError = null;
      });
    }
  }

  void _handlePasswordChanged(String _) {
    if (_passwordError != null || _generalError != null) {
      setState(() {
        _passwordError = null;
        _generalError = null;
      });
    }
  }

  void _handleConfirmPasswordChanged(String _) {
    if (_confirmPasswordError != null || _generalError != null) {
      setState(() {
        _confirmPasswordError = null;
        _generalError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Desktop-first web presentation (>= 768px): a centered sign-up
            // panel matching the Login page. Narrow viewports keep the Orchid
            // mobile layout.
            if (constraints.maxWidth >= 768) {
              return SignUpWebView(
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isLoading: _isLoading,
                emailError: _emailError,
                passwordError: _passwordError,
                confirmPasswordError: _confirmPasswordError,
                generalError: _generalError,
                onEmailChanged: _handleEmailChanged,
                onPasswordChanged: _handlePasswordChanged,
                onConfirmPasswordChanged: _handleConfirmPasswordChanged,
                onSignUp: _validateAndSignUp,
                onNavigateToLogin: widget.onNavigateToLogin,
              );
            }

            return SignUpMobileView(
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              isLoading: _isLoading,
              emailError: _emailError,
              passwordError: _passwordError,
              confirmPasswordError: _confirmPasswordError,
              generalError: _generalError,
              onSignUp: _validateAndSignUp,
              onNavigateToLogin: widget.onNavigateToLogin,
            );
          },
        ),
      ),
    );
  }
}
