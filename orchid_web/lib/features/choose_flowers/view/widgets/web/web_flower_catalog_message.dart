import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Centered loading / error / empty message for the desktop flower grid.
class WebFlowerCatalogMessage extends StatelessWidget {
  final String message;
  final bool showLoader;
  final VoidCallback? onRetry;

  const WebFlowerCatalogMessage({
    super.key,
    required this.message,
    this.showLoader = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLoader) ...[
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
            ],
            CustomText(
              text: message,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 18,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onRetry,
                child: const CustomText(
                  text: 'try again',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
