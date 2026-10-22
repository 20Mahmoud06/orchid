import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';

/// Popular product item card matching the 4-card grid in the reference image.
class WebPopularProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const WebPopularProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onTap,
    this.onToggle,
  });

  @override
  State<WebPopularProductCard> createState() => _WebPopularProductCardState();
}

class _WebPopularProductCardState extends State<WebPopularProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.storeRose.withValues(alpha: 0.4)
                : AppColors.storeCardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
              blurRadius: _hovered ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with heart toggle overlay — fills the card exactly
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.imageUrl.startsWith('http')
                            ? SkeletonImage(
                                path: widget.imageUrl,
                                fit: BoxFit.cover,
                                placeholderColor: AppColors.fieldPink,
                                errorWidget: Image.asset(
                                  AppAssets.circleFlower,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                widget.imageUrl.isNotEmpty
                                    ? widget.imageUrl
                                    : AppAssets.circleFlower,
                                fit: BoxFit.cover,
                              ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.onToggle,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.isFavorite
                                        ? Ionicons.heart
                                        : Ionicons.heart_outline,
                                    size: 17,
                                    color: widget.isFavorite
                                        ? AppColors.storeRose
                                        : AppColors.iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Content: Title & Price
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.storeDeepGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          fontFamily: AppFonts.inriaSerif,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.storeDeepGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible alias for WebProductCard.
class WebProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const WebProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return WebPopularProductCard(
      imageUrl: imageUrl,
      title: title,
      price: price,
      isFavorite: isFavorite,
      onTap: onTap,
      onToggle: onToggle,
    );
  }
}
