import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../catalog/cubit/catalog_cubit.dart';
import '../../../../catalog/cubit/catalog_state.dart';
import '../../../../favorites/cubit/favorites_cubit.dart';
import '../../../../favorites/cubit/favorites_state.dart';
import 'web_popular_section.dart';

/// Desktop "Popular bouquets" section (falls back to all bouquets when the
/// catalog has no popular list yet).
class WebPopularBouquetsSection extends StatelessWidget {
  const WebPopularBouquetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            final catalog = CatalogCubit.instance;
            final catalogBouquets = catalog.popularBouquets.isNotEmpty
                ? catalog.popularBouquets
                : catalog.bouquets;

            if (catalogBouquets.isEmpty) {
              return const SizedBox.shrink();
            }

            final items = catalogBouquets
                .take(5)
                .map(
                  (bouquet) => (
                    id: bouquet.id,
                    name: bouquet.name,
                    price: '${bouquet.price} EGP',
                    image: bouquet.imagePath,
                  ),
                )
                .toList();

            return WebPopularSection(
              title: 'Popular bouquets',
              viewAllRoute: AppRoutes.chooseBouquets,
              items: items,
              isFavorite: FavoritesCubit.instance.isBouquetFavorite,
              onToggleFavorite: FavoritesCubit.instance.toggleBouquetFavorite,
            );
          },
        );
      },
    );
  }
}
