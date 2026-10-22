import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_content_type.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._auth) : super(const EditProfileState());

  final AuthCubit _auth;

  void clearErrors() {
    emit(
      state.copyWith(
        currentPasswordError: null,
        newPasswordError: null,
        generalError: null,
        isSuccess: false,
      ),
    );
  }

  bool validatePasswords({
    required String currentPassword,
    required String newPassword,
  }) {
    if (newPassword.isNotEmpty && currentPassword.isEmpty) {
      emit(
        state.copyWith(
          currentPasswordError: 'please enter your current password',
        ),
      );
      return false;
    }
    if (currentPassword.isNotEmpty && newPassword.isEmpty) {
      emit(state.copyWith(newPasswordError: 'please enter your new password'));
      return false;
    }
    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        emit(
          state.copyWith(
            newPasswordError: 'password must be at least 6 characters',
          ),
        );
        return false;
      }
      if (newPassword == currentPassword) {
        emit(
          state.copyWith(
            newPasswordError:
                'your new password must be different from your current password',
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> save({
    required String username,
    required String phone,
    required String whatsapp,
    required String address,
    required bool wantsPasswordChange,
    required String currentPassword,
    required String newPassword,
    XFile? profileImage,
  }) async {
    if (state.isSaving) return;

    emit(state.copyWith(isSaving: true, generalError: null, isSuccess: false));

    final oldProfileImagePath = _auth.userProfile?.profileImage;

    String? profileImagePath;
    try {
      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        profileImagePath = await _auth.uploadProfileImage(
          bytes: bytes,
          contentType: contentTypeForImageFile(profileImage),
        );
      }

      final result = await _auth.editProfile(
        username: username,
        phone: phone,
        whatsapp: whatsapp,
        address: address,
        profileImagePath: profileImagePath,
      );

      if (result is EditProfileFailure) {
        if (profileImagePath != null) {
          await _auth.deleteProfileImage(profileImagePath);
        }
        if (isClosed) return;
        emit(state.copyWith(isSaving: false, generalError: result.message));
        return;
      }

      if (profileImagePath != null &&
          oldProfileImagePath != null &&
          oldProfileImagePath != profileImagePath) {
        await _auth.deleteProfileImage(oldProfileImagePath);
      }

      if (wantsPasswordChange) {
        final passwordError = await _auth.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        if (passwordError != null) {
          if (isClosed) return;
          emit(
            state.copyWith(
              isSaving: false,
              generalError:
                  'your profile changes were saved, but we could not update '
                  'your password: $passwordError',
            ),
          );
          return;
        }
      }

      if (isClosed) return;
      emit(state.copyWith(isSaving: false, isSuccess: true));
    } catch (error) {
      if (profileImagePath != null) {
        await _auth.deleteProfileImage(profileImagePath);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          isSaving: false,
          generalError: error is String
              ? error
              : 'failed to save your changes, please try again',
        ),
      );
    }
  }
}
