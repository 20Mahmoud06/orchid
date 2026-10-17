import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/order_model.dart';
import 'order_items_list.dart';
import 'order_status_badge.dart';
import 'order_summary.dart';

class OrderDetailsPanel extends StatelessWidget {
  const OrderDetailsPanel({
    super.key,
    required this.order,
    this.onStatusChanged,
  });

  final Order order;
  final ValueChanged<OrderStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(context),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 560;
            final customer = _buildCustomerCard();
            final delivery = _buildDeliveryCard();
            if (stack) {
              return Column(
                children: [
                  customer,
                  const SizedBox(height: 16),
                  delivery,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: customer),
                const SizedBox(width: 16),
                Expanded(child: delivery),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _buildItemsCard(),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final canAccept = order.status == OrderStatus.pending;
    final canComplete = order.status == OrderStatus.preparing;
    final canCancel = order.status == OrderStatus.pending ||
        order.status == OrderStatus.preparing;
    final isCanceled = order.status == OrderStatus.canceled;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 560;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Order #${order.orderCode}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Placed on ${_formatPlacedAt(order.createdAt)}',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canCancel)
                    OutlinedButton.icon(
                      onPressed: onStatusChanged == null
                          ? null
                          : () =>
                              onStatusChanged!(OrderStatus.canceled),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Cancel Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        backgroundColor: AppColors.alertSoft,
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.25)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (canAccept)
                    ElevatedButton.icon(
                      onPressed: onStatusChanged == null
                          ? null
                          : () =>
                              onStatusChanged!(OrderStatus.preparing),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Accept Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (canComplete)
                    ElevatedButton.icon(
                      onPressed: onStatusChanged == null
                          ? null
                          : () =>
                              onStatusChanged!(OrderStatus.completed),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Mark Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (isCanceled)
                    OutlinedButton.icon(
                      onPressed: onStatusChanged == null
                          ? null
                          : () => onStatusChanged!(OrderStatus.preparing),
                      icon: const Icon(Icons.undo_rounded, size: 16),
                      label: const Text('Reopen Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ],
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 14),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Delivery on ${_formatDate(order.deliveryDate)} at ${_formatTime(order.orderTime)}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
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

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Information',
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.softLime,
                child: Text(
                  initials.isEmpty ? 'C' : initials,
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
                    Text(
                      name,
                      style:
                          AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(phone, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Information',
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress.isEmpty
                      ? 'No address provided'
                      : order.deliveryAddress,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (order.additionalNotes != null &&
              order.additionalNotes!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.additionalNotes!,
                    style: AppTextStyles.bodySecondary.copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ],
          if (order.message != null && order.message!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.card_giftcard_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${order.message}"',
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.itemCount})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          OrderItemsList(items: order.items),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          OrderSummary(
            subtotal: order.subtotal,
            deliveryFee: order.deliveryFee,
            serviceFee: order.serviceFee,
            total: order.total,
            paymentMethod: order.paymentMethod,
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatPlacedAt(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final time = _formatTime(date);
    if (isToday) {
      return 'Today, ${_formatDate(date)} at $time';
    }
    return '${_formatDate(date)} at $time';
  }
}
