import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../features/cart/cubit/cart_cubit.dart';
import '../../features/cart/cubit/cart_state.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/favorites/cubit/favorites_state.dart';
import 'web_top_nav_action_link.dart';

/// Header action items (favorites, cart, profile) with live badge counts.
class WebTopNavActions extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final double spacing;

  const WebTopNavActions({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: FavoritesCubit.instance,
          builder: (context, state) {
            return WebTopNavActionLink(
              icon: currentIndex == 1 ? Ionicons.heart : Ionicons.heart_outline,
              label: 'Favorites',
              isSelected: currentIndex == 1,
              badgeCount: FavoritesCubit.instance.totalFavorites,
              onTap: () => onItemSelected(1),
            );
          },
        ),
        SizedBox(width: spacing),
        BlocBuilder<CartCubit, CartState>(
          bloc: CartCubit.instance,
          builder: (context, state) {
            return WebTopNavActionLink(
              icon: currentIndex == 2 ? Ionicons.cart : Ionicons.cart_outline,
              label: 'Cart',
              isSelected: currentIndex == 2,
              badgeCount: CartCubit.instance.totalItems,
              onTap: () => onItemSelected(2),
            );
          },
        ),
        SizedBox(width: spacing),
        WebTopNavActionLink(
          icon: currentIndex == 3 ? Ionicons.person : Ionicons.person_outline,
          label: 'Profile',
          isSelected: currentIndex == 3,
          onTap: () => onItemSelected(3),
        ),
      ],
    );
  }
}
