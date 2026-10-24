import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';

class OrderCustomerCard extends StatelessWidget {
  const OrderCustomerCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final name = (order.customerName?.isNotEmpty ?? false)
        ? order.customerName!
        : 'Customer';
    final phone = (order.customerPhone?.isNotEmpty ?? false)
        ? order.customerPhone!
        : 'No phone provided';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Customer Information',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.softLime,
                child: CustomText(
                  text: initials.isEmpty ? 'C' : initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomText(text: phone, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
