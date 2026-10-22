import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/message_choice.dart';
import 'add_message_state.dart';

class AddMessageCubit extends Cubit<AddMessageState> {
  AddMessageCubit({int initialCharacterCount = 0})
    : super(AddMessageState(characterCount: initialCharacterCount));

  void selectChoice(MessageChoice choice) {
    emit(state.copyWith(selectedChoice: choice, validationError: null));
  }

  void updateCharacterCount(int count) {
    if (state.characterCount == count) return;
    emit(state.copyWith(characterCount: count));
  }

  void clearValidationError() {
    if (state.validationError == null) return;
    emit(state.copyWith(validationError: null));
  }

  bool validateMessage(String text) {
    if (state.selectedChoice == MessageChoice.yes && text.trim().isEmpty) {
      emit(
        state.copyWith(validationError: 'Please enter a message to continue'),
      );
      return false;
    }
    emit(state.copyWith(validationError: null));
    return true;
  }
}
