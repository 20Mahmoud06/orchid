import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../models/customer_order.dart';
import 'order_details_card.dart';

/// Delivery address, gift message and order notes.
class OrderDetailsDeliveryCard extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsDeliveryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'delivery',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          SizedBox(height: 12.h),
          OrderDetailsInfoRow(
            icon: Icons.location_on_outlined,
            text: order.deliveryAddress.isEmpty
                ? 'No address provided'
                : order.deliveryAddress,
          ),
          if (order.message != null && order.message!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            OrderDetailsInfoRow(
              icon: Icons.card_giftcard_outlined,
              text: order.message!,
            ),
          ],
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            OrderDetailsInfoRow(icon: Icons.edit_note, text: order.notes!),
          ],
        ],
      ),
    );
  }
}
