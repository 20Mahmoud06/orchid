import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_text.dart';
import '../../../../products/domain/models/product_model.dart';
import 'flower_thumbnail.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            FlowerThumbnail(product: product),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: product.name, style: AppTextStyles.body),
                  if (product.categoryName != null &&
                      product.categoryName!.isNotEmpty)
                    CustomText(
                      text: product.categoryName!,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            CustomText(
              text: 'EGP ${product.price.round()}',
              style: AppTextStyles.label,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
