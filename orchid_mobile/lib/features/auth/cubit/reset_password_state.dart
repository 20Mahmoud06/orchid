import 'package:equatable/equatable.dart';

const Object _unset = Object();

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.isSubmitting = false,
    this.errorMessage,
    this.canSkip = false,
    this.isSuccess = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final bool canSkip;
  final bool isSuccess;

  ResetPasswordState copyWith({
    bool? isSubmitting,
    Object? errorMessage = _unset,
    bool? canSkip,
    bool? isSuccess,
  }) {
    return ResetPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      canSkip: canSkip ?? this.canSkip,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isSubmitting,
    errorMessage,
    canSkip,
    isSuccess,
  ];
}
