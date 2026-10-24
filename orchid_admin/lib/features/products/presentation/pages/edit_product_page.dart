import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/products_repository.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import '../models/product_form_data.dart';
import '../widgets/edit_product_error_state.dart';
import '../widgets/edit_product_header.dart';
import '../widgets/product_form.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({super.key, this.productId});

  final String? productId;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _productsRepository = ProductsRepository();
  final _categoriesRepository = CategoriesRepository();

  Product? _product;
  List<Category>? _categories;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final productId = widget.productId;
    if (productId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No product ID provided';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _productsRepository.getProductById(productId),
        _categoriesRepository.getAllCategories(),
      ]);
      if (!mounted) return;
      final product = results[0] as Product?;
      setState(() {
        _product = product;
        _categories = results[1] as List<Category>;
        _isLoading = false;
        if (product == null) {
          _errorMessage = 'Product not found';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<bool> _handleSubmit(ProductFormData data) async {
    final product = _product;
    if (product == null) return false;

    try {
      var imagePath = product.imagePath;

      if (data.hasNewImage) {
        final newPath = await _productsRepository.uploadProductImage(
          bytes: data.pickedImageBytes!,
          filename: data.pickedImageName ?? 'image.jpg',
        );
        final oldPath = imagePath;
        imagePath = newPath;
        if (oldPath.isNotEmpty) {
          await _productsRepository.deleteProductImage(oldPath);
        }
      } else if (data.existingImagePath.isEmpty) {
        imagePath = '';
      }

      await _productsRepository.updateProduct(
        id: product.id,
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
          content: Text('Product updated successfully'),
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
          content: Text('Failed to update product: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditProductHeader(
              isLoading: _isLoading,
              hasProduct: _product != null,
              onBack: () => AppNav.pop(context),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              EditProductErrorState(message: _errorMessage!, onRetry: _load)
            else if (_product != null && _categories != null)
              AppCard(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: ProductForm(
                  product: _product,
                  categories: _categories!,
                  onSubmitted: _handleSubmit,
                  submitLabel: 'Update Product',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
