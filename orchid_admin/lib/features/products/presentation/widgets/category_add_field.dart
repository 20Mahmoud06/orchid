import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CategoryAddField extends StatelessWidget {
  const CategoryAddField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onAdd,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            onSubmitted: (_) => onAdd(),
            decoration: const InputDecoration(
              labelText: 'New category name',
              hintText: 'e.g. Orchids',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: enabled ? onAdd : null,
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add category',
          color: AppColors.primary,
        ),
      ],
    );
  }
}
