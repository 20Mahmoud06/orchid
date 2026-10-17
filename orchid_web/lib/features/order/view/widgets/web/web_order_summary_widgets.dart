import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';

/// Desktop-first building blocks for the Order Summary page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "Order Summary" title.
class WebOrderSummaryHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebOrderSummaryHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'Order Summary',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// One purchased item: photo, name, composition and line price.
class WebOrderSummaryCard extends StatelessWidget {
  final String title;
  final String description;
  final int price;
  final String image;

  const WebOrderSummaryCard({
    super.key,
    this.title = 'Custom Bouquet',
    required this.description,
    required this.price,
    this.image = AppAssets.bouquetTest,
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
              path: image,
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
                CustomText(
                  text: title,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  CustomText(
                    text: description,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 13,
                    textColor: AppColors.black.withValues(alpha: 0.7),
                    height: 1.4,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                CustomText(
                  text: '$price EGP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A fee/message/notes line with a leading icon and a trailing value.
class WebSummaryItem extends StatelessWidget {
  final Widget? leading;
  final String? iconPath;
  final double iconSize;
  final String title;
  final String? subtitle;
  final String trailing;

  const WebSummaryItem({
    super.key,
    this.leading,
    this.iconPath,
    this.iconSize = 24,
    required this.title,
    this.subtitle,
    required this.trailing,
  }) : assert(
          leading != null || iconPath != null,
          'Either leading or iconPath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    const double titleLineHeight = 20 * 1.45;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: titleLineHeight,
            child: Center(
              child: leading ??
                  Image.asset(
                    iconPath!,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CustomText(
                    text: subtitle!,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16,
                    textColor: AppColors.black.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          CustomText(
            text: trailing,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}

/// "TOTAL" row with the order grand total.
class WebTotalRow extends StatelessWidget {
  final int total;

  const WebTotalRow({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.black,
        ),
      ],
    );
  }
}
