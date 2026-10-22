import 'package:equatable/equatable.dart';

import '../data/message_choice.dart';

const Object _unset = Object();

class AddMessageState extends Equatable {
  const AddMessageState({
    this.selectedChoice = MessageChoice.yes,
    this.characterCount = 0,
    this.validationError,
  });

  final MessageChoice selectedChoice;
  final int characterCount;
  final String? validationError;

  AddMessageState copyWith({
    MessageChoice? selectedChoice,
    int? characterCount,
    Object? validationError = _unset,
  }) {
    return AddMessageState(
      selectedChoice: selectedChoice ?? this.selectedChoice,
      characterCount: characterCount ?? this.characterCount,
      validationError: identical(validationError, _unset)
          ? this.validationError
          : validationError as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    selectedChoice,
    characterCount,
    validationError,
  ];
}
