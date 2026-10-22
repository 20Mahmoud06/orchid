import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/customer_order.dart';

/// One line item inside the order-details items card.
class OrderDetailsItemRow extends StatelessWidget {
  final CustomerOrderItem item;

  const OrderDetailsItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.cardBorder, width: 1.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? SkeletonImage(
                    path: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: const SkeletonFallbackBox(),
                  )
                : Icon(
                    Icons.local_florist_outlined,
                    size: 24.r,
                    color: AppColors.primary,
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: item.name,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              SizedBox(height: 2.h),
              CustomText(
                text: '${item.quantity} × ${item.unitPrice} EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 13.sp,
                textColor: AppColors.textFieldText,
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                CustomText(
                  text: item.description!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  textColor: AppColors.primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.message != null && item.message!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                CustomText(
                  text: item.message!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  textColor: AppColors.darkGreen,
                  fontStyle: FontStyle.italic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CustomText(
          text: '${item.total} EGP',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          textColor: AppColors.selectedCategory,
        ),
      ],
    );
  }
}
