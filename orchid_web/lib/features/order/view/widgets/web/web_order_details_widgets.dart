import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import '../../../models/customer_order.dart';
import '../order_status_colors.dart';

/// Desktop-first building blocks for the Order Details page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "order details" title.
class WebOrderDetailsHeader extends StatelessWidget {
  const WebOrderDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'order details',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// White rounded panel shared by the details cards.
class _WebDetailsCard extends StatelessWidget {
  final Widget child;

  const _WebDetailsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

/// Order code, status chip, placed-on date and the grand total.
class WebOrderStatusCard extends StatelessWidget {
  final String displayCode;
  final String status;
  final String placedOn;
  final int total;

  const WebOrderStatusCard({
    super.key,
    required this.displayCode,
    required this.status,
    required this.placedOn,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _WebDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: displayCode,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: orderStatusBackgroundColor(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(
                  text: status.toUpperCase(),
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  textColor: orderStatusTextColor(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'placed on $placedOn',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 15,
            textColor: AppColors.textFieldText,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'total',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '$total EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20,
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

/// Every purchased line of the order.
class WebOrderItemsCard extends StatelessWidget {
  final List<CustomerOrderItem> items;

  const WebOrderItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
    return _WebDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'items ($itemCount)',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            _WebOrderItemRow(item: item),
            if (item != items.last) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _WebOrderItemRow extends StatelessWidget {
  final CustomerOrderItem item;

  const _WebOrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? SkeletonImage(
                    path: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: const SkeletonFallbackBox(),
                  )
                : const Icon(
                    Icons.local_florist_outlined,
                    size: 26,
                    color: AppColors.primary,
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: item.name,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 2),
              CustomText(
                text: '${item.quantity} × ${item.unitPrice} EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 14,
                textColor: AppColors.textFieldText,
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 2),
                CustomText(
                  text: item.description!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 13,
                  textColor: AppColors.primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.message != null && item.message!.isNotEmpty) ...[
                const SizedBox(height: 2),
                CustomText(
                  text: item.message!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 13,
                  textColor: AppColors.darkGreen,
                  fontStyle: FontStyle.italic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        CustomText(
          text: '${item.total} EGP',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.selectedCategory,
        ),
      ],
    );
  }
}

/// Delivery address, gift message and additional notes.
class WebOrderDeliveryCard extends StatelessWidget {
  final String address;
  final String? message;
  final String? notes;

  const WebOrderDeliveryCard({
    super.key,
    required this.address,
    this.message,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return _WebDetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'delivery',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          const SizedBox(height: 12),
          _WebInfoRow(
            icon: Icons.location_on_outlined,
            text: address.isEmpty ? 'No address provided' : address,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WebInfoRow(icon: Icons.card_giftcard_outlined, text: message!),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WebInfoRow(icon: Icons.edit_note, text: notes!),
          ],
        ],
      ),
    );
  }
}

class _WebInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WebInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: CustomText(
            text: text,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            textColor: AppColors.black.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
