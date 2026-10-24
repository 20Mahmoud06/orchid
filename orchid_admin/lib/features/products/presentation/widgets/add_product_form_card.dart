import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/category_model.dart';
import '../models/product_form_data.dart';
import 'product_form.dart';

class AddProductFormCard extends StatelessWidget {
  const AddProductFormCard({
    super.key,
    required this.categories,
    required this.loadError,
    required this.onRetry,
    required this.onSubmitted,
  });

  final List<Category>? categories;
  final String? loadError;
  final VoidCallback onRetry;
  final Future<bool> Function(ProductFormData) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (loadError != null) {
      content = Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          CustomText(
            text: 'Failed to load form: $loadError',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    } else if (categories == null) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      content = ProductForm(
        categories: categories!,
        onSubmitted: onSubmitted,
        submitLabel: '+ Add Product',
      );
    }

    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: content,
    );
  }
}
