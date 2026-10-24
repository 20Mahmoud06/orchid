import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/product_model.dart';

class ProductFilters extends StatelessWidget {
  const ProductFilters({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.typeValue,
    this.onTypeChanged,
    this.activeValue,
    this.onActiveChanged,
    this.onReset,
  });

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ProductType? typeValue;
  final ValueChanged<ProductType?>? onTypeChanged;
  final bool? activeValue;
  final ValueChanged<bool?>? onActiveChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 780;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchField(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeDropdown(
                      value: typeValue,
                      onChanged: onTypeChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActiveDropdown(
                      value: activeValue,
                      onChanged: onActiveChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _ResetButton(onPressed: onReset),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _SearchField(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: _TypeDropdown(value: typeValue, onChanged: onTypeChanged),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: _ActiveDropdown(
                value: activeValue,
                onChanged: onActiveChanged,
              ),
            ),
            const SizedBox(width: 8),
            _ResetButton(onPressed: onReset),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        decoration: const InputDecoration(
          hintText: 'Search products by name or category...',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({this.value, this.onChanged});

  final ProductType? value;
  final ValueChanged<ProductType?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterDropdown<ProductType>(
      value: value,
      hint: 'All Types',
      onChanged: onChanged,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Types')),
        ...ProductType.values.map(
          (type) => DropdownMenuItem(value: type, child: Text(type.label)),
        ),
      ],
    );
  }
}

class _ActiveDropdown extends StatelessWidget {
  const _ActiveDropdown({this.value, this.onChanged});

  final bool? value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterDropdown<bool>(
      value: value,
      hint: 'Status: All',
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(value: null, child: Text('Status: All')),
        DropdownMenuItem(value: true, child: Text('Active')),
        DropdownMenuItem(value: false, child: Text('Inactive')),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    this.onChanged,
  });

  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: CustomText(text: hint, style: AppTextStyles.body),
          onChanged: onChanged,
          isDense: true,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          style: AppTextStyles.body,
          items: items,
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: const Text('Reset'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
