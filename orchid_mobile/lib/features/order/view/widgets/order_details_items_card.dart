import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../models/customer_order.dart';
import 'order_details_card.dart';
import 'order_details_item_row.dart';

/// Items included in the order, with a divider between each row.
class OrderDetailsItemsCard extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsItemsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text:
                'items (${order.items.fold<int>(0, (sum, item) => sum + item.quantity)})',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          SizedBox(height: 12.h),
          for (final item in order.items) ...[
            OrderDetailsItemRow(item: item),
            if (item != order.items.last) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: AppColors.cardBorder),
              SizedBox(height: 12.h),
            ],
          ],
        ],
      ),
    );
  }
}
