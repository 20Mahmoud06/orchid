import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/router/app_routes.dart';
import '../../features/cart/cubit/cart_cubit.dart';
import '../../features/cart/cubit/cart_state.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/favorites/cubit/favorites_state.dart';

/// Top announcement bar: slim blush-pink banner with centered seasonal message.
class WebAnnouncementBar extends StatelessWidget {
  const WebAnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 36,
      color: AppColors.storeBlush,
      alignment: Alignment.center,
      child: const Text(
        '🌸 A little joy, delivered in blooms 🌸',
        style: TextStyle(
          fontFamily: AppFonts.inriaSerif,
          fontSize: 13,
          color: AppColors.announcementText,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// Desktop storefront top navigation bar matching the Orchid reference design.
///
/// Combines the top announcement bar with the horizontal desktop header:
/// - Left: Orchid flower icon + uppercase serif 'ORCHID'
/// - Center: Home (with active indicator), Flowers, Bouquets, Build a Bouquet, Inspiration
/// - Right: Search, Favorites, Cart, Profile action items with live badge counts
class WebTopNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const WebTopNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  void _go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const WebAnnouncementBar(), _buildNavBar(context)],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.storeHairline, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final horizontalPadding = isWide ? 48.0 : 20.0;
          final linkSpacing = isWide ? 28.0 : 16.0;
          final actionSpacing = isWide ? 22.0 : 12.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left Brand Logo & Right Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => onItemSelected(0),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppAssets.flowerOutlineIcon,
                              color: AppColors.storeRose,
                              height: 32,
                              width: 32,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ORCHID',
                              style: TextStyle(
                                fontFamily: AppFonts.goudyOldStyle,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0,
                                color: AppColors.storeDeepGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Actions: Favorites, Cart, Profile
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<FavoritesCubit, FavoritesState>(
                          bloc: FavoritesCubit.instance,
                          builder: (context, state) {
                            return _TopNavActionLink(
                              icon: currentIndex == 1
                                  ? Ionicons.heart
                                  : Ionicons.heart_outline,
                              label: 'Favorites',
                              isSelected: currentIndex == 1,
                              badgeCount: FavoritesCubit.instance.totalFavorites,
                              onTap: () => onItemSelected(1),
                            );
                          },
                        ),
                        SizedBox(width: actionSpacing),
                        BlocBuilder<CartCubit, CartState>(
                          bloc: CartCubit.instance,
                          builder: (context, state) {
                            return _TopNavActionLink(
                              icon: currentIndex == 2
                                  ? Ionicons.cart
                                  : Ionicons.cart_outline,
                              label: 'Cart',
                              isSelected: currentIndex == 2,
                              badgeCount: CartCubit.instance.totalItems,
                              onTap: () => onItemSelected(2),
                            );
                          },
                        ),
                        SizedBox(width: actionSpacing),
                        _TopNavActionLink(
                          icon: currentIndex == 3
                              ? Ionicons.person
                              : Ionicons.person_outline,
                          label: 'Profile',
                          isSelected: currentIndex == 3,
                          onTap: () => onItemSelected(3),
                        ),
                      ],
                    ),
                  ],
                ),

                // Center Navigation Links (Exact Center)
                IgnorePointer(
                  ignoring: false,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopNavTextLink(
                        label: 'Home',
                        isSelected: currentIndex == 0,
                        onTap: () => onItemSelected(0),
                      ),
                      SizedBox(width: linkSpacing),
                      _TopNavTextLink(
                        label: 'Flowers',
                        onTap: () => _go(context, AppRoutes.chooseFlowers),
                      ),
                      SizedBox(width: linkSpacing),
                      _TopNavTextLink(
                        label: 'Bouquets',
                        onTap: () => _go(context, AppRoutes.chooseBouquets),
                      ),
                      SizedBox(width: linkSpacing),
                      _TopNavTextLink(
                        label: 'Inspiration',
                        onTap: () => _go(context, AppRoutes.inspiration),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopNavTextLink extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavTextLink({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<_TopNavTextLink> createState() => _TopNavTextLinkState();
}

class _TopNavTextLinkState extends State<_TopNavTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.storeDeepGreen;
    final textColor = widget.isSelected
        ? activeColor
        : (_hovered ? AppColors.storeRose : AppColors.storeNavText);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 15,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: widget.isSelected ? 28 : (_hovered ? 16 : 0),
                height: 2,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? activeColor
                      : AppColors.storeRose.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavActionLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _TopNavActionLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.badgeCount = 0,
  });

  @override
  State<_TopNavActionLink> createState() => _TopNavActionLinkState();
}

class _TopNavActionLinkState extends State<_TopNavActionLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const defaultColor = AppColors.storeDeepGreen;
    final color = widget.isSelected
        ? AppColors.storeRose
        : (_hovered ? AppColors.storeRose : defaultColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(widget.icon, size: 19, color: color),
                if (widget.badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.storeRose,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      constraints: const BoxConstraints(minWidth: 15),
                      child: Text(
                        '${widget.badgeCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
