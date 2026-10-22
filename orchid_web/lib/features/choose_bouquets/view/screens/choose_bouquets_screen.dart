import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../features/cart/cubit/cart_cubit.dart';
import '../../../../features/cart/models/cart_item.dart';
import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../widgets/choose_bouquets_mobile_view.dart';
import '../widgets/web/choose_bouquets_web_view.dart';

/// Choose Bouquets screen matching the Orchid Figma design.
///
/// The mobile and desktop layouts live in separate widget files; this screen
/// owns the search/category state and the selection actions.
class ChooseBouquetScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ChooseBouquetScreen({super.key, this.onBackPressed});

  @override
  State<ChooseBouquetScreen> createState() => _ChooseBouquetScreenState();
}

class _ChooseBouquetScreenState extends State<ChooseBouquetScreen> {
  final _favoritesController = FavoritesCubit.instance;
  final _bouquetController = BouquetCubit.instance;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    CatalogCubit.instance.load();
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
  }

  void _search(String query) {
    setState(() => _searchQuery = query.trim());
  }

  void _toggleFavorite(String bouquetId) {
    _favoritesController.toggleBouquetFavorite(bouquetId);
  }

  /// The message typed in the home celebration section, or null when the
  /// user is not shopping for an occasion.
  String? _pendingOccasionMessage() {
    final checkout = CheckoutCubit.instance;
    if (!checkout.hasMessage) return null;
    final message = checkout.messageText.trim();
    return message.isEmpty ? null : message;
  }

  /// Bottom bar action. When ready bouquets are selected they are added to the
  /// cart (and the cart is opened) instead of opening the View Bouquet preview,
  /// which only makes sense for a custom flower arrangement. A selection that
  /// holds only custom flowers keeps the existing preview flow.
  void _openSelection(BuildContext context) {
    final readyBouquets = _bouquetController.selectedReadyBouquets;
    if (readyBouquets.isEmpty) {
      Navigator.pushNamed(context, AppRoutes.viewBouquet);
      return;
    }

    // A message typed in the home "what are you celebrating?" flow rides
    // along with the bouquet it was written for: the cart shows it under the
    // line and the message screen pre-fills with it.
    final occasionMessage = _pendingOccasionMessage();

    CartCubit.instance.addItems([
      for (final bouquet in readyBouquets)
        CartItem(
          id: bouquet.id,
          name: bouquet.name,
          price: bouquet.price,
          imagePath: bouquet.imagePath,
          quantity: _bouquetController.getQuantity(bouquet.id),
          message: occasionMessage,
        ),
    ]);
    _bouquetController.clearReadyBouquets();
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide bouquet catalog
        // with the search bar, category tabs and a responsive grid. Narrow
        // viewports keep the untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return ChooseBouquetsWebView(
            searchQuery: _searchQuery,
            selectedCategoryIndex: _selectedCategoryIndex,
            onSearchChanged: _search,
            onCategorySelected: _selectCategory,
            onOpenSelection: () => _openSelection(context),
            onFavoriteToggle: _toggleFavorite,
            onIncrement: _bouquetController.incrementQuantity,
            onDecrement: _bouquetController.decrementQuantity,
          );
        }
        return ChooseBouquetsMobileView(
          searchQuery: _searchQuery,
          selectedCategoryIndex: _selectedCategoryIndex,
          onBackPressed: widget.onBackPressed,
          onSearchChanged: _search,
          onCategorySelected: _selectCategory,
          onOpenSelection: () => _openSelection(context),
          onFavoriteToggle: _toggleFavorite,
          onIncrement: _bouquetController.incrementQuantity,
          onDecrement: _bouquetController.decrementQuantity,
        );
      },
    );
  }
}
