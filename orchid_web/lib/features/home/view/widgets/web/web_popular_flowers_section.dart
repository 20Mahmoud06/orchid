import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../catalog/cubit/catalog_cubit.dart';
import '../../../../catalog/cubit/catalog_state.dart';
import '../../../../favorites/cubit/favorites_cubit.dart';
import '../../../../favorites/cubit/favorites_state.dart';
import 'web_popular_section.dart';

/// Desktop "Popular flowers" section with a Pink Lily fallback while the
/// catalog has not loaded yet / offline.
class WebPopularFlowersSection extends StatelessWidget {
  static const _defaultPopularFlowers = [
    (
      id: 'popular_flower_pink_lily',
      name: 'Pink Lily',
      price: '350 EGP',
      image: AppAssets.circleFlower,
    ),
  ];

  const WebPopularFlowersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            final catalogFlowers =
                CatalogCubit.instance.popularFlowers.isNotEmpty
                ? CatalogCubit.instance.popularFlowers
                : CatalogCubit.instance.flowers;
            final items = <WebPopularItem>[];

            if (catalogFlowers.isNotEmpty) {
              for (final flower in catalogFlowers.take(5)) {
                items.add((
                  id: flower.id,
                  name: flower.name,
                  price: '${flower.price} EGP',
                  image: flower.imagePath,
                ));
              }
            } else {
              items.addAll(_defaultPopularFlowers);
            }

            return WebPopularSection(
              title: 'Popular flowers',
              viewAllRoute: AppRoutes.chooseFlowers,
              items: items,
              isFavorite: FavoritesCubit.instance.isFlowerFavorite,
              onToggleFavorite: FavoritesCubit.instance.toggleFlowerFavorite,
            );
          },
        );
      },
    );
  }
}
