import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../features/bouquet/cubit/bouquet_state.dart';
import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../../../../features/catalog/cubit/catalog_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../../../../features/favorites/cubit/favorites_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../widgets/flower_grid_card.dart';
import '../widgets/flower_search_bar.dart';
import '../widgets/view_bouquet_bar.dart';
import '../widgets/web/web_choose_flowers_widgets.dart';

/// Choose Flowers screen matching the Orchid Figma design.
class ChooseFlowersScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ChooseFlowersScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<ChooseFlowersScreen> createState() => _ChooseFlowersScreenState();
}

class _ChooseFlowersScreenState extends State<ChooseFlowersScreen> {
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
  /// (longer) list falls back to "All flowers" instead of going out of range.
  int _categoryIndex(List<String> categories) =>
      _selectedCategoryIndex < categories.length ? _selectedCategoryIndex : 0;

  void _toggleFavorite(String flowerId) {
    _favoritesController.toggleFlowerFavorite(flowerId);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide flower catalog
        // with the search bar, category tabs and a responsive grid. Narrow
        // viewports keep the untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first choose flowers page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — heading, search, category tabs and a
  /// responsive flower grid with the floating view-bouquet bar.
  Widget _buildWeb(BuildContext context) {
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
                      Expanded(child: _buildWebCatalog(context)),
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
                      bloc: _bouquetController,
                      builder: (context, bouquetState) {
                        final hasItems = _bouquetController.totalCount > 0;
                        return AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          offset: hasItems ? Offset.zero : const Offset(0, 2),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: hasItems ? 1 : 0,
                            child: WebViewBouquetBar(
                              totalCount: _bouquetController.totalCount,
                              totalPrice: _bouquetController.totalPrice,
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

  Widget _buildWebCatalog(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        final catalog = CatalogCubit.instance;
        final categories = catalog.flowerCategories;
        final categoryIndex = _categoryIndex(categories);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebFlowerSearchBar(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.trim();
                });
              },
            ),
            const SizedBox(height: 18),
            WebFlowerCategoryTabs(
              categories: categories,
              selectedIndex: categoryIndex,
              onCategorySelected: (index) {
                setState(() => _selectedCategoryIndex = index);
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _buildWebGrid(context, catalog, categories, categoryIndex),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebGrid(
    BuildContext context,
    CatalogCubit catalog,
    List<String> categories,
    int categoryIndex,
  ) {
    return BlocBuilder<BouquetCubit, BouquetState>(
      bloc: _bouquetController,
      builder: (context, bouquetState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: _favoritesController,
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

            final searchQuery = _searchQuery.toLowerCase();
            final selectedCategory = categories[categoryIndex].toLowerCase();
            final filteredFlowers = catalog.flowers.where((flower) {
              final matchesCategory = categoryIndex == 0 ||
                  flower.category.toLowerCase() == selectedCategory;
              final matchesSearch = searchQuery.isEmpty ||
                  flower.name.toLowerCase().contains(searchQuery);
              return matchesCategory && matchesSearch;
            }).toList();

            if (filteredFlowers.isEmpty) {
              return WebFlowerCatalogMessage(
                message: searchQuery.isEmpty
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
                  isFavorite:
                      _favoritesController.isFlowerFavorite(flower.id),
                  quantity: _bouquetController.getQuantity(flower.id),
                  onFavoriteToggle: () => _toggleFavorite(flower.id),
                  onIncrement: () =>
                      _bouquetController.incrementQuantity(flower.id),
                  onDecrement: () =>
                      _bouquetController.decrementQuantity(flower.id),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
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
                        final categories = catalog.flowerCategories;
                        final categoryIndex = _categoryIndex(categories);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            FlowerSearchBar(
                              onChanged: (query) {
                                setState(() {
                                  _searchQuery = query.trim();
                                });
                              },
                            ),
                            SizedBox(height: 16.h),
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
                                              'Could not load flowers.\nCheck your connection and try again.',
                                          onRetry: () =>
                                              catalog.load(force: true),
                                        );
                                      }

                                      final searchQuery =
                                          _searchQuery.toLowerCase();
                                      final selectedCategory = categories[
                                              categoryIndex]
                                          .toLowerCase();
                                      final filteredFlowers =
                                          catalog.flowers.where((flower) {
                                        final matchesCategory = categoryIndex ==
                                                0 ||
                                            flower.category.toLowerCase() ==
                                                selectedCategory;
                                        final matchesSearch =
                                            searchQuery.isEmpty ||
                                                flower.name
                                                    .toLowerCase()
                                                    .contains(searchQuery);
                                        return matchesCategory &&
                                            matchesSearch;
                                      }).toList();

                                      if (filteredFlowers.isEmpty) {
                                        return Center(
                                          child: Text(
                                            searchQuery.isEmpty
                                                ? 'No flowers in this category yet'
                                                : 'No flowers found with this name',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors.black,
                                            ),
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
                                          final flower =
                                              filteredFlowers[index];
                                          return FlowerGridCard(
                                            flower: flower,
                                            isFavorite: _favoritesController
                                                .isFlowerFavorite(flower.id),
                                            quantity: _bouquetController
                                                .getQuantity(flower.id),
                                            onFavoriteToggle: () =>
                                                _toggleFavorite(flower.id),
                                            onIncrement: () =>
                                                _bouquetController
                                                    .incrementQuantity(
                                                        flower.id),
                                            onDecrement: () =>
                                                _bouquetController
                                                    .decrementQuantity(
                                                        flower.id),
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
                final hasItems = _bouquetController.totalCount > 0;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 12.w,
                  right: 12.w,
                  bottom: hasItems ? 16.h : -100.h,
                  child: ViewBouquetBar(
                    totalCount: _bouquetController.totalCount,
                    totalPrice: _bouquetController.totalPrice,
                    onTap: hasItems
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.viewBouquet,
                            );
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
