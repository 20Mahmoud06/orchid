import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

/// Page title + optional supporting sentence.
class AuthHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 30,
            height: 1.15,
            color: AppColors.darkGreen,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}
