import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductTableEmptyState extends StatelessWidget {
  const ProductTableEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: CustomText(
          text: 'No products found.',
          style: AppTextStyles.bodySecondary,
        ),
      ),
    );
  }
}
