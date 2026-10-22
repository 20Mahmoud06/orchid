import 'package:equatable/equatable.dart';

const Object _unset = Object();

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.isSending = false,
    this.emailError,
    this.message,
    this.isError = false,
  });

  final bool isSending;
  final String? emailError;
  final String? message;
  final bool isError;

  ForgotPasswordState copyWith({
    bool? isSending,
    Object? emailError = _unset,
    Object? message = _unset,
    bool? isError,
  }) {
    return ForgotPasswordState(
      isSending: isSending ?? this.isSending,
      emailError: identical(emailError, _unset)
          ? this.emailError
          : emailError as String?,
      message: identical(message, _unset) ? this.message : message as String?,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => <Object?>[isSending, emailError, message, isError];
}
