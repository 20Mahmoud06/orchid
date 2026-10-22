import 'package:equatable/equatable.dart';

const Object _unset = Object();

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.isDeleting = false,
    this.errorMessage,
    this.deletionSucceeded = false,
  });

  final bool isDeleting;
  final String? errorMessage;
  final bool deletionSucceeded;

  DeleteAccountState copyWith({
    bool? isDeleting,
    Object? errorMessage = _unset,
    bool? deletionSucceeded,
  }) {
    return DeleteAccountState(
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      deletionSucceeded: deletionSucceeded ?? this.deletionSucceeded,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isDeleting,
    errorMessage,
    deletionSucceeded,
  ];
}
