import 'package:equatable/equatable.dart';

const Object _unset = Object();

class CompleteProfileState extends Equatable {
  const CompleteProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.usernameError,
    this.phoneError,
    this.addressError,
    this.generalError,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? usernameError;
  final String? phoneError;
  final String? addressError;
  final String? generalError;

  CompleteProfileState copyWith({
    bool? isLoading,
    bool? isSuccess,
    Object? usernameError = _unset,
    Object? phoneError = _unset,
    Object? addressError = _unset,
    Object? generalError = _unset,
  }) {
    return CompleteProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      usernameError: identical(usernameError, _unset)
          ? this.usernameError
          : usernameError as String?,
      phoneError: identical(phoneError, _unset)
          ? this.phoneError
          : phoneError as String?,
      addressError: identical(addressError, _unset)
          ? this.addressError
          : addressError as String?,
      generalError: identical(generalError, _unset)
          ? this.generalError
          : generalError as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isSuccess,
    usernameError,
    phoneError,
    addressError,
    generalError,
  ];
}
