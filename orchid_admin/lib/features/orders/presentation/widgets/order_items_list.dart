import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../products/domain/models/product_model.dart';
import '../../domain/models/order_model.dart';

class OrderItemsList extends StatelessWidget {
  const OrderItemsList({super.key, required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('No items recorded for this order.',
              style: AppTextStyles.bodySecondary),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _OrderItemRow(item: items[i]),
          if (i < items.length - 1)
            const Divider(height: 1, color: AppColors.border),
        ],
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  String? get _imageUrl {
    final raw = item.imageUrl;
    if (raw == null || raw.isEmpty) return null;
    return productImageUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;
    final components = item.customComponents;
    final arrangement = (components?['description'] as String?)?.trim();
    final message = (components?['message'] as String?)?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orchidSoft1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: url == null
                ? const Icon(Icons.local_florist_outlined,
                    size: 22, color: AppColors.orchidStrong)
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                        Icons.local_florist_outlined,
                        size: 22,
                        color: AppColors.orchidStrong),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('Qty: ${item.quantity}', style: AppTextStyles.caption),
                if (arrangement != null && arrangement.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Custom arrangement: $arrangement',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (message != null && message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Message: $message',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${item.total.toStringAsFixed(0)} EGP',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
