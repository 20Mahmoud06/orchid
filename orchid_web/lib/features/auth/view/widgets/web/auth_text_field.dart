import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Labeled text input with an optional password visibility toggle and inline
/// validation message.
class AuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : AppColors.cardBorder.withValues(alpha: 0.6);

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.label,
          fontFamily: AppFonts.inriaSerif,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          textColor: AppColors.darkGreen,
          letterSpacing: 0.1,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 15,
            color: AppColors.textFieldText,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 15,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            prefixIcon: widget.prefixIcon,
            prefixIconColor: AppColors.iconColor,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.designFieldPink
                : AppColors.fieldDisabledPink,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.selectedCategory,
                width: 1.6,
              ),
            ),
            errorBorder: baseBorder,
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.6),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.iconColor,
                      size: 21,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: CustomText(
              text: widget.errorText!,
              fontFamily: AppFonts.inriaSerif,
              fontSize: 12.5,
              height: 1.3,
              textColor: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
