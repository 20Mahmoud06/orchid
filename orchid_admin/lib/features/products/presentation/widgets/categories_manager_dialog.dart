import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/models/category_model.dart';
import 'categories_list.dart';
import 'category_add_field.dart';
import 'delete_category_dialog.dart';
import 'rename_category_dialog.dart';

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
    await _run(() async {
      final category = await _repository.createCategory(name);
      if (!mounted) return;
      setState(() {
        _categories = [..._categories, category]
          ..sort((a, b) => a.name.compareTo(b.name));
        _nameController.clear();
      });
    }, closeOnSuccess: false);
  }

  Future<void> _renameCategory(Category category) async {
    final name = await showRenameCategoryDialog(context, category);
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
    final confirmed = await showDeleteCategoryDialog(context, category);
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
            CategoryAddField(
              controller: _nameController,
              enabled: !_busy,
              onAdd: _addCategory,
            ),
            const SizedBox(height: 16),
            CategoriesList(
              categories: _categories,
              isBusy: _busy,
              onRename: _renameCategory,
              onDelete: _deleteCategory,
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
