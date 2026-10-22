import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../../../bouquet/cubit/bouquet_cubit.dart';
import '../../../bouquet/cubit/bouquet_state.dart';
import '../../../catalog/cubit/catalog_cubit.dart';
import '../../../catalog/cubit/catalog_state.dart';
import 'bouquet_catalog_body.dart';
import 'bouquet_search_bar.dart';
import 'view_bouquet_bar.dart';

/// Mobile layout of the choose bouquets screen (unchanged presentation),
/// extracted from the screen so the screen only owns state and actions.
class ChooseBouquetsMobileView extends StatelessWidget {
  final String searchQuery;
  final int selectedCategoryIndex;
  final VoidCallback? onBackPressed;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onOpenSelection;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  const ChooseBouquetsMobileView({
    super.key,
    required this.searchQuery,
    required this.selectedCategoryIndex,
    required this.onBackPressed,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onOpenSelection,
    required this.onFavoriteToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  /// The tab list grows as the catalog loads, so a selection from a previous
  /// (longer) list falls back to "All bouquets" instead of going out of range.
  int _categoryIndex(List<String> categories) =>
      selectedCategoryIndex < categories.length ? selectedCategoryIndex : 0;

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
                        final categories = catalog.bouquetCategories;
                        final categoryIndex = _categoryIndex(categories);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            BouquetSearchBar(onChanged: onSearchChanged),
                            SizedBox(height: 10.h),
                            FlowerCategoryTabs(
                              categories: categories,
                              selectedIndex: categoryIndex,
                              onCategorySelected: onCategorySelected,
                            ),
                            SizedBox(height: 16.h),
                            Expanded(
                              child: BouquetCatalogBody(
                                web: false,
                                searchQuery: searchQuery,
                                categoryIndex: categoryIndex,
                                categories: categories,
                                catalog: catalog,
                                onFavoriteToggle: onFavoriteToggle,
                                onIncrement: onIncrement,
                                onDecrement: onDecrement,
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
              bloc: BouquetCubit.instance,
              builder: (context, bouquetState) {
                // Ready bouquets share the quantity map with the flowers but
                // are not part of [totalCount], so count them here too so the
                // bar appears as soon as a bouquet is added.
                final readyBouquetCount = BouquetCubit
                    .instance
                    .selectedReadyBouquets
                    .fold<int>(
                      0,
                      (sum, bouquet) =>
                          sum + BouquetCubit.instance.getQuantity(bouquet.id),
                    );
                final totalItems =
                    BouquetCubit.instance.totalCount + readyBouquetCount;
                final hasItems = totalItems > 0;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 12.w,
                  right: 12.w,
                  bottom: hasItems ? 16.h : -100.h,
                  child: ViewBouquetBar(
                    totalCount: totalItems,
                    totalPrice: BouquetCubit.instance.totalPrice,
                    onTap: hasItems ? onOpenSelection : null,
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
