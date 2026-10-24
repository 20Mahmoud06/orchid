import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Compact inline error message (general/network errors).
class AuthErrorText extends StatelessWidget {
  final String message;

  const AuthErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: CustomText(
            text: message,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 13,
            height: 1.3,
            textColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}
