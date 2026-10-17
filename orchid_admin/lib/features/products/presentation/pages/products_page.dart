import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import '../widgets/categories_manager_dialog.dart';
import '../widgets/product_filters.dart';
import '../widgets/product_table.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _productsRepository = ProductsRepository();
  final _categoriesRepository = CategoriesRepository();
  final _searchController = TextEditingController();

  List<Product> _allProducts = const [];
  List<Category> _categories = const [];
  bool _isLoading = true;
  String? _loadError;

  ProductType? _type;
  bool? _active;
  int _currentPage = 1;
  static const int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _productsRepository.getAllProducts(),
        _categoriesRepository.getAllCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _allProducts = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    var products = List<Product>.from(_allProducts);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                (p.categoryName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (_type != null) {
      products = products.where((p) => p.type == _type).toList();
    }

    if (_active != null) {
      products = products.where((p) => p.isActive == _active).toList();
    }

    return products;
  }

  List<Product> get _pagedProducts {
    final filtered = _filteredProducts;
    final start = (_currentPage - 1) * _pageSize;
    if (start >= filtered.length) return [];
    final end = (start + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get _totalPages =>
      (_filteredProducts.length / _pageSize).ceil().clamp(1, 999);

  int get _allCount => _allProducts.length;
  int get _activeCount => _allProducts.where((p) => p.isActive).length;
  int get _inactiveCount => _allProducts.where((p) => !p.isActive).length;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _type = null;
      _active = null;
      _currentPage = 1;
    });
  }

  Future<void> _manageCategories() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => CategoriesManagerDialog(categories: _categories),
    );
    if (changed == true && mounted) {
      _load();
    }
  }

  void _addProduct() {
    AppNav.push(context, AppRoutes.addProduct);
  }

  void _editProduct(Product product) {
    AppNav.push(context, AppRoutes.editProduct(product.id));
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _productsRepository.deleteProduct(product.id);
      await _productsRepository.deleteProductImage(product.imagePath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile: isMobile),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                _buildErrorState()
              else ...[
                ProductFilters(
                  searchController: _searchController,
                  onSearchChanged: (_) {
                    setState(() => _currentPage = 1);
                  },
                  typeValue: _type,
                  onTypeChanged: (value) {
                    setState(() {
                      _type = value;
                      _currentPage = 1;
                    });
                  },
                  activeValue: _active,
                  onActiveChanged: (value) {
                    setState(() {
                      _active = value;
                      _currentPage = 1;
                    });
                  },
                  onReset: _resetFilters,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(),
                const SizedBox(height: 20),
                ProductTable(
                  products: _pagedProducts,
                  onEditProduct: _editProduct,
                  onDeleteProduct: _deleteProduct,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  totalItems: _filteredProducts.length,
                  pageSize: _pageSize,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load products', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            _loadError ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Retry', icon: Icons.refresh, onPressed: _load),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    final title = Text(
      'Products',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
    final subtitle = Text(
      'Manage the products available in your Orchid mobile store.',
      style: AppTextStyles.bodySecondary,
    );
    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: 'Categories',
          icon: Icons.category_outlined,
          variant: AppButtonVariant.outline,
          onPressed: _manageCategories,
        ),
        const SizedBox(width: 12),
        AppButton(
          label: '+ Add Product',
          onPressed: _addProduct,
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, children: [
            AppButton(
              label: 'Categories',
              icon: Icons.category_outlined,
              variant: AppButtonVariant.outline,
              onPressed: _manageCategories,
            ),
            AppButton(label: '+ Add Product', onPressed: _addProduct),
          ]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              subtitle,
            ],
          ),
        ),
        const SizedBox(width: 16),
        buttons,
      ],
    );
  }

  Widget _buildSummaryRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'SUMMARY:',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          _SummaryPill(
            label: 'All Products',
            count: _allCount,
            tone: _SummaryTone.neutral,
            isSelected: _active == null && _type == null,
            onTap: () {
              setState(() {
                _active = null;
                _type = null;
                _currentPage = 1;
              });
            },
          ),
          const SizedBox(width: 8),
          _SummaryPill(
            label: 'Active',
            count: _activeCount,
            tone: _SummaryTone.active,
            isSelected: _active == true,
            onTap: () {
              setState(() {
                _active = true;
                _currentPage = 1;
              });
            },
          ),
          const SizedBox(width: 8),
          _SummaryPill(
            label: 'Inactive',
            count: _inactiveCount,
            tone: _SummaryTone.inactive,
            isSelected: _active == false,
            onTap: () {
              setState(() {
                _active = false;
                _currentPage = 1;
              });
            },
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
      _SummaryTone.neutral =>
        (bg: AppColors.surfaceMuted, fg: AppColors.textSecondary),
      _SummaryTone.active => (bg: AppColors.softLime, fg: AppColors.primary),
      _SummaryTone.inactive =>
        (bg: AppColors.alertSoft, fg: AppColors.error),
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
        child: Text(
          '$label ($count)',
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
