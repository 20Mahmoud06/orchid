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
import '../widgets/web/web_home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    CatalogCubit.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop storefront
  // ---------------------------------------------------------------------------

  static const _defaultPopularFlowers = [
    (
      id: 'popular_flower_pink_lily',
      name: 'Pink Lily',
      price: '350 EGP',
      image: AppAssets.circleFlower,
    ),
  ];

  Widget _buildWeb(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WebStoreSection(
              verticalPadding: 24,
              child: WebHeroSection(),
            ),
            const WebStoreSection(
              verticalPadding: 20,
              child: WebOccasionsSection(),
            ),
            WebStoreSection(
              verticalPadding: 20,
              child: _buildWebPopularBouquets(context),
            ),
            WebStoreSection(
              verticalPadding: 20,
              child: _buildWebPopularFlowers(context),
            ),
            const WebStoreSection(
              verticalPadding: 24,
              child: WebCustomBouquetBanner(),
            ),
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPopularBouquets(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            final catalogBouquets = CatalogCubit.instance.popularBouquets.isNotEmpty
                ? CatalogCubit.instance.popularBouquets
                : CatalogCubit.instance.bouquets;

            if (catalogBouquets.isEmpty) {
              return const SizedBox.shrink();
            }

            final items = catalogBouquets.take(5).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Popular bouquets',
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.storeDeepGreen,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.chooseBouquets,
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'View all',
                              style: TextStyle(
                                fontFamily: AppFonts.inriaSerif,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.storeDeepGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: AppColors.storeDeepGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 290,
                      mainAxisExtent: 270,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isFav =
                          FavoritesCubit.instance.isBouquetFavorite(item.id);
                      return WebPopularProductCard(
                        imageUrl: item.imagePath,
                        title: item.name,
                        price: '${item.price} EGP',
                        isFavorite: isFav,
                        onToggle: () => FavoritesCubit.instance
                            .toggleBouquetFavorite(item.id),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.chooseBouquets,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWebPopularFlowers(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: CatalogCubit.instance,
      builder: (context, catalogState) {
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, favoritesState) {
            final catalogFlowers = CatalogCubit.instance.popularFlowers.isNotEmpty
                ? CatalogCubit.instance.popularFlowers
                : CatalogCubit.instance.flowers;
            final items = <({String id, String name, String price, String image})>[];

            if (catalogFlowers.isNotEmpty) {
              for (final f in catalogFlowers.take(5)) {
                items.add((
                  id: f.id,
                  name: f.name,
                  price: '${f.price} EGP',
                  image: f.imagePath,
                ));
              }
            } else {
              // Fallback to only Pink Lily if catalog has not loaded yet / offline
              items.addAll(_defaultPopularFlowers);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Popular flowers',
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.storeDeepGreen,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.chooseFlowers),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'View all',
                              style: TextStyle(
                                fontFamily: AppFonts.inriaSerif,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.storeDeepGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: AppColors.storeDeepGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 290,
                      mainAxisExtent: 270,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isFav = FavoritesCubit.instance.isFlowerFavorite(item.id);
                      return WebPopularProductCard(
                        imageUrl: item.image,
                        title: item.name,
                        price: item.price,
                        isFavorite: isFav,
                        onToggle: () => FavoritesCubit.instance
                            .toggleFlowerFavorite(item.id),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.chooseFlowers),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // ---------------------------------------------------------------------------
  // Mobile layout (unchanged)
  // ---------------------------------------------------------------------------

  Widget _buildMobile(BuildContext context) {
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
                      final bouquets = CatalogCubit.instance.popularBouquets;
                      if (bouquets.isEmpty) return const SizedBox.shrink();
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
                      final flowers = CatalogCubit.instance.popularFlowers;
                      if (flowers.isEmpty) return const SizedBox.shrink();
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
                                for (final flower in flowers)
                                  PopularItemCard(
                                    imageUrl: flower.imagePath,
                                    title: flower.name,
                                    price: '${flower.price} EGP',
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
