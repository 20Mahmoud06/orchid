import 'package:equatable/equatable.dart';

const Object _unset = Object();

class EditProfileState extends Equatable {
  const EditProfileState({
    this.isSaving = false,
    this.isSuccess = false,
    this.currentPasswordError,
    this.newPasswordError,
    this.generalError,
  });

  final bool isSaving;
  final bool isSuccess;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? generalError;

  EditProfileState copyWith({
    bool? isSaving,
    bool? isSuccess,
    Object? currentPasswordError = _unset,
    Object? newPasswordError = _unset,
    Object? generalError = _unset,
  }) {
    return EditProfileState(
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      currentPasswordError: identical(currentPasswordError, _unset)
          ? this.currentPasswordError
          : currentPasswordError as String?,
      newPasswordError: identical(newPasswordError, _unset)
          ? this.newPasswordError
          : newPasswordError as String?,
      generalError: identical(generalError, _unset)
          ? this.generalError
          : generalError as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isSaving,
    isSuccess,
    currentPasswordError,
    newPasswordError,
    generalError,
  ];
}
