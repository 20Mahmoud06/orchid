import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

/// Inline text link (e.g. "Forgot password?").
class AuthLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  const AuthLink({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final linkColor = color ?? AppColors.linkPurple;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: linkColor,
          ),
        ),
      ),
    );
  }
}
