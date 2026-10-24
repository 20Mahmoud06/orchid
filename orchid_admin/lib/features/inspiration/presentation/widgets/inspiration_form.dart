import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../products/domain/models/product_model.dart';
import '../../../products/presentation/widgets/product_form_section_title.dart';
import '../../../products/presentation/widgets/product_form_text_field.dart';
import '../../../products/presentation/widgets/product_image_uploader.dart';
import '../../domain/models/inspiration_model.dart';
import '../models/inspiration_form_data.dart';

class InspirationForm extends StatefulWidget {
  const InspirationForm({
    super.key,
    required this.products,
    required this.onSubmitted,
  });

  final List<Product> products;
  final Future<bool> Function(InspirationFormData data) onSubmitted;

  @override
  State<InspirationForm> createState() => _InspirationFormState();
}

class _InspirationFormState extends State<InspirationForm> {
  static const int _maxFlowerKinds = 7;
  static const int _maxFlowers = 15;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<_SelectedFlower> _selectedFlowers = [];

  String _searchQuery = '';
  Uint8List? _imageBytes;
  String? _imageName;
  Uint8List? _avatarBytes;
  String? _avatarName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    for (final flower in _selectedFlowers) {
      flower.dispose();
    }
    super.dispose();
  }

  List<Product> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    final selectedIds = _selectedFlowers
        .map((flower) => flower.product.id)
        .toSet();
    return widget.products
        .where((product) => !selectedIds.contains(product.id))
        .where(
          (product) =>
              query.isEmpty || product.name.toLowerCase().contains(query),
        )
        .take(6)
        .toList();
  }

  int get _totalQuantity => _selectedFlowers.fold(
    0,
    (sum, flower) => sum + (int.tryParse(flower.quantity.text) ?? 0),
  );

  void _addFlower(Product product) {
    if (_selectedFlowers.length >= _maxFlowerKinds) {
      _showSnack(
        'You can add up to $_maxFlowerKinds different kinds of flowers',
        isError: true,
      );
      return;
    }
    if (_totalQuantity >= _maxFlowers) {
      _showSnack(
        'Your bouquet can contain up to $_maxFlowers flowers',
        isError: true,
      );
      return;
    }

    setState(() {
      _selectedFlowers.add(_SelectedFlower(product));
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeFlower(_SelectedFlower flower) {
    setState(() {
      _selectedFlowers.remove(flower);
      flower.dispose();
    });
  }

  void _handleQuantityChanged(_SelectedFlower flower, String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) {
      final otherQuantity = _totalQuantity - parsed;
      final allowed = _maxFlowers - otherQuantity;
      if (parsed > allowed) {
        final clamped = allowed.clamp(1, _maxFlowers);
        final text = '$clamped';
        flower.quantity.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        _showSnack(
          'Your bouquet can contain up to $_maxFlowers flowers',
          isError: true,
        );
      }
    }
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedFlowers.isEmpty) {
      _showSnack('Please select at least one flower', isError: true);
      return;
    }
    if (_selectedFlowers.length > _maxFlowerKinds) {
      _showSnack(
        'You can add up to $_maxFlowerKinds different kinds of flowers',
        isError: true,
      );
      return;
    }
    if (_totalQuantity > _maxFlowers) {
      _showSnack(
        'Your bouquet can contain up to $_maxFlowers flowers',
        isError: true,
      );
      return;
    }
    if (_imageBytes == null) {
      _showSnack('Please select a bouquet photo', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final data = InspirationFormData(
      displayName: name.isEmpty ? null : name,
      ingredients: [
        for (final flower in _selectedFlowers)
          InspirationIngredient(
            productId: flower.product.id,
            name: flower.product.name,
            quantity: int.parse(flower.quantity.text.trim()),
            unitPrice: flower.product.price.round(),
          ),
      ],
      imageBytes: _imageBytes!,
      imageName: _imageName ?? 'bouquet.jpg',
      avatarBytes: _avatarBytes,
      avatarName: _avatarName,
    );

    await widget.onSubmitted(data);
    if (mounted) setState(() => _isSubmitting = false);
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
          const ProductFormSectionTitle(
            title: 'Bouquet Details',
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 24),
          ProductFormTextField(
            label: 'Creator Name',
            controller: _nameController,
            hint: 'e.g. Nour or Orchid Studio',
          ),
          const SizedBox(height: 32),
          const ProductFormSectionTitle(
            title: 'Flowers',
            icon: Icons.local_florist_outlined,
          ),
          const SizedBox(height: 8),
          const CustomText(
            text:
                'Pick real flowers from your Products catalog. Shoppers can '
                'rebuild this bouquet with "Looks Good" using these flowers '
                'and prices.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),
          ProductFormTextField(
            label: 'Search Flowers',
            controller: _searchController,
            hint: 'Search by flower name...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          _buildSearchResults(),
          const SizedBox(height: 24),
          Row(
            children: [
              const CustomText(
                text: 'Selected Flowers',
                style: AppTextStyles.label,
              ),
              const Spacer(),
              CustomText(
                text:
                    '${_selectedFlowers.length}/$_maxFlowerKinds kinds · '
                    '$_totalQuantity/$_maxFlowers flowers',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedFlowers.isEmpty)
            const _InfoPanel(
              icon: Icons.local_florist_outlined,
              text:
                  'No flowers selected yet. Search above and tap a flower '
                  'to add it.',
            )
          else
            for (final flower in _selectedFlowers) _buildSelectedFlower(flower),
          const SizedBox(height: 12),
          const ProductFormSectionTitle(
            title: 'Bouquet Photo',
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 20),
          ProductImageUploader(
            pickedBytes: _imageBytes,
            pickedFileName: _imageName,
            isCreating: true,
            dropzoneLabel: 'Click to select a bouquet photo or ',
            onImagePicked: (bytes, name) {
              setState(() {
                _imageBytes = bytes;
                _imageName = name;
              });
            },
            onImageRemoved: () {
              setState(() {
                _imageBytes = null;
                _imageName = null;
              });
            },
          ),
          const SizedBox(height: 12),
          const _SectionHint(
            text: 'This photo is shown on the web and mobile Inspiration tabs.',
          ),
          const SizedBox(height: 32),
          const ProductFormSectionTitle(
            title: 'Creator Photo (optional)',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          ProductImageUploader(
            pickedBytes: _avatarBytes,
            pickedFileName: _avatarName,
            isCreating: true,
            dropzoneLabel: 'Click to select a creator photo or ',
            onImagePicked: (bytes, name) {
              setState(() {
                _avatarBytes = bytes;
                _avatarName = name;
              });
            },
            onImageRemoved: () {
              setState(() {
                _avatarBytes = null;
                _avatarName = null;
              });
            },
          ),
          const SizedBox(height: 32),
          AppButton(
            label: _isSubmitting ? 'Adding...' : 'Add Inspiration',
            icon: _isSubmitting ? null : Icons.add,
            isExpanded: true,
            onPressed: _isSubmitting ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (widget.products.isEmpty) {
      return const _InfoPanel(
        icon: Icons.search_off,
        text:
            'No active flowers found. Add flower products from the Products '
            'page first.',
      );
    }

    if (_selectedFlowers.length >= _maxFlowerKinds) {
      return _InfoPanel(
        icon: Icons.info_outline,
        text: 'You can add up to $_maxFlowerKinds different kinds of flowers.',
      );
    }

    if (_totalQuantity >= _maxFlowers) {
      return _InfoPanel(
        icon: Icons.info_outline,
        text: 'Your bouquet can contain up to $_maxFlowers flowers.',
      );
    }

    final results = _searchResults;
    if (results.isEmpty) {
      final query = _searchQuery.trim();
      return _InfoPanel(
        icon: Icons.search_off,
        text: query.isEmpty
            ? 'All available flowers are already selected.'
            : 'No flowers match "$query".',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < results.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          _buildSearchResult(results[index]),
        ],
      ],
    );
  }

  Widget _buildSearchResult(Product product) {
    return InkWell(
      onTap: () => _addFlower(product),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _FlowerThumbnail(product: product),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: product.name, style: AppTextStyles.body),
                  if (product.categoryName != null &&
                      product.categoryName!.isNotEmpty)
                    CustomText(
                      text: product.categoryName!,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            CustomText(
              text: 'EGP ${product.price.round()}',
              style: AppTextStyles.label,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFlower(_SelectedFlower flower) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _FlowerThumbnail(product: flower.product),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: flower.product.name,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: 'EGP ${flower.product.price.round()}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: TextFormField(
              controller: flower.quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (value) => _handleQuantityChanged(flower, value),
              validator: _quantityValidator,
              decoration: InputDecoration(
                labelText: 'Qty',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeFlower(flower),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Remove flower',
          ),
        ],
      ),
    );
  }

  static String? _quantityValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 1) return 'Invalid qty';
    if (parsed > _maxFlowers) return 'Max $_maxFlowers';
    return null;
  }
}

class _SelectedFlower {
  _SelectedFlower(this.product) : quantity = TextEditingController(text: '1');

  final Product product;
  final TextEditingController quantity;

  void dispose() => quantity.dispose();
}

class _FlowerThumbnail extends StatelessWidget {
  const _FlowerThumbnail({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: product.imagePath.isEmpty
            ? const ColoredBox(
                color: AppColors.border,
                child: Icon(
                  Icons.local_florist_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              )
            : Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: AppColors.border,
                  child: Icon(
                    Icons.local_florist_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(text: text, style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CustomText(text: text, style: AppTextStyles.caption),
        ),
      ],
    );
  }
}
