import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import '../widgets/categories_manager_dialog.dart';
import '../widgets/delete_product_dialog.dart';
import '../widgets/product_filters.dart';
import '../widgets/product_table.dart';
import '../widgets/products_error_state.dart';
import '../widgets/products_page_header.dart';
import '../widgets/products_summary_row.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  static const int _pageSize = 6;

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
    final query = _searchController.text.trim().toLowerCase();

    return _allProducts.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          (product.categoryName?.toLowerCase().contains(query) ?? false);
      final matchesType = _type == null || product.type == _type;
      final matchesActive = _active == null || product.isActive == _active;
      return matchesSearch && matchesType && matchesActive;
    }).toList();
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

  ProductsSummaryFilter? get _selectedSummaryFilter {
    if (_active == true) return ProductsSummaryFilter.active;
    if (_active == false) return ProductsSummaryFilter.inactive;
    return _type == null ? ProductsSummaryFilter.all : null;
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _type = null;
      _active = null;
      _currentPage = 1;
    });
  }

  void _selectSummaryFilter(ProductsSummaryFilter filter) {
    setState(() {
      switch (filter) {
        case ProductsSummaryFilter.all:
          _active = null;
          _type = null;
        case ProductsSummaryFilter.active:
          _active = true;
        case ProductsSummaryFilter.inactive:
          _active = false;
      }
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
    final confirmed = await confirmProductDeletion(context, product);
    if (!confirmed || !mounted) return;

    try {
      await _productsRepository.deleteProduct(product.id);
      await _productsRepository.deleteProductImage(product.imagePath);
      if (!mounted) return;
      _showSnack('Product deleted');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _showSnack('Failed to delete product: $error', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              ProductsPageHeader(
                isMobile: isMobile,
                onManageCategories: _manageCategories,
                onAddProduct: _addProduct,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                ProductsErrorState(message: _loadError!, onRetry: _load)
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
                ProductsSummaryRow(
                  allCount: _allCount,
                  activeCount: _activeCount,
                  inactiveCount: _inactiveCount,
                  selectedFilter: _selectedSummaryFilter,
                  onFilterSelected: _selectSummaryFilter,
                ),
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
}
