import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_content_type.dart';
import '../../auth/cubit/auth_cubit.dart';

/// Runs the edit-profile save flow (image upload, profile update and the
/// optional password change) and reports the outcome to the screen.
class EditProfileSaveOperation {
  final AuthCubit auth;
  final XFile? profileImage;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController addressController;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;

  const EditProfileSaveOperation({
    required this.auth,
    required this.profileImage,
    required this.usernameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.currentPasswordController,
    required this.newPasswordController,
  });

  Future<EditProfileSaveOutcome> run() async {
    final wantsPasswordChange = newPasswordController.text.isNotEmpty;
    final oldProfileImagePath = auth.userProfile?.profileImage;

    String? profileImagePath;
    try {
      // Upload a newly picked profile picture first (optional).
      if (profileImage != null) {
        final bytes = await profileImage!.readAsBytes();
        profileImagePath = await auth.uploadProfileImage(
          bytes: bytes,
          contentType: contentTypeForImageFile(profileImage!),
        );
      }

      final result = await auth.editProfile(
        username: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        whatsapp: whatsappController.text.trim(),
        address: addressController.text.trim(),
        profileImagePath: profileImagePath,
      );

      if (result is EditProfileFailure) {
        // The save failed after the image was uploaded — clean up the orphan.
        if (profileImagePath != null) {
          await auth.deleteProfileImage(profileImagePath);
        }
        return EditProfileSaveFailure(result.message);
      }

      // The old picture was replaced — remove the orphaned file.
      if (profileImagePath != null &&
          oldProfileImagePath != null &&
          oldProfileImagePath != profileImagePath) {
        await auth.deleteProfileImage(oldProfileImagePath);
      }

      // Password change is optional and runs only after the profile saved.
      if (wantsPasswordChange) {
        final passwordError = await auth.changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );
        if (passwordError != null) {
          return EditProfileSaveFailure(
            'your profile changes were saved, but we could not update '
            'your password: $passwordError',
          );
        }
      }

      return const EditProfileSaveSuccess();
    } catch (error) {
      // An upload error (a thrown String) or an unexpected failure.
      if (profileImagePath != null) {
        await auth.deleteProfileImage(profileImagePath);
      }
      return EditProfileSaveFailure(
        error is String
            ? error
            : 'failed to save your changes, please try again',
      );
    }
  }
}

/// Result of [EditProfileSaveOperation.run].
sealed class EditProfileSaveOutcome {
  const EditProfileSaveOutcome();
}

class EditProfileSaveSuccess extends EditProfileSaveOutcome {
  const EditProfileSaveSuccess();
}

class EditProfileSaveFailure extends EditProfileSaveOutcome {
  final String message;

  const EditProfileSaveFailure(this.message);
}
