import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/category_model.dart';

class CategoriesList extends StatelessWidget {
  const CategoriesList({
    super.key,
    required this.categories,
    required this.isBusy,
    required this.onRename,
    required this.onDelete,
  });

  final List<Category> categories;
  final bool isBusy;
  final ValueChanged<Category> onRename;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CustomText(
          text: 'No categories yet. Add one above.',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: categories.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: CustomText(text: category.name, style: AppTextStyles.body),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isBusy ? null : () => onRename(category),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Rename',
                  color: AppColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: isBusy ? null : () => onDelete(category),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete',
                  color: AppColors.error,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
