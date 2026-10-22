import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'web_announcement_bar.dart';
import 'web_top_nav_actions.dart';
import 'web_top_nav_brand.dart';
import 'web_top_nav_links.dart';

/// Desktop storefront top navigation bar matching the Orchid reference design.
///
/// Combines the top announcement bar with the horizontal desktop header:
/// - Left: Orchid flower icon + uppercase serif 'ORCHID'
/// - Center: Home (with active indicator), Flowers, Bouquets, Inspiration
/// - Right: Favorites, Cart, Profile action items with live badge counts
class WebTopNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const WebTopNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const WebAnnouncementBar(), _buildNavBar(context)],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.storeHairline, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final horizontalPadding = isWide ? 48.0 : 20.0;
          final linkSpacing = isWide ? 28.0 : 16.0;
          final actionSpacing = isWide ? 22.0 : 12.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WebTopNavBrand(onTap: () => onItemSelected(0)),
                    WebTopNavActions(
                      currentIndex: currentIndex,
                      onItemSelected: onItemSelected,
                      spacing: actionSpacing,
                    ),
                  ],
                ),
                WebTopNavLinks(
                  currentIndex: currentIndex,
                  onItemSelected: onItemSelected,
                  spacing: linkSpacing,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
