import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Shown when "No" is selected — "No message added".
class WebMessageEmptyPlaceholder extends StatelessWidget {
  const WebMessageEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withValues(alpha: 0.6),
                  AppColors.background.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppAssets.noSpeechBubbleIcon,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                color: AppColors.iconColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomText(
            text: 'No message added',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18,
            textColor: AppColors.primary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'You can add it later at any time',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            textColor: AppColors.iconColor.withValues(alpha: 0.4),
            fontWeight: FontWeight.w300,
          ),
        ],
      ),
    );
  }
}
