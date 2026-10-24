import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductsPageHeader extends StatelessWidget {
  const ProductsPageHeader({
    super.key,
    required this.isMobile,
    required this.onManageCategories,
    required this.onAddProduct,
  });

  final bool isMobile;
  final VoidCallback onManageCategories;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final title = CustomText(
      text: 'Products',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
    final subtitle = CustomText(
      text: 'Manage the products available in your Orchid mobile store.',
      style: AppTextStyles.bodySecondary,
    );
    final categoriesButton = AppButton(
      label: 'Categories',
      icon: Icons.category_outlined,
      variant: AppButtonVariant.outline,
      onPressed: onManageCategories,
    );
    final addButton = AppButton(
      label: '+ Add Product',
      onPressed: onAddProduct,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [categoriesButton, addButton],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 6), subtitle],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [categoriesButton, const SizedBox(width: 12), addButton],
        ),
      ],
    );
  }
}
