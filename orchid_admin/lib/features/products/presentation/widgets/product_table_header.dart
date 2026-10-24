import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductTableHeader extends StatelessWidget {
  const ProductTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderLabel('PRODUCT')),
          Expanded(flex: 1, child: _HeaderLabel('TYPE')),
          Expanded(flex: 2, child: _HeaderLabel('CATEGORY')),
          Expanded(flex: 1, child: _HeaderLabel('PRICE')),
          Expanded(flex: 1, child: _HeaderLabel('STATUS')),
          Expanded(flex: 2, child: _HeaderLabel('CREATED DATE')),
          SizedBox(width: 100, child: _HeaderLabel('ACTIONS')),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: CustomText(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
