import 'package:flutter/material.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/info_panel.dart';
import 'package:orchid_admin/features/inspiration/presentation/widgets/inspiration_form/search_result_tile.dart';
import 'package:orchid_admin/features/products/domain/models/product_model.dart';

class SearchResultsBuilder extends StatelessWidget {
  const SearchResultsBuilder({
    super.key,
    required this.products,
    required this.selectedCount,
    required this.totalQuantity,
    required this.maxFlowerKinds,
    required this.maxFlowers,
    required this.searchQuery,
    required this.searchResults,
    required this.onAddFlower,
  });

  final List<Product> products;
  final int selectedCount;
  final int totalQuantity;
  final int maxFlowerKinds;
  final int maxFlowers;
  final String searchQuery;
  final List<Product> searchResults;
  final void Function(Product) onAddFlower;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const InfoPanel(
        icon: Icons.search_off,
        text:
            'No active flowers found. Add flower products from the Products '
            'page first.',
      );
    }

    if (selectedCount >= maxFlowerKinds) {
      return InfoPanel(
        icon: Icons.info_outline,
        text: 'You can add up to $maxFlowerKinds different kinds of flowers.',
      );
    }

    if (totalQuantity >= maxFlowers) {
      return InfoPanel(
        icon: Icons.info_outline,
        text: 'Your bouquet can contain up to $maxFlowers flowers.',
      );
    }

    final results = searchResults;
    if (results.isEmpty) {
      final query = searchQuery.trim();
      return InfoPanel(
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
          SearchResultTile(
            product: results[index],
            onTap: () => onAddFlower(results[index]),
          ),
        ],
      ],
    );
  }
}
