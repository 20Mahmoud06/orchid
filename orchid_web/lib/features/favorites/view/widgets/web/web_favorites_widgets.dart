import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/favorites/view/widgets/favorites_segmented_tabs.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';

/// Fixed-width segmented tab bar (All / Bouquets / Flowers) matching the mobile
/// favorites bar with absolute pixel sizing for the desktop layout.
class WebFavoritesTabs extends StatelessWidget {
  final FavoritesTab selectedTab;
  final ValueChanged<FavoritesTab> onTabSelected;

  const WebFavoritesTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  static const _tabs = <FavoritesTab, String>{
    FavoritesTab.all: 'All',
    FavoritesTab.bouquets: 'Bouquets',
    FavoritesTab.flowers: 'Flowers',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: FavoritesTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardBorder : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: CustomText(
                  text: _tabs[tab]!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18,
                  textColor: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Empty favorites state matching the mobile one with absolute pixel sizing.
class WebFavoritesEmptyState extends StatelessWidget {
  final String message;

  const WebFavoritesEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.flowerIcon, width: 200, height: 200),
          const SizedBox(height: 16),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 22,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Desktop favorite product card: white rounded tile with a cover image,
/// heart toggle and the same name / price wording as the mobile grid cards.
class WebFavoriteCard extends StatelessWidget {
  final String name;
  final int price;
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const WebFavoriteCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
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
                    path: imagePath,
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
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        child: Icon(
                          isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                          size: 18,
                          color: isFavorite
                              ? AppColors.redText
                              : AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: name,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  textColor: AppColors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: '$price EGP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14,
                  textColor: AppColors.black.withValues(alpha: 0.7),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
