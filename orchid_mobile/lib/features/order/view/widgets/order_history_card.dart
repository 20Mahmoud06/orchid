import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import 'order_status_colors.dart';

class OrderHistoryCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String date;
  final int price;
  final String status;
  final String image;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onResumePayment;

  const OrderHistoryCard({
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

  Color get _statusBackgroundColor => orderStatusBackgroundColor(status);

  Color get _statusTextColor => orderStatusTextColor(status);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 205.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1.w,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0.h,
            left: -1.w,
            bottom: 0.h,
            width: 130.w,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 1.w,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13.r),
                  bottomLeft: Radius.circular(13.r),
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
            left: 130.w,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.darkGreen,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onRemove != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.all(2.r),
                              child: Icon(
                                Ionicons.trash,
                                size: 16.r,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: orderId,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 14.sp,
                    textColor: AppColors.textFieldText,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: date,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 14.sp,
                    textColor: AppColors.textFieldText,
                  ),
                  CustomText(
                    text: '$price EGP',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 16.sp,
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
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textFieldPink,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: CustomText(
                              text: 'PAY NOW',
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              textColor: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBackgroundColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: CustomText(
                          text: status.toUpperCase(),
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          textColor: _statusTextColor,
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
