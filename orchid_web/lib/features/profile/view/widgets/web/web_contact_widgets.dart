import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';

/// Desktop-first Contact Us widgets.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile contact screen exactly. Sizing uses fixed logical pixels (not
/// `flutter_screenutil`) because on the web the app pins the design size, so
/// these values render 1:1 on any monitor — the same convention as the other
/// web pages.

/// ORCHID flower + wordmark used at the top of the contact page.
class WebContactBrand extends StatelessWidget {
  const WebContactBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Text(
          'ORCHID',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 62,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: -1.24,
            color: AppColors.darkGreen,
            shadows: [
              Shadow(
                offset: const Offset(4, 4),
                blurRadius: 7,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'flower shop',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyBookletter,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: -0.44,
            color: AppColors.flowerShopGreen,
            shadows: [
              Shadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bordered list of contact rows with divider lines, matching the mobile card.
class WebContactSection extends StatelessWidget {
  final List<WebContactTile> tiles;

  const WebContactSection({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.selectedCategory, width: 1),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (index < tiles.length - 1)
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: AppColors.selectedCategory,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// A single tappable contact row: icon, title/subtitle and a chevron.
class WebContactTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const WebContactTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              SizedBox(width: 28, height: 28, child: Center(child: icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square social media icon used in the "Follow Us" row.
class WebSocialIcon extends StatelessWidget {
  final String asset;

  const WebSocialIcon({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, width: 52, height: 52, fit: BoxFit.contain);
  }
}
