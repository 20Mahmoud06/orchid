import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

enum ProductsSummaryFilter { all, active, inactive }

class ProductsSummaryRow extends StatelessWidget {
  const ProductsSummaryRow({
    super.key,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final int allCount;
  final int activeCount;
  final int inactiveCount;
  final ProductsSummaryFilter? selectedFilter;
  final ValueChanged<ProductsSummaryFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomText(
            text: 'SUMMARY:',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          _SummaryPill(
            label: 'All Products',
            count: allCount,
            tone: _SummaryTone.neutral,
            isSelected: selectedFilter == ProductsSummaryFilter.all,
            onTap: () => onFilterSelected(ProductsSummaryFilter.all),
          ),
          const SizedBox(width: 8),
          _SummaryPill(
            label: 'Active',
            count: activeCount,
            tone: _SummaryTone.active,
            isSelected: selectedFilter == ProductsSummaryFilter.active,
            onTap: () => onFilterSelected(ProductsSummaryFilter.active),
          ),
          const SizedBox(width: 8),
          _SummaryPill(
            label: 'Inactive',
            count: inactiveCount,
            tone: _SummaryTone.inactive,
            isSelected: selectedFilter == ProductsSummaryFilter.inactive,
            onTap: () => onFilterSelected(ProductsSummaryFilter.inactive),
          ),
        ],
      ),
    );
  }
}

enum _SummaryTone { neutral, active, inactive }

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.tone,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final int count;
  final _SummaryTone tone;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      _SummaryTone.neutral => (
        bg: AppColors.surfaceMuted,
        fg: AppColors.textSecondary,
      ),
      _SummaryTone.active => (bg: AppColors.softLime, fg: AppColors.primary),
      _SummaryTone.inactive => (bg: AppColors.alertSoft, fg: AppColors.error),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? Border.all(color: colors.fg.withValues(alpha: 0.35))
              : null,
        ),
        child: CustomText(
          text: '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.fg,
          ),
        ),
      ),
    );
  }
}
