import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import 'auth_cubit.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginFormState> {
  LoginCubit(this._auth) : super(const LoginFormState());

  final AuthCubit _auth;

  void setRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  void clearEmailError() {
    if (state.emailError == null && state.generalError == null) return;
    emit(state.copyWith(emailError: null, generalError: null));
  }

  void clearPasswordError() {
    if (state.passwordError == null && state.generalError == null) return;
    emit(state.copyWith(passwordError: null, generalError: null));
  }

  Future<void> submit({required String email, required String password}) async {
    emit(
      state.copyWith(emailError: null, passwordError: null, generalError: null),
    );

    final emailError = Validators.validateEmail(email);
    final passwordError = password.isEmpty
        ? 'please enter your password'
        : null;

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(emailError: emailError, passwordError: passwordError),
      );
      return;
    }

    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    final result = await _auth.login(
      email: email,
      password: password,
      rememberMe: state.rememberMe,
    );

    if (isClosed) return;

    switch (result) {
      case LoginFailure():
        emit(
          state.copyWith(
            isLoading: false,
            generalError: result.message,
            result: result,
          ),
        );
      case LoginSuccess():
      case LoginIncompleteProfile():
        emit(state.copyWith(isLoading: false, result: result));
    }
  }
}
