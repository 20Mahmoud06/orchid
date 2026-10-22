import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../../../models/flower_item.dart';

/// Desktop flower card: white tile with cover image, heart toggle, name, price
/// and the same quantity stepper as the mobile grid card.
class WebFlowerGridCard extends StatelessWidget {
  final FlowerItem flower;
  final bool isFavorite;
  final int quantity;
  final bool showQuantityControl;
  final Color? favoriteHeartColor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebFlowerGridCard({
    super.key,
    required this.flower,
    required this.isFavorite,
    required this.quantity,
    this.showQuantityControl = true,
    this.favoriteHeartColor,
    required this.onFavoriteToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SkeletonImage(
                    path: flower.imagePath,
                    fit: BoxFit.cover,
                    placeholderColor: AppColors.fieldPink,
                    errorWidget: const SkeletonFallbackBox(
                      color: AppColors.fieldPink,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFavoriteToggle,
                      child: Icon(
                        isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                        size: 18,
                        color: isFavorite
                            ? (favoriteHeartColor ?? AppColors.redText)
                            : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: flower.name,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  textColor: AppColors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: '${flower.price} EGP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 14,
                        textColor: AppColors.black.withValues(alpha: 0.7),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showQuantityControl) ...[
                      const SizedBox(width: 6),
                      _WebQuantityControl(
                        quantity: quantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
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

class _WebQuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _WebQuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.incrementButton,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.white),
          ),
        ),
      );
    }

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(14),
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
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.remove, size: 15, color: AppColors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CustomText(
              text: '$quantity',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              textColor: AppColors.white,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onIncrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.add, size: 15, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
