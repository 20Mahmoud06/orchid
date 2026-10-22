import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Retry panel for the web layout (fixed logical pixels).
class WebOrdersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WebOrdersErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.black.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            textColor: AppColors.black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRetry,
            child: const CustomText(
              text: 'Tap to retry',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              textColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
