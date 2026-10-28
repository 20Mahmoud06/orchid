import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_text.dart';
import '../../../../products/domain/models/product_model.dart';

class FlowerThumbnail extends StatelessWidget {
  const FlowerThumbnail({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: product.imagePath.isEmpty
            ? const ColoredBox(
                color: AppColors.border,
                child: Icon(
                  Icons.local_florist_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              )
            : Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: AppColors.border,
                  child: Icon(
                    Icons.local_florist_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }
}
