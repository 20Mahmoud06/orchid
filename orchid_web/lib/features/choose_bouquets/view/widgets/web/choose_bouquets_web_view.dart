import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../bouquet/cubit/bouquet_cubit.dart';
import '../../../../bouquet/cubit/bouquet_state.dart';
import '../../../../catalog/cubit/catalog_cubit.dart';
import '../../../../catalog/cubit/catalog_state.dart';
import '../../../../choose_flowers/view/widgets/web/web_choose_flowers_widgets.dart';
import '../bouquet_catalog_body.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first choose bouquets page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — heading, search, category tabs and a
/// responsive bouquet grid with the floating view-bouquet bar.
class ChooseBouquetsWebView extends StatelessWidget {
  final String searchQuery;
  final int selectedCategoryIndex;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onOpenSelection;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  const ChooseBouquetsWebView({
    super.key,
    required this.searchQuery,
    required this.selectedCategoryIndex,
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 36, 40, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomText(
                        text: 'choose bouquets',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.black,
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _buildCatalog(context)),
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
                      bloc: BouquetCubit.instance,
                      builder: (context, bouquetState) {
                        // Ready bouquets live in the same quantity map as the
                        // flowers but are not part of [totalCount] (which only
                        // folds the selected flowers), so count them here too so
                        // the view-bouquet bar appears as soon as a bouquet is
                        // added.
                        final readyBouquetCount = BouquetCubit
                            .instance
                            .selectedReadyBouquets
                            .fold<int>(
                              0,
                              (sum, bouquet) =>
                                  sum +
                                  BouquetCubit.instance.getQuantity(bouquet.id),
                            );
                        final totalItems =
                            BouquetCubit.instance.totalCount +
                            readyBouquetCount;
                        final hasItems = totalItems > 0;
                        return AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          offset: hasItems ? Offset.zero : const Offset(0, 2),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: hasItems ? 1 : 0,
                            child: WebViewBouquetBar(
                              totalCount: totalItems,
                              totalPrice: BouquetCubit.instance.totalPrice,
                              onTap: hasItems ? onOpenSelection : null,
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

  Widget _buildCatalog(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        final catalog = CatalogCubit.instance;
        final categories = catalog.bouquetCategories;
        final categoryIndex = _categoryIndex(categories);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WebFlowerSearchBar(
              hintText: 'Search for bouquets',
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 18),
            WebFlowerCategoryTabs(
              categories: categories,
              selectedIndex: categoryIndex,
              onCategorySelected: onCategorySelected,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: BouquetCatalogBody(
                web: true,
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
    );
  }
}
