import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import '../models/product_form_data.dart';
import 'product_form_image_section.dart';
import 'product_form_information_section.dart';
import 'product_form_status_section.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    this.product,
    required this.categories,
    required this.onSubmitted,
    this.submitLabel = 'Save Product',
  });

  final Product? product;
  final List<Category> categories;
  final Future<bool> Function(ProductFormData data) onSubmitted;
  final String submitLabel;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  late ProductType _type;
  String? _categoryId;
  bool _isActive = true;
  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _isSubmitting = false;

  bool get _isCreating => widget.product == null;
  String get _existingImage => widget.product?.imagePath ?? '';

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : _formatPrice(product.price),
    );
    _type = product?.type ?? ProductType.flower;
    _isActive = product?.isActive ?? true;

    final productCategoryId = product?.categoryId;
    final knownCategory = widget.categories.any(
      (category) => category.id == productCategoryId,
    );
    _categoryId = knownCategory ? productCategoryId : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  static String _formatPrice(double price) {
    final rounded = price.roundToDouble();
    return rounded == price ? rounded.toStringAsFixed(0) : price.toString();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isCreating && _pickedBytes == null && _existingImage.isEmpty) {
      _showSnack('Please select a product image', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final data = ProductFormData(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      type: _type,
      categoryId: _categoryId,
      isActive: _isActive,
      existingImagePath: _existingImage,
      pickedImageBytes: _pickedBytes,
      pickedImageName: _pickedName,
    );

    await widget.onSubmitted(data);
    if (mounted) {
      setState(() => _isSubmitting = false);
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductFormInformationSection(
            nameController: _nameController,
            priceController: _priceController,
            categories: widget.categories,
            type: _type,
            categoryId: _categoryId,
            onTypeChanged: (value) => setState(() => _type = value),
            onCategoryChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: 32),
          ProductFormStatusSection(
            isActive: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 32),
          ProductFormImageSection(
            pickedBytes: _pickedBytes,
            pickedFileName: _pickedName,
            existingImageUrl: _pickedBytes == null && _existingImage.isNotEmpty
                ? widget.product!.imageUrl
                : null,
            isCreating: _isCreating,
            onImagePicked: (bytes, name) {
              setState(() {
                _pickedBytes = bytes;
                _pickedName = name;
              });
            },
            onImageRemoved: () {
              setState(() {
                _pickedBytes = null;
                _pickedName = null;
              });
            },
          ),
          const SizedBox(height: 32),
          AppButton(
            label: _isSubmitting ? 'Saving...' : widget.submitLabel,
            icon: _isSubmitting ? null : (_isCreating ? Icons.add : Icons.save),
            isExpanded: true,
            onPressed: _isSubmitting ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}
