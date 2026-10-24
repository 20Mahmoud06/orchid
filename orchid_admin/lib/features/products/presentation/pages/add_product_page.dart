import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../domain/models/category_model.dart';
import '../models/product_form_data.dart';
import '../widgets/add_product_form_card.dart';
import '../widgets/add_product_top_bar.dart';

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
              AddProductTopBar(
                isMobile: isMobile,
                onProductsPressed: () => AppNav.go(context, AppRoutes.products),
                onBackPressed: () => AppNav.pop(context),
              ),
              const SizedBox(height: 20),
              CustomText(
                text: 'Add New Product',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              CustomText(
                text: 'Add a new product to your Orchid store.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              AddProductFormCard(
                categories: _categories,
                loadError: _loadError,
                onRetry: _loadCategories,
                onSubmitted: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
