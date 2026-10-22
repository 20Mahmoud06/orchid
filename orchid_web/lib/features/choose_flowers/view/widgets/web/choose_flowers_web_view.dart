import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../bouquet/cubit/bouquet_cubit.dart';
import '../../../../bouquet/cubit/bouquet_state.dart';
import '../../../../catalog/cubit/catalog_cubit.dart';
import '../../../../catalog/cubit/catalog_state.dart';
import '../../../../favorites/cubit/favorites_cubit.dart';
import '../../../../favorites/cubit/favorites_state.dart';
import 'web_choose_flowers_widgets.dart';

/// Desktop-first choose flowers page (>= 768px): heading, search, category
/// tabs and a responsive flower grid with the floating view-bouquet bar.
class ChooseFlowersWebView extends StatelessWidget {
  final int selectedCategoryIndex;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onCategorySelected;

  const ChooseFlowersWebView({
    super.key,
    required this.selectedCategoryIndex,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final bouquetController = BouquetCubit.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'choose flowers',
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildCatalog(context, bouquetController),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: BlocBuilder<BouquetCubit, BouquetState>(
                      bloc: bouquetController,
                      builder: (context, bouquetState) {
                        final hasItems = bouquetController.totalCount > 0;
                        return AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          offset: hasItems ? Offset.zero : const Offset(0, 2),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: hasItems ? 1 : 0,
                            child: WebViewBouquetBar(
                              totalCount: bouquetController.totalCount,
                              totalPrice: bouquetController.totalPrice,
                              onTap: hasItems
                                  ? () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.viewBouquet,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, BouquetCubit bouquetController) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        final catalog = CatalogCubit.instance;
        final categories = catalog.flowerCategories;
        final categoryIndex = selectedCategoryIndex < categories.length
            ? selectedCategoryIndex
            : 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebFlowerSearchBar(onChanged: onSearchChanged),
            const SizedBox(height: 18),
            WebFlowerCategoryTabs(
              categories: categories,
              selectedIndex: categoryIndex,
              onCategorySelected: onCategorySelected,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _buildGrid(
                context,
                bouquetController,
                catalog,
                categories,
                categoryIndex,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    BouquetCubit bouquetController,
    CatalogCubit catalog,
    List<String> categories,
    int categoryIndex,
  ) {
    return BlocBuilder<BouquetCubit, BouquetState>(
      bloc: bouquetController,
      builder: (context, bouquetState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            if (!catalog.isLoaded && catalog.error == null) {
              return const WebFlowerCatalogMessage(
                message: 'loading flowers...',
                showLoader: true,
              );
            }
            if (catalog.error != null && !catalog.isLoaded) {
              return WebFlowerCatalogMessage(
                message:
                    'Could not load flowers.\nCheck your connection and try again.',
                onRetry: () => catalog.load(force: true),
              );
            }

            final query = searchQuery.toLowerCase();
            final selectedCategory = categories[categoryIndex].toLowerCase();
            final filteredFlowers = catalog.flowers.where((flower) {
              final matchesCategory =
                  categoryIndex == 0 ||
                  flower.category.toLowerCase() == selectedCategory;
              final matchesSearch =
                  query.isEmpty || flower.name.toLowerCase().contains(query);
              return matchesCategory && matchesSearch;
            }).toList();

            if (filteredFlowers.isEmpty) {
              return WebFlowerCatalogMessage(
                message: query.isEmpty
                    ? 'No flowers in this category yet'
                    : 'No flowers found with this name',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 300,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
              ),
              itemCount: filteredFlowers.length,
              itemBuilder: (context, index) {
                final flower = filteredFlowers[index];
                return WebFlowerGridCard(
                  flower: flower,
                  isFavorite: FavoritesCubit.instance.isFlowerFavorite(
                    flower.id,
                  ),
                  quantity: bouquetController.getQuantity(flower.id),
                  onFavoriteToggle: () =>
                      FavoritesCubit.instance.toggleFlowerFavorite(flower.id),
                  onIncrement: () =>
                      bouquetController.incrementQuantity(flower.id),
                  onDecrement: () =>
                      bouquetController.decrementQuantity(flower.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
