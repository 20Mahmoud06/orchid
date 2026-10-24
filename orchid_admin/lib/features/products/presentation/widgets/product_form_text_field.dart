import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductFormTextField extends StatelessWidget {
  const ProductFormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.isRequired = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final bool isRequired;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  FormFieldValidator<String>? get _effectiveValidator {
    if (validator != null) return validator;
    if (!isRequired) return null;

    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'This field is required';
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: _effectiveValidator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(text: label, style: AppTextStyles.label),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const CustomText(
            text: '*',
            style: TextStyle(color: AppColors.error, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
