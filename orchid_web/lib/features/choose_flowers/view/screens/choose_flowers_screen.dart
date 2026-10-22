import 'package:flutter/material.dart';

import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../widgets/choose_flowers_mobile_view.dart';
import '../widgets/web/choose_flowers_web_view.dart';

/// Choose Flowers screen matching the Orchid Figma design.
class ChooseFlowersScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ChooseFlowersScreen({super.key, this.onBackPressed});

  @override
  State<ChooseFlowersScreen> createState() => _ChooseFlowersScreenState();
}

class _ChooseFlowersScreenState extends State<ChooseFlowersScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    CatalogCubit.instance.load();
  }

  void _handleSearchChanged(String query) {
    setState(() => _searchQuery = query.trim());
  }

  void _handleCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide flower catalog
        // with the search bar, category tabs and a responsive grid. Narrow
        // viewports keep the untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return ChooseFlowersWebView(
            selectedCategoryIndex: _selectedCategoryIndex,
            searchQuery: _searchQuery,
            onSearchChanged: _handleSearchChanged,
            onCategorySelected: _handleCategorySelected,
          );
        }
        return ChooseFlowersMobileView(
          onBackPressed: widget.onBackPressed,
          selectedCategoryIndex: _selectedCategoryIndex,
          searchQuery: _searchQuery,
          onSearchChanged: _handleSearchChanged,
          onCategorySelected: _handleCategorySelected,
        );
      },
    );
  }
}
