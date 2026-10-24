import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    this.paymentMethod,
  });

  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('Subtotal', '${subtotal.toStringAsFixed(0)} EGP'),
        const SizedBox(height: 8),
        _buildRow(
          'Delivery fee',
          deliveryFee == 0 ? 'Free' : '${deliveryFee.toStringAsFixed(0)} EGP',
          valueColor: deliveryFee == 0 ? AppColors.primary : null,
        ),
        const SizedBox(height: 8),
        _buildRow('Service fee', '${serviceFee.toStringAsFixed(0)} EGP'),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: 'Total: ${total.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (paymentMethod != null && paymentMethod!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text:
                      'Payment method: ${_formatPaymentMethod(paymentMethod!)}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static String _formatPaymentMethod(String value) {
    final normalized = value.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (normalized.isEmpty) return 'Not specified';
    return normalized[0].toUpperCase() + normalized.substring(1).toLowerCase();
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, style: AppTextStyles.bodySecondary),
        CustomText(
          text: value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
