import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductTablePagination extends StatelessWidget {
  const ProductTablePagination({
    super.key,
    this.onPageChanged,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.pageSize = 6,
  });

  final ValueChanged<int>? onPageChanged;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final startIndex = totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endIndex = (currentPage * pageSize).clamp(0, totalItems);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < 520;
          final summary = CustomText(
            text: 'Showing $startIndex to $endIndex of $totalItems products',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          );
          final pagination = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: currentPage > 1
                    ? () => onPageChanged?.call(currentPage - 1)
                    : null,
              ),
              const SizedBox(width: 4),
              ...List.generate(totalPages.clamp(0, 8), (index) {
                final page = index + 1;
                final isSelected = page == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _PageNumberButton(
                    page: page,
                    isSelected: isSelected,
                    onPressed: isSelected
                        ? null
                        : () => onPageChanged?.call(page),
                  ),
                );
              }),
              const SizedBox(width: 4),
              _NavIconButton(
                icon: Icons.chevron_right_rounded,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged?.call(currentPage + 1)
                    : null,
              ),
            ],
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 12), pagination],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: summary),
              const SizedBox(width: 16),
              pagination,
            ],
          );
        },
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null ? AppColors.border : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    this.onPressed,
  });

  final int page;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: CustomText(
          text: '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
