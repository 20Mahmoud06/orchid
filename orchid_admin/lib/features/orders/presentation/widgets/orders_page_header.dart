import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/time/date_range.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/date_range_selector.dart';

class OrdersPageHeader extends StatelessWidget {
  const OrdersPageHeader({
    super.key,
    required this.dateRange,
    required this.onRangeChanged,
    required this.isLoading,
    required this.onRefresh,
  });

  final DateRange dateRange;
  final ValueChanged<DateRange> onRangeChanged;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 820;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Orders',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              text: 'Live customer orders from the Orchid mobile app.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        );
        final selector = DateRangeSelector(
          dateRange: dateRange,
          onChanged: onRangeChanged,
          isLoading: isLoading,
        );
        final button = AppButton(
          label: 'Refresh',
          icon: Icons.refresh_rounded,
          variant: AppButtonVariant.outline,
          onPressed: onRefresh,
          isExpanded: stack,
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: selector),
              const SizedBox(height: 12),
              button,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            SizedBox(width: 310, child: selector),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }
}
