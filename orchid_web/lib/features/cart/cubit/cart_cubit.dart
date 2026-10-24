import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../models/cart_item.dart';
import 'cart_state.dart';

/// Holds the order draft: items the customer intends to buy. Persisted on
/// the device, so an unfinished order survives the app closing or losing
/// internet mid-flow.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  static final CartCubit instance = CartCubit();

  /// Restores the cart saved on this device. Call once from `main`.
  Future<void> init() async {
    final raw = await AppPrefs.instance.getString(AppPrefKeys.cartItems);
    emit(
      CartState(
        items: _decodeItems(raw).map(_withSingleFlowerIdentity).toList(),
      ),
    );
  }

  static CartItem _withSingleFlowerIdentity(CartItem item) {
    if (!item.isSingleFlowerBouquet) return item;
    return item.copyWith(
      name: item.displayName,
      imagePath: item.displayImagePath,
    );
  }

  static List<CartItem> _decodeItems(String? raw) {
    if (raw == null || raw.isEmpty) return <CartItem>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <CartItem>[];
      return decoded
          .whereType<Map>()
          .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty && item.quantity > 0)
          .toList();
    } catch (_) {
      return <CartItem>[];
    }
  }

  void _persist(List<CartItem> items) {
    AppPrefs.instance.saveString(AppPrefKeys.cartItems, jsonEncode(items));
  }

  void _emit(List<CartItem> items) {
    _persist(items);
    emit(CartState(items: List.unmodifiable(items)));
  }

  void clearCart() => _emit(<CartItem>[]);

  List<CartItem> get items => state.items;

  /// Total number of units across all cart items.
  int get totalItems => state.items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal for the whole cart (unit price x quantity for each item).
  int get totalPrice => state.items.fold(0, (sum, item) => sum + item.total);

  /// Adds items to the order draft. An item with the same id (e.g. the same
  /// ready bouquet added twice) has its quantities merged.
  void addItems(List<CartItem> newItems) {
    final items = List<CartItem>.of(state.items);
    for (final newItem in newItems) {
      final item = _withSingleFlowerIdentity(newItem);
      if (item.id.isEmpty || item.quantity <= 0) continue;
      final index = items.indexWhere((existing) => existing.id == item.id);
      if (index == -1) {
        items.add(item);
      } else {
        final existing = items[index];
        items[index] = existing.copyWith(
          name: item.name,
          quantity: existing.quantity + item.quantity,
          // Refresh price/image/composition from the latest add.
          price: item.price,
          imagePath: item.imagePath,
          components: item.components,
        );
      }
    }
    _emit(items);
  }

  void removeItem(String id) {
    _emit(state.items.where((item) => item.id != id).toList());
  }

  /// Attaches (or clears, with an empty [message]) a note to one cart line.
  void setItemMessage(String id, String message) {
    final items = List<CartItem>.of(state.items);
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final item = items[index];
    final trimmed = message.trim();
    items[index] = CartItem(
      id: item.id,
      name: item.name,
      price: item.price,
      imagePath: item.imagePath,
      quantity: item.quantity,
      components: item.components,
      message: trimmed.isEmpty ? null : trimmed,
    );
    _emit(items);
  }

  void incrementQuantity(String id) {
    final items = List<CartItem>.of(state.items);
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    _emit(items);
  }

  void decrementQuantity(String id) {
    final items = List<CartItem>.of(state.items);
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    }
    _emit(items);
  }
}
