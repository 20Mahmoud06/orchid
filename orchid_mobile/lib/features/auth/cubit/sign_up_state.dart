import 'package:equatable/equatable.dart';

import 'auth_cubit.dart';

const Object _unset = Object();

class SignUpFormState extends Equatable {
  const SignUpFormState({
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
    this.result,
  });

  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;
  final SignUpResult? result;

  SignUpFormState copyWith({
    bool? isLoading,
    Object? emailError = _unset,
    Object? passwordError = _unset,
    Object? confirmPasswordError = _unset,
    Object? generalError = _unset,
    SignUpResult? result,
  }) {
    return SignUpFormState(
      isLoading: isLoading ?? this.isLoading,
      emailError: identical(emailError, _unset)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _unset)
          ? this.passwordError
          : passwordError as String?,
      confirmPasswordError: identical(confirmPasswordError, _unset)
          ? this.confirmPasswordError
          : confirmPasswordError as String?,
      generalError: identical(generalError, _unset)
          ? this.generalError
          : generalError as String?,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    emailError,
    passwordError,
    confirmPasswordError,
    generalError,
    result,
  ];
}
