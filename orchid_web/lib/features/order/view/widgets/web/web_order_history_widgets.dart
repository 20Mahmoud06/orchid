import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../order_status_colors.dart';

/// Desktop-first building blocks for the Orders History page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "orders history" title with the cancel-all action on the right.
class WebOrderHistoryHeader extends StatelessWidget {
  final VoidCallback? onCancelAll;
  final bool showCancelAll;

  const WebOrderHistoryHeader({
    super.key,
    this.onCancelAll,
    this.showCancelAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          const Center(
            child: CustomText(
              text: 'orders history',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24,
              textColor: AppColors.black,
            ),
          ),
          if (showCancelAll)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: onCancelAll,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Ionicons.trash,
                      size: 22,
                      color: AppColors.redText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One order row: photo on the left, details on the right — the mobile
/// `OrderHistoryCard` at fixed logical pixels.
class WebOrderHistoryCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String date;
  final int price;
  final String status;
  final String image;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const WebOrderHistoryCard({
    super.key,
    required this.title,
    required this.orderId,
    required this.date,
    required this.price,
    required this.status,
    this.image = AppAssets.bouquetTest,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            width: 170,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
                child: SkeletonImage(
                  path: image,
                  fit: BoxFit.contain,
                  errorWidget: const SkeletonFallbackBox(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 170,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: title,
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.darkGreen,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onRemove != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
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
                  const SizedBox(height: 4),
                  CustomText(
                    text: orderId,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    textColor: AppColors.textFieldText,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: date,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 15,
                    textColor: AppColors.textFieldText,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: '$price EGP',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.selectedCategory,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: orderStatusBackgroundColor(status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          text: status.toUpperCase(),
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          textColor: orderStatusTextColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty history state matching the mobile one with absolute pixel sizing.
class WebOrderEmptyState extends StatelessWidget {
  final String message;

  const WebOrderEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.flowerIcon, width: 200, height: 200),
          const SizedBox(height: 12),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Retry panel for the web layout (fixed logical pixels).
class WebOrdersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WebOrdersErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.black.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            textColor: AppColors.black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRetry,
            child: const CustomText(
              text: 'Tap to retry',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              textColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cancel confirmation (single order or all orders), the mobile dialog at
/// desktop sizing. Pops `true` when the shopper confirms.
class WebCancelOrderDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;

  const WebCancelOrderDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.redText),
              ),
              const SizedBox(height: 16),
              CustomText(
                text: title,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 12),
              CustomText(
                text: message,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'KEEP',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: AppColors.white,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: confirmLabel,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: confirmLabel.length > 14 ? 13 : 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.white,
                      backgroundColor: AppColors.canceledText,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
