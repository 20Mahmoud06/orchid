import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../../../../features/favorites/cubit/favorites_state.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../choose_bouquets/view/widgets/bouquet_grid_card.dart';
import '../../../choose_flowers/view/widgets/flower_grid_card.dart';
import '../widgets/favorites_empty_state.dart';
import '../widgets/favorites_segmented_tabs.dart';

/// Favorites screen matching the Orchid Figma design.
class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const FavoritesScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoritesController = FavoritesCubit.instance;
  FavoritesTab _selectedTab = FavoritesTab.all;

  bool get _showFlowers => _selectedTab != FavoritesTab.bouquets;

  bool get _showBouquets => _selectedTab != FavoritesTab.flowers;

  List<Widget> _buildCards() {
    final cards = <Widget>[];

    if (_showFlowers) {
      final flowers = _favoritesController.favoriteFlowers;
      for (final flower in flowers) {
        cards.add(FlowerGridCard(
          key: ValueKey('favorite-flower-${flower.id}'),
          flower: flower,
          isFavorite: true,
          quantity: 0,
          showQuantityControl: false,
          favoriteHeartColor: AppColors.redText,
          onFavoriteToggle: () =>
              _favoritesController.toggleFlowerFavorite(flower.id),
          onIncrement: () {},
          onDecrement: () {},
        ));
      }
    }

    if (_showBouquets) {
      final bouquets = _favoritesController.favoriteBouquets;
      for (final bouquet in bouquets) {
        cards.add(BouquetGridCard(
          key: ValueKey('favorite-bouquet-${bouquet.id}'),
          bouquet: bouquet,
          isFavorite: true,
          quantity: 0,
          showQuantityControl: false,
          favoriteHeartColor: AppColors.redText,
          onFavoriteToggle: () =>
              _favoritesController.toggleBouquetFavorite(bouquet.id),
          onIncrement: () {},
          onDecrement: () {},
        ));
      }
    }

    return cards;
  }

  String _emptyMessage() {
    switch (_selectedTab) {
      case FavoritesTab.all:
        return 'no favorite items here';
      case FavoritesTab.bouquets:
        return 'no favorite Bouquets';
      case FavoritesTab.flowers:
        return 'no favorite Flowers here';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar.orchid(
              title: 'favorites',
              onBackPressed: widget.onBackPressed,
              centerWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'favorites',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.black,
                  ),
                ],
              ),
            ),
            CustomText(
              text: 'all flowers you love,\nsaved in one place',
              fontFamily: AppFonts.inriaSerif,
              fontSize: 16.sp,
              textColor: AppColors.darkGreen,
              textAlign: TextAlign.center,
              height: 1.3,
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: FavoritesSegmentedTabs(
                selectedTab: _selectedTab,
                onTabSelected: (tab) => setState(() => _selectedTab = tab),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  bloc: _favoritesController,
                  builder: (context, state) {
                    final cards = _buildCards();
                    if (cards.isEmpty) {
                      return FavoritesEmptyState(
                        message: _emptyMessage(),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.only(bottom: 28.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) => cards[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}