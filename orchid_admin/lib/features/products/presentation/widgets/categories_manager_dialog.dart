import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/models/category_model.dart';

class CategoriesManagerDialog extends StatefulWidget {
  const CategoriesManagerDialog({super.key, required this.categories});

  final List<Category> categories;

  @override
  State<CategoriesManagerDialog> createState() =>
      _CategoriesManagerDialogState();
}

class _CategoriesManagerDialogState extends State<CategoriesManagerDialog> {
  final _repository = CategoriesRepository();
  final _nameController = TextEditingController();
  late List<Category> _categories;
  bool _busy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _categories = List<Category>.from(widget.categories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool closeOnSuccess = true,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      _changed = true;
      if (closeOnSuccess && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        setState(() => _busy = false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await _run(
      () async {
        final category = await _repository.createCategory(name);
        if (!mounted) return;
        setState(() {
          _categories = [..._categories, category]
            ..sort((a, b) => a.name.compareTo(b.name));
          _nameController.clear();
        });
      },
      closeOnSuccess: false,
    );
  }

  Future<void> _renameCategory(Category category) async {
    final controller = TextEditingController(text: category.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == category.name) return;

    await _run(() async {
      await _repository.updateCategory(category.id, name);
      if (!mounted) return;
      setState(() {
        _categories = [
          for (final item in _categories)
            if (item.id == category.id)
              Category(id: item.id, name: name, createdAt: item.createdAt)
            else
              item,
        ]..sort((a, b) => a.name.compareTo(b.name));
      });
    });
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Products using "${category.name}" will become uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _run(() async {
      await _repository.deleteCategory(category.id);
      if (!mounted) return;
      setState(() {
        _categories = _categories.where((c) => c.id != category.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage categories'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    enabled: !_busy,
                    onSubmitted: (_) => _addCategory(),
                    decoration: const InputDecoration(
                      labelText: 'New category name',
                      hintText: 'e.g. Orchids',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _busy ? null : _addCategory,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add category',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No categories yet. Add one above.',
                  style: AppTextStyles.bodySecondary,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(category.name, style: AppTextStyles.body),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed:
                                _busy ? null : () => _renameCategory(category),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Rename',
                            color: AppColors.textSecondary,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed:
                                _busy ? null : () => _deleteCategory(category),
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
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_changed),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
