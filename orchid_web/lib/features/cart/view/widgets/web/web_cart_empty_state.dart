import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'web_cart_button.dart';

/// Centered empty-cart illustration with a CALL-TO-action.
class WebCartEmptyState extends StatelessWidget {
  final VoidCallback onChooseItems;

  const WebCartEmptyState({super.key, required this.onChooseItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.fieldPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.cart_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const CustomText(
            text: 'Your cart is empty',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
          const SizedBox(height: 8),
          const CustomText(
            text: 'Start adding your favorite items!',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 260,
            child: WebCartButton(
              label: 'CHOOSE BOUQUET',
              height: 52,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              backgroundColor: AppColors.textFieldPink,
              textColor: AppColors.black,
              onPressed: onChooseItems,
            ),
          ),
        ],
      ),
    );
  }
}
