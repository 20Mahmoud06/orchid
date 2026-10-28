import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_text.dart';
import 'flower_thumbnail.dart';
import 'selected_flower.dart';

class SelectedFlowerTile extends StatelessWidget {
  const SelectedFlowerTile({
    super.key,
    required this.flower,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.quantityValidator,
    required this.maxFlowers,
  });

  final SelectedFlower flower;
  final VoidCallback onRemove;
  final ValueChanged<String> onQuantityChanged;
  final String? Function(String?) quantityValidator;
  final int maxFlowers;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          FlowerThumbnail(product: flower.product),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: flower.product.name,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: 'EGP ${flower.product.price.round()}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: TextFormField(
              controller: flower.quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: onQuantityChanged,
              validator: quantityValidator,
              decoration: InputDecoration(
                labelText: 'Qty',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Remove flower',
          ),
        ],
      ),
    );
  }
}
