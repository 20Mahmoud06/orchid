import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';

class OrderDeliveryCard extends StatelessWidget {
  const OrderDeliveryCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Delivery Information',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.primary,
            text: order.deliveryAddress.isEmpty
                ? 'No address provided'
                : order.deliveryAddress,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (order.additionalNotes != null &&
              order.additionalNotes!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.note_outlined,
              iconColor: AppColors.textSecondary,
              text: order.additionalNotes!,
              style: AppTextStyles.bodySecondary.copyWith(height: 1.35),
            ),
          ],
          if (order.message != null && order.message!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.card_giftcard_outlined,
              iconColor: AppColors.primary,
              text: '"${order.message}"',
              style: AppTextStyles.bodySecondary.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(text: text, style: style),
        ),
      ],
    );
  }
}
