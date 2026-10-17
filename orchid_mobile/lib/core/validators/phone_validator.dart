// lib/core/validators/phone_validator.dart

class PhoneValidator {
  // Egyptian phone numbers: 11 digits, starts with 010, 011, 012, 015
  static String? validateEgyptianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters (spaces, dashes, parentheses, etc.)
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it's exactly 11 digits
    if (cleanNumber.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }

    // Check if it starts with valid Egyptian mobile prefixes
    final validPrefixes = ['010', '011', '012', '015'];
    final prefix = cleanNumber.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return 'Invalid phone number prefix. Must start with 010, 011, 012, or 015';
    }

    return null; // Valid
  }

  // Generic international phone number validator
  static String? validateInternationalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters except '+'
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');

    // Check if it has at least 8 digits and at most 15 digits (E.164 standard)
    final digitsOnly = cleanNumber.replaceAll('+', '');
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return 'Phone number must be between 8-15 digits';
    }

    return null; // Valid
  }

  // WhatsApp number validator (same as phone but with specific checks)
  static String? validateWhatsAppNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'WhatsApp number is required';
    }

    // Remove any non-digit characters
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it's exactly 11 digits for Egypt
    if (cleanNumber.length != 11) {
      return 'WhatsApp number must be exactly 11 digits';
    }

    // Check if it starts with valid Egyptian mobile prefixes
    final validPrefixes = ['010', '011', '012', '015'];
    final prefix = cleanNumber.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return 'Invalid WhatsApp number. Must start with 010, 011, 012, or 015';
    }

    return null;
  }
}