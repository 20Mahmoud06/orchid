import 'package:equatable/equatable.dart';

import 'auth_cubit.dart';

const Object _unset = Object();

class LoginFormState extends Equatable {
  const LoginFormState({
    this.isLoading = false,
    this.rememberMe = false,
    this.emailError,
    this.passwordError,
    this.generalError,
    this.result,
  });

  final bool isLoading;
  final bool rememberMe;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final LoginResult? result;

  LoginFormState copyWith({
    bool? isLoading,
    bool? rememberMe,
    Object? emailError = _unset,
    Object? passwordError = _unset,
    Object? generalError = _unset,
    LoginResult? result,
  }) {
    return LoginFormState(
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      emailError: identical(emailError, _unset)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _unset)
          ? this.passwordError
          : passwordError as String?,
      generalError: identical(generalError, _unset)
          ? this.generalError
          : generalError as String?,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    rememberMe,
    emailError,
    passwordError,
    generalError,
    result,
  ];
}
