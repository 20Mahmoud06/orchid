import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_model.dart';
import 'product_row.dart';
import 'product_table_empty_state.dart';
import 'product_table_header.dart';
import 'product_table_pagination.dart';

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
              final tableWidth = constraints.maxWidth < _tableMinWidth
                  ? _tableMinWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      const ProductTableHeader(),
                      if (products.isEmpty)
                        const ProductTableEmptyState()
                      else
                        for (
                          int index = 0;
                          index < products.length;
                          index++
                        ) ...[
                          ProductRow(
                            product: products[index],
                            onEdit: onEditProduct == null
                                ? null
                                : () => onEditProduct!(products[index]),
                            onDelete: onDeleteProduct == null
                                ? null
                                : () => onDeleteProduct!(products[index]),
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
          ProductTablePagination(
            onPageChanged: onPageChanged,
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            pageSize: pageSize,
          ),
        ],
      ),
    );
  }
}
