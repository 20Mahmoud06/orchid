import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../features/favorites/cubit/favorites_cubit.dart';
import '../../../../features/favorites/cubit/favorites_state.dart';
import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../../../../features/catalog/cubit/catalog_state.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/home_side_menu.dart';
import '../widgets/celebration_section.dart';
import '../widgets/popular_item_card.dart';
import '../widgets/build_bouquet_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Storefront fallback shown when the catalog has not loaded yet / offline.
  static const _defaultPopularFlowers = [
    (
      id: 'popular_flower_pink_lily',
      name: 'Pink Lily',
      price: '350 EGP',
      image: AppAssets.circleFlower,
    ),
  ];

  @override
  void initState() {
    super.initState();
    CatalogCubit.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const HomeSideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: CustomText(
          text: 'ORCHID',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24.sp,
          fontWeight: FontWeight.w500,
          textColor: AppColors.primary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CelebrationSection(),
              SizedBox(height: 24.h),
              
              // Popular Bouquets
              BlocBuilder<CatalogCubit, CatalogState>(
                bloc: CatalogCubit.instance,
                builder: (context, catalogState) {
                  return BlocBuilder<FavoritesCubit, FavoritesState>(
                    bloc: FavoritesCubit.instance,
                    builder: (context, favoritesState) {
                      final catalogBouquets =
                          CatalogCubit.instance.popularBouquets.isNotEmpty
                              ? CatalogCubit.instance.popularBouquets
                              : CatalogCubit.instance.bouquets;
                      if (catalogBouquets.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final bouquets = catalogBouquets.take(5).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: 'Popular Bouquets',
                            onSeeAll: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.chooseBouquets);
                            },
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 180.h,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final bouquet in bouquets)
                                  PopularItemCard(
                                    imageUrl: bouquet.imagePath,
                                    title: bouquet.name,
                                    price: '${bouquet.price} EGP',
                                    isFavorite: FavoritesCubit.instance
                                        .isBouquetFavorite(bouquet.id),
                                    onToggle: () => FavoritesCubit.instance
                                        .toggleBouquetFavorite(bouquet.id),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.chooseBouquets);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Popular Flowers
              BlocBuilder<CatalogCubit, CatalogState>(
                bloc: CatalogCubit.instance,
                builder: (context, catalogState) {
                  return BlocBuilder<FavoritesCubit, FavoritesState>(
                    bloc: FavoritesCubit.instance,
                    builder: (context, favoritesState) {
                      final catalogFlowers =
                          CatalogCubit.instance.popularFlowers.isNotEmpty
                              ? CatalogCubit.instance.popularFlowers
                              : CatalogCubit.instance.flowers;
                      final items =
                          <({
                            String id,
                            String name,
                            String price,
                            String image,
                          })>[];

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
                        // Fallback to only Pink Lily if the catalog has not
                        // loaded yet / offline.
                        items.addAll(_defaultPopularFlowers);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: 'Popular Flowers',
                            onSeeAll: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.chooseFlowers);
                            },
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 180.h,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final flower in items)
                                  PopularItemCard(
                                    imageUrl: flower.image,
                                    title: flower.name,
                                    price: flower.price,
                                    isFavorite: FavoritesCubit.instance
                                        .isFlowerFavorite(flower.id),
                                    onToggle: () => FavoritesCubit.instance
                                        .toggleFlowerFavorite(flower.id),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.chooseFlowers);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),
              
              // Build your own bouquet
              BuildBouquetBanner(
                imagePath: AppAssets.buildFlower,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.chooseFlowers);
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CustomText(
          text: title,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 20.sp,
          textColor: AppColors.black,
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: CustomText(
            text: 'see all',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            textColor: AppColors.black
          ),
        ),
      ],
    );
  }
}
