import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Full-width floating "view bouquet" bar matching the mobile wording.
class WebViewBouquetBar extends StatelessWidget {
  final int totalCount;
  final int totalPrice;
  final VoidCallback? onTap;
  final bool isSingleFlower;

  const WebViewBouquetBar({
    super.key,
    required this.totalCount,
    required this.totalPrice,
    this.onTap,
    this.isSingleFlower = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.incrementButton,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.designFieldPink.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text:
                    '${isSingleFlower ? 'view flower' : 'view bouquet'} '
                    '($totalCount) >',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textColor: AppColors.viewBouquetButton,
              ),
              CustomText(
                text: '$totalPrice EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                textColor: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
