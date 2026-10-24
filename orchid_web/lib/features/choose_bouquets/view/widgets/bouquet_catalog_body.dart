import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../../bouquet/cubit/bouquet_cubit.dart';
import '../../../bouquet/cubit/bouquet_state.dart';
import '../../../catalog/cubit/catalog_cubit.dart';
import '../../../choose_flowers/view/widgets/web/web_choose_flowers_widgets.dart';
import '../../../favorites/cubit/favorites_cubit.dart';
import '../../../favorites/cubit/favorites_state.dart';
import '../../models/bouquet_item.dart';
import 'bouquet_grid_card.dart';
import 'web/web_choose_bouquets_widgets.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Loading / error / empty / bouquet grid, shared by the mobile and web
/// layouts of the choose bouquets screen. The web layout uses the fixed-pixel
/// counterparts of the mobile widgets.
class BouquetCatalogBody extends StatelessWidget {
  final bool web;
  final String searchQuery;
  final int categoryIndex;
  final List<String> categories;
  final CatalogCubit catalog;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  const BouquetCatalogBody({
    super.key,
    required this.web,
    required this.searchQuery,
    required this.categoryIndex,
    required this.categories,
    required this.catalog,
    required this.onFavoriteToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BouquetCubit, BouquetState>(
      bloc: BouquetCubit.instance,
      builder: (context, bouquetState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            if (!catalog.isLoaded && catalog.error == null) {
              return web
                  ? const WebFlowerCatalogMessage(
                      message: 'loading bouquets...',
                      showLoader: true,
                    )
                  : const Center(child: CircularProgressIndicator());
            }
            if (catalog.error != null && !catalog.isLoaded) {
              return web
                  ? WebFlowerCatalogMessage(
                      message:
                          'Could not load bouquets.\nCheck your connection and try again.',
                      onRetry: () => catalog.load(force: true),
                    )
                  : CatalogErrorView(
                      message:
                          'Could not load bouquets.\nCheck your connection and try again.',
                      onRetry: () => catalog.load(force: true),
                    );
            }

            final query = searchQuery.toLowerCase();
            final selectedCategory = categories[categoryIndex].toLowerCase();
            final filteredBouquets = catalog.bouquets.where((bouquet) {
              final matchesCategory =
                  categoryIndex == 0 ||
                  bouquet.category.toLowerCase() == selectedCategory;
              final matchesSearch =
                  query.isEmpty || bouquet.name.toLowerCase().contains(query);
              return matchesCategory && matchesSearch;
            }).toList();

            if (filteredBouquets.isEmpty) {
              final message = query.isEmpty
                  ? 'No bouquets in this category yet'
                  : 'No bouquets found with this name';
              return web
                  ? WebFlowerCatalogMessage(message: message)
                  : Center(
                      child: CustomText(
                        text: message,
                        textAlign: TextAlign.center,
                        fontSize: 14.sp,
                        textColor: AppColors.black,
                      ),
                    );
            }

            if (web) {
              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisExtent: 300,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                ),
                itemCount: filteredBouquets.length,
                itemBuilder: (context, index) {
                  final BouquetItem bouquet = filteredBouquets[index];
                  return WebBouquetGridCard(
                    bouquet: bouquet,
                    isFavorite: FavoritesCubit.instance.isBouquetFavorite(
                      bouquet.id,
                    ),
                    quantity: BouquetCubit.instance.getQuantity(bouquet.id),
                    onFavoriteToggle: () => onFavoriteToggle(bouquet.id),
                    onIncrement: () => onIncrement(bouquet.id),
                    onDecrement: () => onDecrement(bouquet.id),
                  );
                },
              );
            }

            return GridView.builder(
              // 3. Increased bottom padding to clear the overhanging bottom cards
              padding: EdgeInsets.only(bottom: 100.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 14.h,
                // 4. Changed from 0.72 to 0.68 to make cards taller!
                childAspectRatio: 0.68,
              ),
              itemCount: filteredBouquets.length,
              itemBuilder: (context, index) {
                final BouquetItem bouquet = filteredBouquets[index];
                return BouquetGridCard(
                  bouquet: bouquet,
                  isFavorite: FavoritesCubit.instance.isBouquetFavorite(
                    bouquet.id,
                  ),
                  quantity: BouquetCubit.instance.getQuantity(bouquet.id),
                  onFavoriteToggle: () => onFavoriteToggle(bouquet.id),
                  onIncrement: () => onIncrement(bouquet.id),
                  onDecrement: () => onDecrement(bouquet.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
