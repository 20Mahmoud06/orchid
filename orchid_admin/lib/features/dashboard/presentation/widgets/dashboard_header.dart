import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/time/date_range.dart';
import '../../../../core/widgets/date_range_selector.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.adminFirstName,
    required this.dateRange,
    required this.onRangeChanged,
    required this.isLoading,
  });

  final String adminFirstName;
  final DateRange dateRange;
  final ValueChanged<DateRange> onRangeChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Welcome back, $adminFirstName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              text: 'Track your orders and revenue for any period.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        );
        final selector = DateRangeSelector(
          dateRange: dateRange,
          onChanged: onRangeChanged,
          isLoading: isLoading,
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: selector),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            SizedBox(width: 310, child: selector),
          ],
        );
      },
    );
  }
}
