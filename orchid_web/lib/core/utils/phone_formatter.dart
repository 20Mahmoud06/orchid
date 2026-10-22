import 'package:flutter/services.dart';

/// Formats an Egyptian phone number as "010 1234 5678".
/// Non-digit characters (spaces, dashes, etc.) are stripped first, so already
/// formatted or mixed input is handled gracefully.
String formatEgyptianPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length <= 3) return digits;
  if (digits.length <= 7) {
    return '${digits.substring(0, 3)} ${digits.substring(3)}';
  }
  return '${digits.substring(0, 3)} ${digits.substring(3, 7)} ${digits.substring(7)}';
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 11 digits
    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    // Format as: 010 1234 5678
    String formatted = text;
    if (text.length > 3) {
      formatted = '${text.substring(0, 3)} ${text.substring(3)}';
    }
    if (text.length > 7) {
      formatted =
          '${text.substring(0, 3)} ${text.substring(3, 7)} ${text.substring(7)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
