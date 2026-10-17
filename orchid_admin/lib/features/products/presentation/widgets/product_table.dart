import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/product_model.dart';
import 'product_row.dart';

class ProductTable extends StatelessWidget {
  const ProductTable({
    super.key,
    required this.products,
    this.onEditProduct,
    this.onDeleteProduct,
    this.onPageChanged,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.pageSize = 6,
  });

  final List<Product> products;
  final ValueChanged<Product>? onEditProduct;
  final ValueChanged<Product>? onDeleteProduct;
  final ValueChanged<int>? onPageChanged;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  static const double _tableMinWidth = 1040;

  @override
  Widget build(BuildContext context) {
    final startIndex = totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endIndex = (currentPage * pageSize).clamp(0, totalItems);

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < _tableMinWidth ? _tableMinWidth : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      _buildHeader(),
                      if (products.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(48),
                          child: Center(
                            child: Text('No products found.', style: AppTextStyles.bodySecondary),
                          ),
                        )
                      else
                        for (int index = 0; index < products.length; index++) ...[
                          ProductRow(
                            product: products[index],
                            onEdit: onEditProduct == null ? null : () => onEditProduct!(products[index]),
                            onDelete: onDeleteProduct == null ? null : () => onDeleteProduct!(products[index]),
                          ),
                          if (index < products.length - 1)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stack = constraints.maxWidth < 520;
                final summary = Text(
                  'Showing $startIndex to $endIndex of $totalItems products',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                );
                final pagination = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: currentPage > 1 ? () => onPageChanged?.call(currentPage - 1) : null,
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
                          onPressed: isSelected ? null : () => onPageChanged?.call(page),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    _NavIconButton(
                      icon: Icons.chevron_right_rounded,
                      onPressed: currentPage < totalPages ? () => onPageChanged?.call(currentPage + 1) : null,
                    ),
                  ],
                );

                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summary,
                      const SizedBox(height: 12),
                      pagination,
                    ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderLabel('PRODUCT')),
          Expanded(flex: 1, child: _HeaderLabel('TYPE')),
          Expanded(flex: 2, child: _HeaderLabel('CATEGORY')),
          Expanded(flex: 1, child: _HeaderLabel('PRICE')),
          Expanded(flex: 1, child: _HeaderLabel('STATUS')),
          Expanded(flex: 2, child: _HeaderLabel('CREATED DATE')),
          SizedBox(width: 100, child: _HeaderLabel('ACTIONS')),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
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
  const _PageNumberButton({required this.page, required this.isSelected, this.onPressed});

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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '$page',
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
