import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_state.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'web_cart_button.dart';

/// TOTAL row plus the CONFIRM ORDER action.
class WebCheckoutSummary extends StatelessWidget {
  final int total;
  final VoidCallback? onConfirmOrder;

  const WebCheckoutSummary({
    super.key,
    required this.total,
    this.onConfirmOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: 'TOTAL',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '$total EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                textColor: AppColors.selectedCategory,
              ),
            ],
          ),
          const SizedBox(height: 14),
          WebCartButton(
            label: 'CONFIRM ORDER',
            height: 52,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            backgroundColor: AppColors.textFieldPink,
            textColor: AppColors.black,
            onPressed:
                onConfirmOrder ??
                () {
                  CheckoutCubit.instance.beginCheckout(CheckoutSource.cart);
                  Navigator.pushNamed(context, AppRoutes.deliveryDetails);
                },
          ),
        ],
      ),
    );
  }
}
