import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import 'auth_cubit.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpFormState> {
  SignUpCubit(this._auth) : super(const SignUpFormState());

  final AuthCubit _auth;

  void clearEmailError() {
    if (state.emailError == null && state.generalError == null) return;
    emit(state.copyWith(emailError: null, generalError: null));
  }

  void clearPasswordError() {
    if (state.passwordError == null && state.generalError == null) return;
    emit(state.copyWith(passwordError: null, generalError: null));
  }

  void clearConfirmPasswordError() {
    if (state.confirmPasswordError == null && state.generalError == null) {
      return;
    }
    emit(state.copyWith(confirmPasswordError: null, generalError: null));
  }

  Future<void> submit({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(
      state.copyWith(
        emailError: null,
        passwordError: null,
        confirmPasswordError: null,
        generalError: null,
      ),
    );

    final emailError = Validators.validateEmail(email);

    String? passwordError;
    if (password.isEmpty) {
      passwordError = 'please enter a password';
    } else if (password.length < 6) {
      passwordError = 'password must be at least 6 characters';
    }

    String? confirmPasswordError;
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'please confirm your password';
    } else if (password != confirmPassword) {
      confirmPasswordError = 'passwords do not match';
    }

    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
      return;
    }

    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    final result = await _auth.signUp(email: email, password: password);

    if (isClosed) return;

    switch (result) {
      case SignUpFailure():
        emit(
          state.copyWith(
            isLoading: false,
            generalError: result.message,
            result: result,
          ),
        );
      case SignUpSuccess():
        emit(state.copyWith(isLoading: false, result: result));
    }
  }
}
