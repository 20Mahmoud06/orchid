import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../domain/models/category_model.dart';
import '../widgets/product_form.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _productsRepository = ProductsRepository();
  final _categoriesRepository = CategoriesRepository();

  List<Category>? _categories;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoriesRepository.getAllCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    }
  }

  Future<bool> _handleSubmit(ProductFormData data) async {
    try {
      final imagePath = await _productsRepository.uploadProductImage(
        bytes: data.pickedImageBytes!,
        filename: data.pickedImageName ?? 'image.jpg',
      );

      await _productsRepository.createProduct(
        name: data.name,
        price: data.price,
        type: data.type,
        categoryId: data.categoryId,
        isActive: data.isActive,
        imagePath: imagePath,
      );

      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      AppNav.pop(context);
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
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
              _buildTopBar(isMobile: isMobile),
              const SizedBox(height: 20),
              Text(
                'Add New Product',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new product to your Orchid store.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final Widget content;
    if (_loadError != null) {
      content = Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load form: $_loadError', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('Retry'),
          ),
        ],
      );
    } else if (_categories == null) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      content = ProductForm(
        categories: _categories!,
        onSubmitted: _handleSubmit,
        submitLabel: '+ Add Product',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: content,
    );
  }

  Widget _buildTopBar({required bool isMobile}) {
    final crumbs = Row(
      children: [
        const Icon(Icons.folder_outlined,
            size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        TextButton(
        onPressed: () => AppNav.go(context, AppRoutes.products),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Products',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        const Text(' / ',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Text(
          'Add New Product',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );

    final back = OutlinedButton.icon(
      onPressed: () => AppNav.pop(context),
      icon: const Icon(Icons.arrow_back, size: 16),
      label: const Text('Back to Products'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          crumbs,
          const SizedBox(height: 12),
          back,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: crumbs),
        back,
      ],
    );
  }
}
