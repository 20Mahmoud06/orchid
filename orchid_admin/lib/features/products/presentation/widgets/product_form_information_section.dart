import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import 'product_form_dropdown_field.dart';
import 'product_form_section_title.dart';
import 'product_form_text_field.dart';

class ProductFormInformationSection extends StatelessWidget {
  const ProductFormInformationSection({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.categories,
    required this.type,
    required this.categoryId,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final List<Category> categories;
  final ProductType type;
  final String? categoryId;
  final ValueChanged<ProductType> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFormSectionTitle(
          title: 'Product Information',
          icon: Icons.info_outline,
        ),
        const SizedBox(height: 24),
        ProductFormTextField(
          label: 'Product Name',
          controller: nameController,
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
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return ProductFormDropdownField<ProductType>(
      label: 'Type',
      value: type,
      items: ProductType.values
          .map(
            (productType) => DropdownMenuItem(
              value: productType,
              child: Text(productType.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onTypeChanged(value);
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return ProductFormDropdownField<String>(
      label: 'Category',
      value: categoryId,
      hint: 'None',
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('None')),
        ...categories.map(
          (category) => DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          ),
        ),
      ],
      onChanged: onCategoryChanged,
    );
  }

  Widget _buildPriceField() {
    return ProductFormTextField(
      label: 'Price (EGP)',
      controller: priceController,
      hint: '750',
      isRequired: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        final parsed = double.tryParse(value);
        if (parsed == null || parsed < 0) {
          return 'Price cannot be negative';
        }
        return null;
      },
    );
  }
}
