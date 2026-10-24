import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import 'product_form_section_title.dart';

class ProductFormStatusSection extends StatelessWidget {
  const ProductFormStatusSection({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFormSectionTitle(
          title: 'Product Status',
          icon: Icons.assignment_outlined,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Active Product',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: 'Visible in the mobile store',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: onChanged,
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
