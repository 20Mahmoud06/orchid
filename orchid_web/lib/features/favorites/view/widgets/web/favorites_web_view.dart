import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../choose_bouquets/models/bouquet_item.dart';
import '../../../../choose_flowers/models/flower_item.dart';
import '../favorites_segmented_tabs.dart';
import 'web_favorites_widgets.dart';

/// Desktop-first favorites page (>= 768px). Same colors, copy and behaviour as
/// the mobile screen — heading, subtitle, segmented tabs and a card grid.
class FavoritesWebView extends StatelessWidget {
  final FavoritesTab selectedTab;
  final ValueChanged<FavoritesTab> onTabSelected;
  final List<FlowerItem> flowers;
  final List<BouquetItem> bouquets;
  final String emptyMessage;
  final ValueChanged<String> onFlowerFavoriteToggle;
  final ValueChanged<String> onBouquetFavoriteToggle;

  const FavoritesWebView({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.flowers,
    required this.bouquets,
    required this.emptyMessage,
    required this.onFlowerFavoriteToggle,
    required this.onBouquetFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'favorites',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text: 'all flowers you love, saved in one place',
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 16,
                    textColor: AppColors.darkGreen,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: WebFavoritesTabs(
                      selectedTab: selectedTab,
                      onTabSelected: onTabSelected,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildGrid()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final cards = _buildCards();
    if (cards.isEmpty) {
      return WebFavoritesEmptyState(message: emptyMessage);
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  List<Widget> _buildCards() {
    final showFlowers = selectedTab != FavoritesTab.bouquets;
    final showBouquets = selectedTab != FavoritesTab.flowers;
    final cards = <Widget>[];

    if (showFlowers) {
      for (final flower in flowers) {
        cards.add(
          WebFavoriteCard(
            key: ValueKey('web-favorite-flower-${flower.id}'),
            name: flower.name,
            price: flower.price,
            imagePath: flower.imagePath,
            isFavorite: true,
            onFavoriteToggle: () => onFlowerFavoriteToggle(flower.id),
          ),
        );
      }
    }

    if (showBouquets) {
      for (final bouquet in bouquets) {
        cards.add(
          WebFavoriteCard(
            key: ValueKey('web-favorite-bouquet-${bouquet.id}'),
            name: bouquet.name,
            price: bouquet.price,
            imagePath: bouquet.imagePath,
            isFavorite: true,
            onFavoriteToggle: () => onBouquetFavoriteToggle(bouquet.id),
          ),
        );
      }
    }

    return cards;
  }
}
