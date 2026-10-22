import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';

/// Full-width "label : value" info row (About page).
class WebAboutInfoRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const WebAboutInfoRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.sideBarIcons,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
