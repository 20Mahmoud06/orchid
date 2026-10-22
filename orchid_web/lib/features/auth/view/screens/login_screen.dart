import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../cubit/auth_cubit.dart';
import '../widgets/login_mobile_view.dart';
import '../widgets/web/login_web_view.dart';

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

  void _handleRememberMeChanged(bool value) {
    setState(() => _rememberMe = value);
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
            return LoginWebView(
              emailController: _emailController,
              passwordController: _passwordController,
              rememberMe: _rememberMe,
              isLoading: _isLoading,
              emailError: _emailError,
              passwordError: _passwordError,
              generalError: _generalError,
              onRememberMeChanged: _handleRememberMeChanged,
              onEmailChanged: _handleEmailChanged,
              onPasswordChanged: _handlePasswordChanged,
              onLogin: _validateAndLogin,
              onNavigateToSignup: widget.onNavigateToSignup,
              onNavigateToForgotPassword: widget.onNavigateToForgotPassword,
            );
          }

          return LoginMobileView(
            emailController: _emailController,
            passwordController: _passwordController,
            rememberMe: _rememberMe,
            isLoading: _isLoading,
            emailError: _emailError,
            passwordError: _passwordError,
            generalError: _generalError,
            onRememberMeChanged: _handleRememberMeChanged,
            onLogin: _validateAndLogin,
            onNavigateToSignup: widget.onNavigateToSignup,
            onNavigateToForgotPassword: widget.onNavigateToForgotPassword,
          );
        },
      ),
    );
  }
}
