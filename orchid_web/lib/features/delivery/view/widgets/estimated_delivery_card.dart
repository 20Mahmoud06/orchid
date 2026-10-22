import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Estimated delivery info card for the delivery details screen.
class EstimatedDeliveryCard extends StatelessWidget {
  final String? date;
  final String? timeRange;

  const EstimatedDeliveryCard({super.key, this.date, this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.calendarIcon,
            width: 60.w,
            height: 60.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Estimated Delivery',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18.sp,
                  textColor: AppColors.textGrey,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: date ?? CheckoutCubit.instance.deliveryDate,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18.sp,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: timeRange ?? CheckoutCubit.instance.deliveryTime,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18.sp,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
