import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

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
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
