import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';

class AddProductTopBar extends StatelessWidget {
  const AddProductTopBar({
    super.key,
    required this.isMobile,
    required this.onProductsPressed,
    required this.onBackPressed,
  });

  final bool isMobile;
  final VoidCallback onProductsPressed;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final crumbs = Row(
      children: [
        const Icon(
          Icons.folder_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onProductsPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const CustomText(
            text: 'Products',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        const CustomText(
          text: ' / ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const CustomText(
          text: 'Add New Product',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );

    final back = OutlinedButton.icon(
      onPressed: onBackPressed,
      icon: const Icon(Icons.arrow_back, size: 16),
      label: const Text('Back to Products'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [crumbs, const SizedBox(height: 12), back],
      );
    }

    return Row(
      children: [
        Expanded(child: crumbs),
        back,
      ],
    );
  }
}
