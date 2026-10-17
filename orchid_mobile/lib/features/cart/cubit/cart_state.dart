import 'package:equatable/equatable.dart';

import '../models/cart_item.dart';

/// The order draft: items the customer intends to buy.
class CartState extends Equatable {
  const CartState({this.items = const <CartItem>[]});

  final List<CartItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}
