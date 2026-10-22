import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._onSubmit) : super(const ResetPasswordState());

  final Future<void> Function(String newPassword) _onSubmit;

  static const int _minPasswordLength = 6;

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  Future<void> submit(String newPassword, String confirmPassword) async {
    if (state.isSubmitting) return;

    final validationError = _validate(newPassword, confirmPassword);
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, canSkip: false),
    );

    try {
      await _onSubmit(newPassword);
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _resolveErrorMessage(error),
          canSkip: true,
        ),
      );
    }
  }

  String? _validate(String newPassword, String confirmPassword) {
    if (newPassword.isEmpty) {
      return 'please enter your new password';
    }
    if (newPassword.length < _minPasswordLength) {
      return 'password must be at least $_minPasswordLength characters';
    }
    if (confirmPassword.isEmpty) {
      return 'please confirm your new password';
    }
    if (newPassword != confirmPassword) {
      return 'passwords do not match';
    }
    return null;
  }

  String _resolveErrorMessage(Object error) {
    if (error is String && error.isNotEmpty) {
      return error;
    }
    return AppStrings.networkError;
  }
}
