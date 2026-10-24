import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../features/bouquet/cubit/bouquet_state.dart';
import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../../../../features/catalog/cubit/catalog_state.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../../../../features/favorites/cubit/favorites_state.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import 'flower_grid_card.dart';
import 'flower_search_bar.dart';
import 'view_bouquet_bar.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Mobile layout of the choose-flowers screen (unchanged presentation).
class ChooseFlowersMobileView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final int selectedCategoryIndex;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onCategorySelected;

  const ChooseFlowersMobileView({
    super.key,
    required this.onBackPressed,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar.orchid(
                  title: 'choose flowers',
                  onBackPressed: onBackPressed,
                  actions: [
                    AppBarAction(
                      icon: Icons.favorite,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.favorites),
                    ),
                    AppBarAction(
                      icon: Icons.shopping_cart,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.cart),
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
                        final categories = catalog.flowerCategories;
                        final categoryIndex =
                            selectedCategoryIndex < categories.length
                            ? selectedCategoryIndex
                            : 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            FlowerSearchBar(onChanged: onSearchChanged),
                            SizedBox(height: 16.h),
                            FlowerCategoryTabs(
                              categories: categories,
                              selectedIndex: categoryIndex,
                              onCategorySelected: onCategorySelected,
                            ),
                            SizedBox(height: 16.h),
                            Expanded(
                              child: BlocBuilder<BouquetCubit, BouquetState>(
                                bloc: bouquetController,
                                builder: (context, bouquetState) {
                                  return BlocBuilder<
                                    FavoritesCubit,
                                    FavoritesState
                                  >(
                                    bloc: FavoritesCubit.instance,
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
                                              'Could not load flowers.\nCheck your connection and try again.',
                                          onRetry: () =>
                                              catalog.load(force: true),
                                        );
                                      }

                                      final query = searchQuery.toLowerCase();
                                      final selectedCategory =
                                          categories[categoryIndex]
                                              .toLowerCase();
                                      final filteredFlowers = catalog.flowers
                                          .where((flower) {
                                            final matchesCategory =
                                                categoryIndex == 0 ||
                                                flower.category.toLowerCase() ==
                                                    selectedCategory;
                                            final matchesSearch =
                                                query.isEmpty ||
                                                flower.name
                                                    .toLowerCase()
                                                    .contains(query);
                                            return matchesCategory &&
                                                matchesSearch;
                                          })
                                          .toList();

                                      if (filteredFlowers.isEmpty) {
                                        return Center(
                                          child: CustomText(
                                            text: query.isEmpty
                                                ? 'No flowers in this category yet'
                                                : 'No flowers found with this name',
                                            textAlign: TextAlign.center,
                                            fontSize: 14.sp,
                                            textColor: AppColors.black,
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        padding: EdgeInsets.only(bottom: 90.h),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 10.w,
                                              mainAxisSpacing: 14.h,
                                              childAspectRatio: 0.72,
                                            ),
                                        itemCount: filteredFlowers.length,
                                        itemBuilder: (context, index) {
                                          final flower = filteredFlowers[index];
                                          return FlowerGridCard(
                                            flower: flower,
                                            isFavorite: FavoritesCubit.instance
                                                .isFlowerFavorite(flower.id),
                                            quantity: bouquetController
                                                .getQuantity(flower.id),
                                            onFavoriteToggle: () =>
                                                FavoritesCubit.instance
                                                    .toggleFlowerFavorite(
                                                      flower.id,
                                                    ),
                                            onIncrement: () => bouquetController
                                                .incrementQuantity(flower.id),
                                            onDecrement: () => bouquetController
                                                .decrementQuantity(flower.id),
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
              bloc: bouquetController,
              builder: (context, bouquetState) {
                final hasItems = bouquetController.totalCount > 0;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 12.w,
                  right: 12.w,
                  bottom: hasItems ? 16.h : -100.h,
                  child: ViewBouquetBar(
                    totalCount: bouquetController.totalCount,
                    totalPrice: bouquetController.totalPrice,
                    isSingleFlower:
                        bouquetController.selectedFlowers.length == 1 &&
                        bouquetController.selectedReadyBouquets.isEmpty &&
                        bouquetController.totalCount == 1,
                    onTap: hasItems
                        ? () {
                            Navigator.pushNamed(context, AppRoutes.viewBouquet);
                          }
                        : null,
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
