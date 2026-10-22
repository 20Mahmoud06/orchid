import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../cubit/cart_cubit.dart';
import '../../models/cart_item.dart';
import 'cart_item_card.dart';

/// Scrollable list of cart line items with quantity/remove actions.
class CartItemList extends StatelessWidget {
  final List<CartItem> items;
  final CartCubit cart;

  const CartItemList({super.key, required this.items, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 14.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemCard(
          item: item,
          onRemove: () => cart.removeItem(item.id),
          onIncrement: () => cart.incrementQuantity(item.id),
          onDecrement: () => cart.decrementQuantity(item.id),
        );
      },
    );
  }
}
