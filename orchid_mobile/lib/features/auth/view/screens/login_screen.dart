import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_routes.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/login_cubit.dart';
import '../../cubit/login_state.dart';
import '../widgets/login_form.dart';

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
  late final LoginCubit _loginCubit = LoginCubit(AuthCubit.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginCubit.close();
    super.dispose();
  }

  void _validateAndLogin() {
    _loginCubit.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _handleResult(BuildContext context, LoginResult? result) {
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
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginFormState>(
      bloc: _loginCubit,
      listener: (context, state) => _handleResult(context, state.result),
      builder: (context, state) => LoginForm(
        state: state,
        emailController: _emailController,
        passwordController: _passwordController,
        onLogin: _validateAndLogin,
        onEmailChanged: _loginCubit.clearEmailError,
        onPasswordChanged: _loginCubit.clearPasswordError,
        onRememberMeChanged: _loginCubit.setRememberMe,
        onForgotPassword: widget.onNavigateToForgotPassword,
        onSignUp: widget.onNavigateToSignup,
      ),
    );
  }
}
