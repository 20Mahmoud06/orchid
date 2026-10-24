import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/time/date_formatter.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';
import 'order_status_badge.dart';

class OrderListTile extends StatelessWidget {
  const OrderListTile({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final Order order;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = OrderStatusVisual.forStatus(order.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.orchidSoft1 : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visual.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(visual.icon, size: 18, color: visual.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CustomText(
                          text: '#${order.orderCode}',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: (order.customerName?.isNotEmpty ?? false)
                        ? order.customerName!
                        : 'Customer',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: formatRelativeTimestamp(order.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: '${order.total.toStringAsFixed(0)} EGP',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                CustomText(
                  text:
                      '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
