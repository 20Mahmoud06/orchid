import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import 'auth_link.dart';

/// Centered "Already have an account? Sign in" style prompt.
class AuthInlinePrompt extends StatelessWidget {
  final String leading;
  final String action;
  final VoidCallback? onTap;

  const AuthInlinePrompt({
    super.key,
    required this.leading,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            leading,
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 5),
        AuthLink(text: action, onTap: onTap),
      ],
    );
  }
}
