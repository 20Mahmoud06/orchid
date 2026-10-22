import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

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
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 13,
              height: 1.3,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
