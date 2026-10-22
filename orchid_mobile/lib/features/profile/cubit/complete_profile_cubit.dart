import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_content_type.dart';
import '../../../core/validators/phone_validator.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  CompleteProfileCubit(this._auth) : super(const CompleteProfileState());

  final AuthCubit _auth;

  Future<void> submit({
    required String username,
    required String phone,
    String? whatsapp,
    required String address,
    XFile? profileImage,
  }) async {
    emit(
      state.copyWith(
        isSuccess: false,
        usernameError: null,
        phoneError: null,
        addressError: null,
        generalError: null,
      ),
    );

    if (username.isEmpty) {
      emit(state.copyWith(usernameError: 'please enter your username'));
      return;
    }

    final phoneError = PhoneValidator.validateEgyptianPhone(phone);
    if (phoneError != null) {
      emit(state.copyWith(phoneError: phoneError));
      return;
    }

    if (address.isEmpty) {
      emit(state.copyWith(addressError: 'please enter your delivery address'));
      return;
    }

    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    String? profileImagePath;
    try {
      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        profileImagePath = await _auth.uploadProfileImage(
          bytes: bytes,
          contentType: contentTypeForImageFile(profileImage),
        );
      }

      final result = await _auth.completeProfile(
        username: username,
        phone: phone,
        whatsapp: whatsapp,
        address: address,
        profileImagePath: profileImagePath,
      );

      if (isClosed) return;

      switch (result) {
        case CompleteProfileSuccess():
          emit(state.copyWith(isLoading: false, isSuccess: true));
          break;
        case CompleteProfileFailure():
          if (profileImagePath != null) {
            await _auth.deleteProfileImage(profileImagePath);
          }
          if (isClosed) return;
          emit(state.copyWith(isLoading: false, generalError: result.message));
          break;
      }
    } catch (error) {
      if (profileImagePath != null) {
        await _auth.deleteProfileImage(profileImagePath);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          generalError: error is String
              ? error
              : 'failed to save your profile, please try again',
        ),
      );
    }
  }
}
