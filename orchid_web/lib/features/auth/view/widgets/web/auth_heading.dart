import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

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
        CustomText(
          text: title,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 30,
          height: 1.15,
          textColor: AppColors.darkGreen,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          CustomText(
            text: subtitle!,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 15,
            height: 1.45,
            textColor: Colors.black87,
          ),
        ],
      ],
    );
  }
}
