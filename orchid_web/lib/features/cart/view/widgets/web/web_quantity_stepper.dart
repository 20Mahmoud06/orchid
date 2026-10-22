import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';

/// Rounded quantity stepper (- / count / +).
class WebQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDecrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.remove, size: 16, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CustomText(
            text: '$quantity',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textColor: AppColors.white,
          ),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onIncrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
