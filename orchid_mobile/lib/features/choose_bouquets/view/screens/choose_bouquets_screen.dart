import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../features/bouquet/cubit/bouquet_state.dart';
import '../../../../features/cart/cubit/cart_cubit.dart';
import '../../../../features/cart/models/cart_item.dart';
import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../../../../features/catalog/cubit/catalog_state.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../../../../features/favorites/cubit/favorites_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../models/bouquet_item.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../widgets/bouquet_grid_card.dart';
import '../widgets/bouquet_search_bar.dart';
import '../widgets/view_bouquet_bar.dart';

/// Choose Bouquets screen matching the Orchid Figma design.
class ChooseBouquetScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ChooseBouquetScreen({
    super.key,
    this.onBackPressed,
  });

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

  /// The tab list grows as the catalog loads, so a selection from a previous
  /// (longer) list falls back to "All bouquets" instead of going out of range.
  int _categoryIndex(List<String> categories) =>
      _selectedCategoryIndex < categories.length ? _selectedCategoryIndex : 0;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar.orchid(
                  title: 'choose bouquets',
                  onBackPressed: widget.onBackPressed,
                  actions: [
                    AppBarAction(
                      icon: Icons.favorite,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.favorites),
                    ),
                    AppBarAction(
                      icon: Icons.shopping_cart,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: BlocBuilder<CatalogCubit, CatalogState>(
                      bloc: CatalogCubit.instance,
                      builder: (context, catalogState) {
                        final catalog = CatalogCubit.instance;
                        final categories = catalog.bouquetCategories;
                        final categoryIndex = _categoryIndex(categories);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            BouquetSearchBar(
                              onChanged: (query) {
                                setState(() {
                                  _searchQuery = query.trim();
                                });
                              },
                            ),
                            SizedBox(height: 10.h),
                            FlowerCategoryTabs(
                              categories: categories,
                              selectedIndex: categoryIndex,
                              onCategorySelected: (index) {
                                setState(
                                    () => _selectedCategoryIndex = index);
                              },
                            ),
                            SizedBox(height: 16.h),
                            Expanded(
                              child: BlocBuilder<BouquetCubit, BouquetState>(
                                bloc: _bouquetController,
                                builder: (context, bouquetState) {
                                  return BlocBuilder<FavoritesCubit,
                                      FavoritesState>(
                                    bloc: _favoritesController,
                                    builder: (context, favoritesState) {
                                      if (!catalog.isLoaded &&
                                          catalog.error == null) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (catalog.error != null &&
                                          !catalog.isLoaded) {
                                        return CatalogErrorView(
                                          message:
                                              'Could not load bouquets.\nCheck your connection and try again.',
                                          onRetry: () =>
                                              catalog.load(force: true),
                                        );
                                      }

                                      final searchQuery =
                                          _searchQuery.toLowerCase();
                                      final selectedCategory = categories[
                                              categoryIndex]
                                          .toLowerCase();
                                      final filteredBouquets =
                                          catalog.bouquets.where((bouquet) {
                                        final matchesCategory = categoryIndex ==
                                                0 ||
                                            bouquet.category.toLowerCase() ==
                                                selectedCategory;
                                        final matchesSearch =
                                            searchQuery.isEmpty ||
                                                bouquet.name
                                                    .toLowerCase()
                                                    .contains(searchQuery);
                                        return matchesCategory &&
                                            matchesSearch;
                                      }).toList();

                                      if (filteredBouquets.isEmpty) {
                                        return Center(
                                          child: Text(
                                            searchQuery.isEmpty
                                                ? 'No bouquets in this category yet'
                                                : 'No bouquets found with this name',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        // 3. Increased bottom padding to clear the overhanging bottom cards
                                        padding: EdgeInsets.only(bottom: 100.h),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10.w,
                                          mainAxisSpacing: 14.h,
                                          // 4. Changed from 0.72 to 0.68 to make cards taller!
                                          childAspectRatio: 0.68,
                                        ),
                                        itemCount: filteredBouquets.length,
                                        itemBuilder: (context, index) {
                                          final BouquetItem bouquet =
                                              filteredBouquets[index];
                                          return BouquetGridCard(
                                            bouquet: bouquet,
                                            isFavorite: _favoritesController
                                                .isBouquetFavorite(bouquet.id),
                                            quantity: _bouquetController
                                                .getQuantity(bouquet.id),
                                            onFavoriteToggle: () =>
                                                _toggleFavorite(bouquet.id),
                                            onIncrement: () =>
                                                _bouquetController
                                                    .incrementQuantity(
                                                        bouquet.id),
                                            onDecrement: () =>
                                                _bouquetController
                                                    .decrementQuantity(
                                                        bouquet.id),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            BlocBuilder<BouquetCubit, BouquetState>(
              bloc: _bouquetController,
              builder: (context, bouquetState) {
                // Ready bouquets live in the same quantity map as the flowers
                // but are not part of [totalCount] (which only folds the
                // selected flowers), so count them here too so the view-bouquet
                // bar appears as soon as a bouquet is added.
                final readyBouquetCount = _bouquetController
                    .selectedReadyBouquets
                    .fold<int>(
                      0,
                      (sum, bouquet) =>
                          sum + _bouquetController.getQuantity(bouquet.id),
                    );
                final totalItems =
                    _bouquetController.totalCount + readyBouquetCount;
                final hasItems = totalItems > 0;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 12.w,
                  right: 12.w,
                  bottom: hasItems ? 16.h : -100.h,
                  child: ViewBouquetBar(
                    totalCount: totalItems,
                    totalPrice: _bouquetController.totalPrice,
                    onTap: hasItems ? () => _openSelection(context) : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}