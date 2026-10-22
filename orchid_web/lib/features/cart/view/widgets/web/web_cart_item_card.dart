import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';
import 'web_quantity_stepper.dart';

/// One cart line: photo, name, price, optional note, stepper and delete.
class WebCartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMessage;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebCartItemCard({
    super.key,
    required this.item,
    required this.onMessage,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SkeletonImage(
              path: item.imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholderColor: AppColors.fieldPink,
              errorWidget: const SkeletonFallbackBox(
                color: AppColors.fieldPink,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: item.name,
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.black,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: onMessage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            AppAssets.greySpeechBubbleIcon,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: '${item.price} EGP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.black,
                ),
                if (item.message != null &&
                    item.message!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CustomText(
                    text: item.message!,
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 13,
                    textColor: AppColors.darkGreen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    WebQuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Ionicons.trash,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
