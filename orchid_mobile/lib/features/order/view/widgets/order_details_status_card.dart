import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../models/customer_order.dart';
import 'order_details_card.dart';
import 'order_status_colors.dart';

/// Order code, status badge, placed date and total.
class OrderDetailsStatusCard extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsStatusCard({super.key, required this.order});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) {
    final hour = date.toLocal().hour > 12
        ? date.toLocal().hour - 12
        : date.toLocal().hour;
    final minute = date.toLocal().minute.toString().padLeft(2, '0');
    final period = date.toLocal().hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${_months[date.month - 1]} ${date.year}, '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return OrderDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: order.displayCode,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: orderStatusBackgroundColor(order.status),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CustomText(
                  text: order.status.toUpperCase(),
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  textColor: orderStatusTextColor(order.status),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: 'placed on ${_formatDate(order.createdAt)}',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            textColor: AppColors.textFieldText,
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: AppColors.cardBorder),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'total',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '${order.total} EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.selectedCategory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
