import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_auth_text_field.dart';
import 'profile_form_error_text.dart';

/// Auth-styled text field plus its inline error, used by the Complete Profile
/// screen.
class CompleteProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CompleteProfileField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAuthTextField(
          textColor: AppColors.textSecondary,
          controller: controller,
          hint: hint,
          prefixIcon: prefixIcon,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
        if (errorText != null) ProfileFormErrorText(message: errorText!),
      ],
    );
  }
}
