import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_routes.dart';
import '../../../profile/view/screens/complete_profile_screen.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/sign_up_cubit.dart';
import '../../cubit/sign_up_state.dart';
import '../widgets/sign_up_form.dart';

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
  late final SignUpCubit _signUpCubit = SignUpCubit(AuthCubit.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signUpCubit.close();
    super.dispose();
  }

  void _validateAndSignUp() {
    _signUpCubit.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  void _handleResult(BuildContext context, SignUpResult? result) {
    if (result is SignUpSuccess) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.completeProfile,
        (route) => false,
        arguments: const CompleteProfileArgs(fromSignUp: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpFormState>(
      bloc: _signUpCubit,
      listener: (context, state) => _handleResult(context, state.result),
      builder: (context, state) => SignUpForm(
        state: state,
        emailController: _emailController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        onSignUp: _validateAndSignUp,
        onEmailChanged: _signUpCubit.clearEmailError,
        onPasswordChanged: _signUpCubit.clearPasswordError,
        onConfirmPasswordChanged: _signUpCubit.clearConfirmPasswordError,
        onNavigateToLogin: widget.onNavigateToLogin,
        onBackPressed: widget.onBackPressed,
      ),
    );
  }
}
