import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../order_status_colors.dart';

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
  final VoidCallback? onResumePayment;

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
    this.onResumePayment,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onResumePayment != null)
                        InkWell(
                          onTap: onResumePayment,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textFieldPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const CustomText(
                              text: 'PAY NOW',
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              textColor: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
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
