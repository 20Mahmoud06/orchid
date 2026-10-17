import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import './product_image_uploader.dart';

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

class ProductFormData {
  const ProductFormData({
    required this.name,
    required this.price,
    required this.type,
    required this.categoryId,
    required this.isActive,
    required this.existingImagePath,
    this.pickedImageBytes,
    this.pickedImageName,
  });

  final String name;
  final double price;
  final ProductType type;
  final String? categoryId;
  final bool isActive;
  final String existingImagePath;
  final Uint8List? pickedImageBytes;
  final String? pickedImageName;

  bool get hasNewImage => pickedImageBytes != null;
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
    final knownCategory =
        widget.categories.any((category) => category.id == productCategoryId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  String get _existingImage => widget.product?.imagePath ?? '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Product Information', Icons.info_outline),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Product Name',
            controller: _nameController,
            hint: 'Enter product name',
            isRequired: true,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTypeDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildPriceField()),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Product Status', Icons.assignment_outlined),
          const SizedBox(height: 24),
          _buildToggleRow(
            title: 'Active Product',
            description: 'Visible in the mobile store',
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value ?? false),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Product Image', Icons.image_outlined),
          const SizedBox(height: 20),
          ProductImageUploader(
            pickedBytes: _pickedBytes,
            pickedFileName: _pickedName,
            existingImageUrl:
                _pickedBytes == null && _existingImage.isNotEmpty
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Images are stored in Supabase Storage and displayed directly in the Orchid mobile app.',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _isSubmitting ? 'Saving...' : widget.submitLabel,
                  icon: _isSubmitting
                      ? null
                      : (_isCreating ? Icons.add : Icons.save),
                  isExpanded: true,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.label),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*',
                  style: TextStyle(color: AppColors.error, fontSize: 14)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return _buildDropdownField(
      label: 'Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ProductType>(
            value: _type,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down,
                color: AppColors.textSecondary),
            style: AppTextStyles.body,
            items: ProductType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdownField(
      label: 'Category',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _categoryId,
            isExpanded: true,
            hint: const Text('None'),
            icon: const Icon(Icons.arrow_drop_down,
                color: AppColors.textSecondary),
            style: AppTextStyles.body,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('None'),
              ),
              ...widget.categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Price (EGP)', style: AppTextStyles.label),
            const SizedBox(width: 4),
            const Text('*',
                style: TextStyle(color: AppColors.error, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) return 'Price cannot be negative';
            return null;
          },
          decoration: InputDecoration(
            hintText: '750',
            hintStyle: AppTextStyles.bodySecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(description, style: AppTextStyles.caption),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.white,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}
