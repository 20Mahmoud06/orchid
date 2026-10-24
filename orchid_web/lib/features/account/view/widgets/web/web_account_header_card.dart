import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Soft blush heading panel with a title and supporting sentence.
class WebAccountHeaderCard extends StatelessWidget {
  final String title;
  final String body;

  const WebAccountHeaderCard({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomText(
            text: title,
            textAlign: TextAlign.center,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            textColor: AppColors.darkGreen,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: body,
            textAlign: TextAlign.center,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            textColor: AppColors.darkGreen,
          ),
        ],
      ),
    );
  }
}
