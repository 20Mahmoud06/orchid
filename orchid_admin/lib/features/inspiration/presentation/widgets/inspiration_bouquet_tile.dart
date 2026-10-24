import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/inspiration_model.dart';
import '../../../products/domain/models/product_model.dart';

class InspirationBouquetTile extends StatelessWidget {
  const InspirationBouquetTile({
    super.key,
    required this.imagePath,
    required this.name,
    required this.ingredients,
    required this.total,
    required this.trailing,
  });

  final String? imagePath;
  final String? name;
  final List<InspirationIngredient> ingredients;
  final double total;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _InspirationThumbnail(path: imagePath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: (name == null || name!.isEmpty)
                      ? 'ORCHID customer'
                      : name!,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: ingredients.isEmpty
                      ? 'Custom arrangement'
                      : ingredients
                            .map((i) => '${i.quantity} ${i.name.toLowerCase()}')
                            .join(', '),
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: '${total.toStringAsFixed(0)} EGP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _InspirationThumbnail extends StatelessWidget {
  const _InspirationThumbnail({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final url = path == null || path!.isEmpty ? '' : productImageUrl(path!);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.orchidSoft1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(
              Icons.local_florist_outlined,
              size: 22,
              color: AppColors.orchidStrong,
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.local_florist_outlined,
                size: 22,
                color: AppColors.orchidStrong,
              ),
            ),
    );
  }
}
