import '../../../core/validators/phone_validator.dart';

/// Inline validation shared by the mobile and desktop edit-profile forms.
class EditProfileValidators {
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please enter your username';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please enter your delivery address';
    }
    return null;
  }

  /// WhatsApp is optional — an empty value is allowed, anything else must be
  /// a valid 11-digit Egyptian mobile number.
  static String? validateWhatsapp(String? value) {
    final clean = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return null;
    return PhoneValidator.validateWhatsAppNumber(clean);
  }

  static PasswordValidationResult validatePasswords({
    required String currentPassword,
    required String newPassword,
  }) {
    if (newPassword.isNotEmpty && currentPassword.isEmpty) {
      return const PasswordValidationResult(
        currentPasswordError: 'please enter your current password',
      );
    }
    if (currentPassword.isNotEmpty && newPassword.isEmpty) {
      return const PasswordValidationResult(
        newPasswordError: 'please enter your new password',
      );
    }
    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        return const PasswordValidationResult(
          newPasswordError: 'password must be at least 6 characters',
        );
      }
      if (newPassword == currentPassword) {
        return const PasswordValidationResult(
          newPasswordError:
              'your new password must be different from your current password',
        );
      }
    }
    return const PasswordValidationResult();
  }
}

/// The inline errors produced when validating the optional password change.
class PasswordValidationResult {
  final String? currentPasswordError;
  final String? newPasswordError;

  const PasswordValidationResult({
    this.currentPasswordError,
    this.newPasswordError,
  });

  bool get isValid => currentPasswordError == null && newPasswordError == null;
}
