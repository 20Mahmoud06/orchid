import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: CustomText(
        text: status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: style.fg,
        ),
      ),
    );
  }

  static ({Color bg, Color fg}) _styleFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return (bg: AppColors.warningSoft, fg: AppColors.warning);
      case OrderStatus.preparing:
        return (bg: AppColors.orchidSoft1, fg: AppColors.orchidStrong);
      case OrderStatus.completed:
        return (bg: AppColors.softLime, fg: AppColors.primary);
      case OrderStatus.canceled:
        return (bg: AppColors.alertSoft, fg: AppColors.error);
    }
  }
}

class OrderStatusVisual {
  const OrderStatusVisual({
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final Color bg;
  final Color fg;

  static OrderStatusVisual forStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const OrderStatusVisual(
          icon: Icons.fiber_new_outlined,
          bg: AppColors.warningSoft,
          fg: AppColors.warning,
        );
      case OrderStatus.preparing:
        return const OrderStatusVisual(
          icon: Icons.autorenew_rounded,
          bg: AppColors.orchidSoft1,
          fg: AppColors.orchidStrong,
        );
      case OrderStatus.completed:
        return const OrderStatusVisual(
          icon: Icons.check_circle_outline,
          bg: AppColors.softLime,
          fg: AppColors.primary,
        );
      case OrderStatus.canceled:
        return const OrderStatusVisual(
          icon: Icons.close_rounded,
          bg: AppColors.alertSoft,
          fg: AppColors.error,
        );
    }
  }
}
