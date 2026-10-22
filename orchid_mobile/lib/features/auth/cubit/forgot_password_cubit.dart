import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import 'auth_cubit.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._auth) : super(const ForgotPasswordState());

  final AuthCubit _auth;

  Future<void> sendResetLink(String email) async {
    if (state.isSending) return;

    final validationError = Validators.validateEmail(email);
    if (validationError != null) {
      emit(state.copyWith(emailError: validationError, message: null));
      return;
    }

    emit(state.copyWith(emailError: null, isSending: true, message: null));

    try {
      final exists = await _auth.emailExists(email);
      if (isClosed) return;

      if (exists == false) {
        emit(
          state.copyWith(
            isSending: false,
            emailError: 'no account found with this email address',
          ),
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email);
      if (isClosed) return;

      emit(
        state.copyWith(
          isSending: false,
          message: 'check your email to reset your password',
          isError: false,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSending: false,
          message: error is String ? error : AppStrings.networkError,
          isError: true,
        ),
      );
    }
  }
}
