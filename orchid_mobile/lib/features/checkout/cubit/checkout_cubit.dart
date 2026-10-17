import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/cart/models/cart_item.dart';
import '../../../features/catalog/cubit/catalog_cubit.dart';
import '../../bouquet/cubit/bouquet_cubit.dart';
import 'checkout_state.dart';

/// Raised when an order cannot be placed; [message] is safe to show to the
/// user.
class CheckoutException implements Exception {
  CheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One line of the order being placed, in the shape the order summary renders:
/// a photo, a name, the composition/message and the line price.
class CheckoutLineItem {
  const CheckoutLineItem({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String image;
  final String description;
  final int price;
  final int quantity;
}

/// Shared order data collected across the checkout flow, and the single
/// place that writes an order into the same `orders` / `order_items` tables
/// the admin dashboard reads.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(const CheckoutState());

  static final CheckoutCubit instance = CheckoutCubit();

  static const int deliveryFee = 30;
  static const int serviceFee = 10;

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  bool get hasMessage => state.hasMessage;

  String get messageText => state.messageText;

  String get fullName => state.fullName;

  String get phone => state.phone;

  String get whatsapp => state.whatsapp;

  String get location => state.location;

  String get notes => state.notes;

  CheckoutSource get source => state.source;

  String? get lastOrderCode => state.lastOrderCode;

  /// Next-day delivery slot; the same value is stored on the order row so
  /// the admin can display it.
  static DateTime get deliverySlot {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 10);
  }

  String get deliveryDate {
    final slot = deliverySlot;
    return '${_weekdays[slot.weekday - 1]}, '
        '${slot.day} ${_months[slot.month - 1]} ${slot.year}';
  }

  String get deliveryTime => 'between 10 a.m. to 2 p.m.';

  String get deliveryDateTimeText => '$deliveryDate\n$deliveryTime';

  /// Subtotal of what is being checked out: the saved cart for cart
  /// checkout, the live bouquet builder for the direct flow.
  int get bouquetPrice => state.source == CheckoutSource.cart
      ? CartCubit.instance.totalPrice
      : BouquetCubit.instance.totalPrice;

  int get totalPrice => bouquetPrice + deliveryFee + serviceFee;

  String get bouquetDescription => BouquetCubit.instance.descriptionText;

  /// Items being purchased, in the shape the order summary displays.
  List<String> get checkoutLines {
    if (state.source == CheckoutSource.cart) {
      return [
        for (final item in CartCubit.instance.items)
          '${item.quantity} ${item.name.toLowerCase()}'
              '${item.message != null && item.message!.trim().isNotEmpty ? ' — ${item.message!.trim()}' : ''}',
      ];
    }
    return BouquetCubit.instance.descriptionText.isEmpty
        ? const <String>[]
        : BouquetCubit.instance.descriptionText.split(', ').toList();
  }

  /// Structured checkout lines (photo, name, composition, line price) so the
  /// order summary can draw one card per item instead of a single card.
  List<CheckoutLineItem> get checkoutItems {
    if (state.source == CheckoutSource.cart) {
      return [
        for (final item in CartCubit.instance.items)
          CheckoutLineItem(
            name: item.name,
            image: item.imagePath,
            description: _cartItemDescription(item),
            price: item.total,
            quantity: item.quantity,
          ),
      ];
    }

    final bouquet = BouquetCubit.instance;
    final items = <CheckoutLineItem>[];

    final flowers = bouquet.selectedFlowers;
    if (flowers.isNotEmpty) {
      final flowerSubtotal = flowers.fold<int>(
        0,
        (sum, flower) => sum + flower.price * bouquet.getQuantity(flower.id),
      );
      items.add(
        CheckoutLineItem(
          name: 'Custom Bouquet',
          image: flowers.first.imagePath,
          description: bouquet.descriptionText,
          price: flowerSubtotal,
          quantity: 1,
        ),
      );
    }

    for (final ready in bouquet.selectedReadyBouquets) {
      final quantity = bouquet.getQuantity(ready.id);
      items.add(
        CheckoutLineItem(
          name: ready.name,
          image: ready.imagePath,
          description: '',
          price: ready.price * quantity,
          quantity: quantity,
        ),
      );
    }

    return items;
  }

  String _cartItemDescription(CartItem item) {
    final message = item.message?.trim();
    if (item.isCustomBouquet) {
      final composition = item.components!
          .map((c) => '${c.quantity} ${c.name.toLowerCase()}')
          .join(', ');
      return (message != null && message.isNotEmpty)
          ? '$composition — $message'
          : composition;
    }
    return message ?? '';
  }

  void setMessage({required bool hasMessage, required String text}) {
    emit(state.copyWith(hasMessage: hasMessage, messageText: text.trim()));
  }

  void setDeliveryDetails({
    required String fullName,
    required String phone,
    required String whatsapp,
    required String location,
    required String notes,
  }) {
    emit(state.copyWith(
      fullName: fullName.trim(),
      phone: phone.trim(),
      whatsapp: whatsapp.trim(),
      location: location.trim(),
      notes: notes.trim(),
    ));
  }

  /// Marks which items the payment screen should turn into an order.
  /// Called before navigating to the payment screen.
  void beginCheckout(CheckoutSource source) {
    emit(state.copyWith(source: source));
  }

