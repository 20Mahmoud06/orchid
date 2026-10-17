import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first building blocks for the order-confirmation page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Top bar of the web confirmation page: the mobile screen's home shortcut
/// pinned to the right edge.
class WebConfirmHeader extends StatelessWidget {
  final VoidCallback onHomePressed;

  const WebConfirmHeader({super.key, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Ionicons.home, size: 24, color: AppColors.black),
            onPressed: onHomePressed,
          ),
        ],
      ),
    );
  }
}

/// The order-number panel: "ORDER CODE" caption above the code itself.
class WebConfirmOrderCodeCard extends StatelessWidget {
  final String orderCode;

  const WebConfirmOrderCodeCard({super.key, required this.orderCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomText(
            text: 'ORDER CODE',
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            textColor: AppColors.black.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          CustomText(
            text: orderCode,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}
