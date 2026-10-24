import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';

class RecentOrdersEmptyState extends StatelessWidget {
  const RecentOrdersEmptyState({super.key, required this.periodLabel});

  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CustomText(
          text: 'No orders found for $periodLabel.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
