import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';

class InspirationErrorState extends StatelessWidget {
  const InspirationErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          CustomText(
            text: 'Failed to load inspiration',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
        ],
      ),
    );
  }
}
