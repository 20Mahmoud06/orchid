import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orchid_admin/features/inspiration/domain/models/inspiration_model.dart';
import 'package:orchid_admin/features/inspiration/presentation/models/inspiration_form_data.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/build_search_results.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/info_panel.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/section_hint.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/selected_flower.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/selected_flower_tile.dart';
import 'package:orchid_admin/features/products/domain/models/product_model.dart';
import 'package:orchid_admin/features/products/presentation/widgets/product_form_section_title.dart';
import 'package:orchid_admin/features/products/presentation/widgets/product_form_text_field.dart';
import 'package:orchid_admin/features/products/presentation/widgets/product_image_uploader.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/custom_text.dart';

export 'inspiration_form/selected_flower.dart';

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
  final List<SelectedFlower> _selectedFlowers = [];

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
    final selectedIds =
        _selectedFlowers.map((flower) => flower.product.id).toSet();
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
      _selectedFlowers.add(SelectedFlower(product));
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeFlower(SelectedFlower flower) {
    setState(() {
      _selectedFlowers.remove(flower);
      flower.dispose();
    });
  }

  void _handleQuantityChanged(SelectedFlower flower, String value) {
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
            const InfoPanel(
              icon: Icons.local_florist_outlined,
              text:
                  'No flowers selected yet. Search above and tap a flower '
                  'to add it.',
            )
          else
            for (final flower in _selectedFlowers)
              SelectedFlowerTile(
                flower: flower,
                onRemove: () => _removeFlower(flower),
                onQuantityChanged: (value) =>
                    _handleQuantityChanged(flower, value),
                quantityValidator: _quantityValidator,
                maxFlowers: _maxFlowers,
              ),
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
          const SectionHint(
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
    return SearchResultsBuilder(
      products: widget.products,
      selectedCount: _selectedFlowers.length,
      totalQuantity: _totalQuantity,
      maxFlowerKinds: _maxFlowerKinds,
      maxFlowers: _maxFlowers,
      searchQuery: _searchQuery,
      searchResults: _searchResults,
      onAddFlower: _addFlower,
    );
  }

  static String? _quantityValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 1) return 'Invalid qty';
    if (parsed > _maxFlowers) return 'Max $_maxFlowers';
    return null;
  }
}

