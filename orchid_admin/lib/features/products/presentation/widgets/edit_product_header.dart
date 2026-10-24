import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

class EditProductHeader extends StatelessWidget {
  const EditProductHeader({
    super.key,
    required this.isLoading,
    required this.hasProduct,
    required this.onBack,
  });

  final bool isLoading;
  final bool hasProduct;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final notFound = !isLoading && !hasProduct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.textSecondary,
              ),
              label: const Text('Back to Products'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: notFound ? 'Product Not Found' : 'Edit Product',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              text: notFound
                  ? 'The product you are looking for could not be found.'
                  : 'Update product details and settings.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ],
    );
  }
}