  void setPaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method));
  }

  /// Inserts the order and its items into Supabase, then clears the draft
  /// (bouquet selection and, for cart checkout, the cart).
  ///
  /// Throws [CheckoutException] with a user-readable message on failure.
  Future<void> submitOrder() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw CheckoutException('Please sign in to place an order');
    }

    final items = buildItems();
    if (items.isEmpty) {
      throw CheckoutException(
        state.source == CheckoutSource.cart
            ? 'Your cart is empty'
            : 'Your bouquet is empty',
      );
    }

    final subtotal = items.fold<int>(
      0,
      (sum, item) =>
          sum +
          ((item['price_snapshot'] as num) * (item['quantity'] as num)).round(),
    );
    final total = subtotal + deliveryFee + serviceFee;
    final now = DateTime.now().toUtc();
    final slot = deliverySlot.toUtc();
    final code = _generateOrderCode();
    final source = state.source;

    String? orderId;
    try {
      final orderRow = await client
          .from('orders')
          .insert({
            'order_code': code,
            'status': 'PENDING',
            'user_id': user.id,
            'message': state.hasMessage && state.messageText.isNotEmpty
                ? state.messageText
                : null,
            'additional_notes': state.notes.isEmpty ? null : state.notes,
            'delivery_address': state.location,
            'delivery_date': slot.toIso8601String(),
            'order_time': slot.toIso8601String(),
            'delivery_fee': deliveryFee,
            'service_fee': serviceFee,
            'total': total,
            'payment_method': state.paymentMethod,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .select('id')
          .single();
      orderId = orderRow['id'] as String?;

      await client.from('order_items').insert([
        for (final item in items) {...item, 'order_id': orderId},
      ]);
    } catch (error) {
      // A half-written order (row created, items failed) must not linger in
      // the admin dashboard, so remove it before reporting the failure.
      if (orderId != null) {
        try {
          await client.from('orders').delete().eq('id', orderId);
        } catch (_) {
          // Cleanup is best-effort; the checkout error below is what matters.
        }
      }
      throw CheckoutException(
        'Could not place your order. Check your connection and try again. '
        '($error)',
      );
    }

    _resetDraft(lastOrderCode: code, clearCart: source == CheckoutSource.cart);
  }

  /// Builds the `order_items` rows for the current draft. Exposed for tests;
  /// production code goes through [submitOrder].
  ///
  /// `image_snapshot` is NOT NULL in the orders schema, so the raw path is
  /// always stored: a public URL, a bundled asset path, or '' — the admin and
  /// the app both render a floral placeholder for the latter two.
  @visibleForTesting
  List<Map<String, dynamic>> buildItems() {
    if (state.source == CheckoutSource.cart) {
      final items = <Map<String, dynamic>>[];
      for (final item in CartCubit.instance.items) {
        final message = item.message?.trim();
        final components = <String, dynamic>{
          if (message != null && message.isNotEmpty) 'message': message,
          if (item.isCustomBouquet) 'description': item.components!
              .map((c) => '${c.quantity} ${c.name.toLowerCase()}')
              .join(', '),
          if (item.isCustomBouquet)
            'flowers': [
              for (final component in item.components!)
                {
                  'product_id': component.productId,
                  'name': component.name,
                  'quantity': component.quantity,
                  'unit_price': component.unitPrice,
                },
            ],
        };
        items.add({
          'item_type': item.isCustomBouquet ? _bouquetType : _productType(item.id),
          'product_id': _uuidOrNull(item.id),
          'name_snapshot': item.name,
          'image_snapshot': item.imagePath,
          'price_snapshot': item.price,
          'quantity': item.quantity,
          'custom_components': components.isEmpty ? null : components,
        });
      }
      return items;
    }

    final bouquet = BouquetCubit.instance;
    final items = <Map<String, dynamic>>[];

    final flowers = bouquet.selectedFlowers;
    if (flowers.isNotEmpty) {
      final flowerSubtotal = flowers.fold<int>(
        0,
        (sum, flower) => sum + flower.price * bouquet.getQuantity(flower.id),
      );
      items.add({
        'item_type': _bouquetType,
        'product_id': null,
        'name_snapshot': 'Custom Bouquet',
        'image_snapshot': flowers.first.imagePath,
        'price_snapshot': flowerSubtotal,
        'quantity': 1,
        'custom_components': {
          'description': bouquet.descriptionText,
          'flowers': [
            for (final flower in flowers)
              {
                'product_id': flower.id,
                'name': flower.name,
                'quantity': bouquet.getQuantity(flower.id),
                'unit_price': flower.price,
              },
          ],
        },
      });
    }

    for (final ready in bouquet.selectedReadyBouquets) {
      items.add({
        'item_type': _bouquetType,
        'product_id': ready.id,
        'name_snapshot': ready.name,
        'image_snapshot': ready.imagePath,
        'price_snapshot': ready.price,
        'quantity': bouquet.getQuantity(ready.id),
        'custom_components': null,
      });
    }

    return items;
  }

  String _generateOrderCode() {
    // Ambiguous letters (I, O, 0, 1...) are left out so codes are easy to
    // read out loud and retype.
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Cart item ids only become `order_items.product_id` when they really
  /// are a product UUID — custom bouquet entries use local ids.
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  String? _uuidOrNull(String id) => _uuidPattern.hasMatch(id) ? id : null;

  /// `order_items.item_type` shares the `products.type` vocabulary.
  static const String _bouquetType = 'ready_bouquet';
  static const String _flowerType = 'flower';

  /// Plain cart products keep their catalog type when known, falling back to
  /// `flower` — both are valid values either way.
  String _productType(String productId) {
    final isBouquet = CatalogCubit.instance.bouquets.any(
      (bouquet) => bouquet.id == productId,
    );
    return isBouquet ? _bouquetType : _flowerType;
  }

  void _resetDraft({required String lastOrderCode, required bool clearCart}) {
    BouquetCubit.instance.clear();
    if (clearCart) {
      CartCubit.instance.clearCart();
    }
    emit(CheckoutState(lastOrderCode: lastOrderCode));
  }
}
