import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Empty history state matching the mobile one with absolute pixel sizing.
class WebOrderEmptyState extends StatelessWidget {
  final String message;

  const WebOrderEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.flowerIcon, width: 200, height: 200),
          const SizedBox(height: 12),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
